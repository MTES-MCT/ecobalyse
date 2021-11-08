module Data.Step exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Gitbook as Gitbook exposing (Path(..))
import Data.Inputs exposing (Inputs)
import Data.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport, default, defaultInland)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type alias Step =
    { label : Label
    , country : Country
    , editable : Bool
    , mass : Mass
    , waste : Mass
    , transport : Transport
    , co2 : Co2e
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo

    -- TODO: move custom ratios to custom values?
    , dyeingWeighting : Float -- why not Maybe?
    , airTransportRatio : Float -- why not Maybe?
    , customValues : CustomValues
    }


type alias CustomValues =
    { countryMix : Maybe Co2e
    }


type alias ProcessInfo =
    { countryElec : Maybe String
    , countryHeat : Maybe String
    , dyeingWeighting : Maybe String
    , airTransportRatio : Maybe String
    }


type Label
    = MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Ennoblement -- Ennoblement
    | Making -- Confection
    | Distribution -- Distribution


create : Label -> Bool -> Country -> Step
create label editable country =
    { label = label
    , country = country
    , editable = editable
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = default
    , co2 = Quantity.zero
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = defaultProcessInfo
    , dyeingWeighting = country.dyeingWeighting
    , airTransportRatio = 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
    , customValues = defaultCustomValues
    }


defaultCustomValues : CustomValues
defaultCustomValues =
    { countryMix = Nothing
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { countryElec = Nothing
    , countryHeat = Nothing
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    }


processInfo : Step -> ProcessInfo
processInfo { label, country, customValues } =
    let
        countryElec =
            customValues.countryMix
                |> Maybe.map countryMixToString
                |> Maybe.withDefault country.electricityProcess.name
    in
    case label of
        WeavingKnitting ->
            { defaultProcessInfo
                | countryElec = Just countryElec
            }

        Ennoblement ->
            { defaultProcessInfo
                | countryHeat = Just country.heatProcess.name
                , countryElec = Just countryElec
                , dyeingWeighting = Just (dyeingWeightingToString country.dyeingWeighting)
            }

        Making ->
            { defaultProcessInfo
                | countryElec = Just countryElec
                , airTransportRatio =
                    country.airTransportRatio
                        |> airTransportRatioToString
                        |> Just
            }

        _ ->
            defaultProcessInfo


countryMixToString : Co2e -> String
countryMixToString =
    Co2.inKgCo2e
        >> String.fromFloat
        >> (\kgCo2e ->
                -- FIXME: better format float number
                "Mix électrique personnalisé\u{00A0}: " ++ kgCo2e ++ "kgCO₂e"
           )


{-| Computes step transport distances and co2 scores regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/transport>

-}
computeTransports : Db -> Step -> Step -> Result String Step
computeTransports db next current =
    db.processes
        |> Process.loadWellKnown
        |> Result.map
            (\wellKnown ->
                let
                    transport =
                        db.transports
                            |> Transport.getTransportBetween current.country.code next.country.code

                    stepSummary =
                        computeTransportSummary current transport
                            |> Formula.transportRatio current.airTransportRatio

                    roadTransportProcess =
                        getRoadTransportProcess wellKnown current
                in
                { current
                    | transport =
                        stepSummary
                            |> computeTransportCo2 wellKnown roadTransportProcess next.mass
                            |> Transport.add (initialTransportSummary wellKnown current)
                }
            )


computeTransportCo2 : Process.WellKnown -> Process -> Mass -> Transport -> Transport
computeTransportCo2 { seaTransport, airTransport } roadProcess mass { road, sea, air } =
    let
        ( roadCo2, seaCo2, airCo2 ) =
            ( mass |> Co2.forKgAndDistance roadProcess.climateChange road
            , mass |> Co2.forKgAndDistance seaTransport.climateChange sea
            , mass |> Co2.forKgAndDistance airTransport.climateChange air
            )
    in
    { road = road
    , sea = sea
    , air = air
    , co2 = Quantity.sum [ roadCo2, seaCo2, airCo2 ]
    }


initialTransportSummary : Process.WellKnown -> Step -> Transport
initialTransportSummary wellKnown { label, mass } =
    case label of
        MaterialAndSpinning ->
            -- Apply initial Material to Spinning step transport data (see Excel)
            Transport.materialToSpinningTransport
                |> computeTransportCo2 wellKnown wellKnown.roadTransportPreMaking mass

        _ ->
            default


computeTransportSummary : Step -> Transport -> Transport
computeTransportSummary step transport =
    case step.label of
        Ennoblement ->
            -- Added intermediary defaultInland transport step to materialize
            -- Processing + Dyeing steps (see Excel)
            { default
                | road = transport.road |> Quantity.plus defaultInland.road
                , sea = transport.sea |> Quantity.plus defaultInland.sea
            }

        Making ->
            -- Air transport only applies between the Making and the Distribution steps
            { default
                | road = transport.road
                , sea = transport.sea
                , air = transport.air
            }

        _ ->
            -- All other steps don't use air transport at all
            { default
                | road = transport.road
                , sea = transport.sea
            }


getRoadTransportProcess : Process.WellKnown -> Step -> Process
getRoadTransportProcess wellKnown { label } =
    case label of
        Making ->
            wellKnown.roadTransportPostMaking

        Distribution ->
            wellKnown.distribution

        _ ->
            wellKnown.roadTransportPreMaking


updateCustomValues : (CustomValues -> CustomValues) -> Step -> Step
updateCustomValues update_ ({ customValues } as step) =
    { step | customValues = update_ customValues }


update : Inputs -> Maybe Step -> Step -> Step
update { dyeingWeighting, airTransportRatio } _ step =
    { step
        | processInfo =
            processInfo step
        , dyeingWeighting =
            if step.label == Ennoblement then
                dyeingWeighting |> Maybe.withDefault step.country.dyeingWeighting

            else
                step.dyeingWeighting
        , airTransportRatio =
            if step.label == Making then
                airTransportRatio |> Maybe.withDefault step.country.airTransportRatio

            else
                step.airTransportRatio
    }


airTransportRatioToString : Float -> String
airTransportRatioToString airTransportRatio =
    case round (airTransportRatio * 100) of
        0 ->
            "Aucun transport aérien"

        p ->
            String.fromInt p ++ "% de transport aérien"


dyeingWeightingToString : Float -> String
dyeingWeightingToString dyeingWeighting =
    case round (dyeingWeighting * 100) of
        0 ->
            "Procédé représentatif"

        p ->
            "Procédé " ++ String.fromInt p ++ "% majorant"


decodeLabel : Decoder Label
decodeLabel =
    Decode.string
        |> Decode.andThen
            (\label ->
                case labelFromString label of
                    Just decoded ->
                        Decode.succeed decoded

                    Nothing ->
                        Decode.fail ("Invalid step : " ++ label)
            )


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "label", Encode.string (labelToString v.label) )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "transport", Transport.encode v.transport )
        , ( "co2", Co2.encodeKgCo2e v.co2 )
        , ( "heat", Encode.float (Energy.inMegajoules v.heat) )
        , ( "kwh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        , ( "customValues", encodeCustomValues v.customValues )
        ]


encodeCustomValues : CustomValues -> Encode.Value
encodeCustomValues v =
    Encode.object
        [ ( "countryMix", v.countryMix |> Maybe.map Co2.encodeKgCo2e |> Maybe.withDefault Encode.null )
        ]


encodeProcessInfo : ProcessInfo -> Encode.Value
encodeProcessInfo v =
    Encode.object
        [ ( "electricity", Maybe.map Encode.string v.countryElec |> Maybe.withDefault Encode.null )
        , ( "heat", Maybe.map Encode.string v.countryHeat |> Maybe.withDefault Encode.null )
        , ( "dyeing", Maybe.map Encode.string v.dyeingWeighting |> Maybe.withDefault Encode.null )
        ]


labelToString : Label -> String
labelToString label =
    case label of
        MaterialAndSpinning ->
            "Matière & Filature"

        WeavingKnitting ->
            "Tissage & Tricotage"

        Making ->
            "Confection"

        Ennoblement ->
            "Teinture"

        Distribution ->
            "Distribution"


labelFromString : String -> Maybe Label
labelFromString label =
    case label of
        "Matière & Filature" ->
            Just MaterialAndSpinning

        "Tissage & Tricotage" ->
            Just WeavingKnitting

        "Confection" ->
            Just Making

        "Teinture" ->
            Just Ennoblement

        "Distribution" ->
            Just Distribution

        _ ->
            Nothing


getStepGitbookPath : Label -> Gitbook.Path
getStepGitbookPath label =
    case label of
        MaterialAndSpinning ->
            Gitbook.MaterialAndSpinning

        WeavingKnitting ->
            Gitbook.WeavingKnitting

        Ennoblement ->
            Gitbook.Dyeing

        Making ->
            Gitbook.Making

        Distribution ->
            Gitbook.Distribution
