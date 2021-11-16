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
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type alias Step =
    { label : Label
    , country : Country
    , editable : Bool
    , inputMass : Mass
    , waste : Mass
    , transport : Transport
    , co2 : Co2e
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo
    , dyeingWeighting : Float -- FIXME: why not Maybe?
    , airTransportRatio : Float -- FIXME: why not Maybe?
    , customCountryMix : Maybe Co2e
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
    , inputMass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = default
    , co2 = Quantity.zero
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = defaultProcessInfo
    , dyeingWeighting = country.dyeingWeighting
    , airTransportRatio = 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
    , customCountryMix = Nothing
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { countryElec = Nothing
    , countryHeat = Nothing
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    }


countryMixToString : Co2e -> String
countryMixToString =
    Co2.inKgCo2e
        >> FormatNumber.format { frenchLocale | decimals = Exact 3 }
        >> (\kgCo2e -> "Mix électrique personnalisé: " ++ kgCo2e ++ "\u{202F}kgCO₂e/KWh")


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
                            |> computeTransportCo2 wellKnown roadTransportProcess next.inputMass
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
initialTransportSummary wellKnown { label, inputMass } =
    case label of
        MaterialAndSpinning ->
            -- Apply initial Material to Spinning step transport data (see Excel)
            Transport.materialToSpinningTransport
                |> computeTransportCo2 wellKnown wellKnown.roadTransportPreMaking inputMass

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


update : Inputs -> Maybe Step -> Step -> Step
update { dyeingWeighting, airTransportRatio, customCountryMixes } _ ({ label, country } as step) =
    -- Note: only WeavingKnitting, Ennoblement and Making steps renders detailed processes info.
    let
        countryElecInfo =
            Maybe.map countryMixToString
                >> Maybe.withDefault country.electricityProcess.name
                >> Just
    in
    case label of
        WeavingKnitting ->
            { step
                | customCountryMix = customCountryMixes.fabric
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = countryElecInfo customCountryMixes.fabric
                    }
            }

        Ennoblement ->
            { step
                | customCountryMix = customCountryMixes.dyeing
                , dyeingWeighting =
                    dyeingWeighting |> Maybe.withDefault step.country.dyeingWeighting
                , processInfo =
                    { defaultProcessInfo
                        | countryHeat = Just country.heatProcess.name
                        , countryElec = countryElecInfo customCountryMixes.dyeing
                        , dyeingWeighting = Just (dyeingWeightingToString country.dyeingWeighting)
                    }
            }

        Making ->
            { step
                | customCountryMix = customCountryMixes.making
                , airTransportRatio =
                    airTransportRatio |> Maybe.withDefault step.country.airTransportRatio
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = countryElecInfo customCountryMixes.making
                        , airTransportRatio =
                            country.airTransportRatio
                                |> airTransportRatioToString
                                |> Just
                    }
            }

        _ ->
            step


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
        , ( "inputMass", Encode.float (Mass.inKilograms v.inputMass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "transport", Transport.encode v.transport )
        , ( "co2", Co2.encodeKgCo2e v.co2 )
        , ( "heat", Encode.float (Energy.inMegajoules v.heat) )
        , ( "kwh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        , ( "customCountryMix", v.customCountryMix |> Maybe.map Co2.encodeKgCo2e |> Maybe.withDefault Encode.null )
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
