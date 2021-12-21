module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Gitbook as Gitbook exposing (Path(..))
import Data.Impact as Impact exposing (Impacts)
import Data.Inputs exposing (Inputs)
import Data.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport, default, defaultInland)
import Data.Unit as Unit
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
    , outputMass : Mass
    , waste : Mass
    , transport : Transport
    , impacts : Impacts
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo
    , dyeingWeighting : Float -- FIXME: why not Maybe?
    , airTransportRatio : Float -- FIXME: why not Maybe?
    , customCountryMix : Maybe Unit.Impact
    }


type alias ProcessInfo =
    { countryElec : Maybe String
    , countryHeat : Maybe String
    , dyeingWeighting : Maybe String
    , airTransportRatio : Maybe String
    , airTransport : Maybe Process
    , seaTransport : Maybe Process
    , roadTransport : Maybe Process
    }


type Label
    = MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Ennoblement -- Ennoblement
    | Making -- Confection
    | Distribution -- Distribution


create : { db : Db, label : Label, editable : Bool, country : Country } -> Step
create { db, label, editable, country } =
    { label = label
    , country = country
    , editable = editable
    , inputMass = Quantity.zero
    , outputMass = Quantity.zero
    , waste = Quantity.zero
    , transport = Transport.default
    , impacts = Impact.impactsFromDefinitons db.impacts
    , heat = Quantity.zero
    , kwh = Quantity.zero
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
    , airTransport = Nothing
    , seaTransport = Nothing
    , roadTransport = Nothing
    }


displayLabel : { knitted : Bool } -> Label -> String
displayLabel { knitted } label =
    case ( label, knitted ) of
        ( WeavingKnitting, True ) ->
            "Tricotage"

        ( WeavingKnitting, False ) ->
            "Tissage"

        _ ->
            labelToString label


getCountryElectricityProcess : Step -> Process
getCountryElectricityProcess { country, customCountryMix } =
    let
        { electricityProcess } =
            country
    in
    case customCountryMix of
        Just mix ->
            electricityProcess
                |> Process.updateImpact (Impact.trg "cch") mix

        Nothing ->
            electricityProcess


countryMixToString : Unit.Impact -> String
countryMixToString =
    Unit.impactToFloat
        >> FormatNumber.format { frenchLocale | decimals = Exact 3 }
        >> (\kgCo2e -> "Mix électrique personnalisé: " ++ kgCo2e ++ "\u{202F}kgCO₂e/KWh")


{-| Computes step transport distances and impact regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/transport>

-}
computeTransports : Db -> Impact.Definition -> Step -> Step -> Result String Step
computeTransports db impact next ({ processInfo } as current) =
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

                    roadTransportProcess =
                        getRoadTransportProcess wellKnown current
                in
                { current
                    | processInfo =
                        { processInfo
                            | roadTransport = Just roadTransportProcess
                            , seaTransport = Just wellKnown.seaTransport
                            , airTransport = Just wellKnown.airTransport
                        }
                    , transport =
                        stepSummary
                            |> computeTransportImpacts impact
                                wellKnown
                                roadTransportProcess
                                next.inputMass
                }
            )


computeTransportImpacts : Impact.Definition -> Process.WellKnown -> Process -> Mass -> Transport -> Transport
computeTransportImpacts impact { seaTransport, airTransport } roadProcess mass { road, sea, air } =
    let
        ( roadImpact, seaImpact, airImpact ) =
            -- TODO: refactor/simplify
            ( mass |> Unit.forKgAndDistance (Process.getImpact impact.trigram roadProcess) road
            , mass |> Unit.forKgAndDistance (Process.getImpact impact.trigram seaTransport) sea
            , mass |> Unit.forKgAndDistance (Process.getImpact impact.trigram airTransport) air
            )
    in
    { road = road
    , sea = sea
    , air = air
    , impact = Quantity.sum [ roadImpact, seaImpact, airImpact ]
    }


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
            Formula.transportRatio step.airTransportRatio
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


updateFromInputs : Inputs -> Step -> Step
updateFromInputs { dyeingWeighting, airTransportRatio, customCountryMixes } ({ label, country } as step) =
    let
        countryElecInfo =
            Maybe.map countryMixToString
                >> Maybe.withDefault country.electricityProcess.name
                >> Just
    in
    -- Note: only WeavingKnitting, Ennoblement and Making steps render detailed processes info.
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
                    dyeingWeighting |> Maybe.withDefault country.dyeingWeighting
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
                    airTransportRatio |> Maybe.withDefault country.airTransportRatio
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


initMass : Mass -> Step -> Step
initMass mass step =
    { step
        | inputMass = mass
        , outputMass = mass
    }


updateWaste : Mass -> Mass -> Step -> Step
updateWaste waste mass step =
    { step
        | waste = waste
        , inputMass = mass
        , outputMass = Quantity.difference mass waste
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
        , ( "inputMass", Encode.float (Mass.inKilograms v.inputMass) )
        , ( "outputMass", Encode.float (Mass.inKilograms v.outputMass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "transport", Transport.encode v.transport )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "heat", Encode.float (Energy.inMegajoules v.heat) )
        , ( "kwh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        , ( "customCountryMix", v.customCountryMix |> Maybe.map Unit.encodeImpact |> Maybe.withDefault Encode.null )
        ]


encodeProcessInfo : ProcessInfo -> Encode.Value
encodeProcessInfo v =
    let
        encodeMaybeString =
            Maybe.map Encode.string >> Maybe.withDefault Encode.null
    in
    Encode.object
        [ ( "electricity", encodeMaybeString v.countryElec )
        , ( "heat", encodeMaybeString v.countryHeat )
        , ( "dyeing", encodeMaybeString v.dyeingWeighting )
        , ( "airTransportRatio", encodeMaybeString v.airTransportRatio )
        , ( "airTransport", v.airTransport |> Maybe.map Process.encode |> Maybe.withDefault Encode.null )
        , ( "seaTransport", v.seaTransport |> Maybe.map Process.encode |> Maybe.withDefault Encode.null )
        , ( "roadTransport", v.roadTransport |> Maybe.map Process.encode |> Maybe.withDefault Encode.null )
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
