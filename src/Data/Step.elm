module Data.Step exposing (..)

import Data.Country as Country exposing (Country2)
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Inputs exposing (Inputs)
import Data.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE


type alias Step =
    { label : Label
    , country : Country2
    , editable : Bool
    , mass : Mass
    , waste : Mass
    , transport : Transport.Summary
    , co2 : Float
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo
    , dyeingWeighting : Float
    , airTransportRatio : Float
    }


type alias ProcessInfo =
    { electricity : Maybe String
    , heat : Maybe String
    , dyeingWeighting : Maybe String
    , airTransportRatio : Maybe String
    }


type Label
    = MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Ennoblement -- Ennoblement
    | Making -- Confection
    | Distribution -- Distribution


create : Db -> Label -> Bool -> Country2 -> Result String Step
create db label editable country =
    country
        |> processCountryInfo db label
        |> Result.map
            (\processInfo ->
                { label = label
                , country = country
                , editable = editable
                , mass = Mass.kilograms 0
                , waste = Mass.kilograms 0
                , transport = Transport.defaultSummary
                , co2 = 0
                , heat = Energy.megajoules 0
                , kwh = Energy.kilowattHours 0
                , processInfo = processInfo
                , dyeingWeighting = country.dyeingWeighting
                , airTransportRatio = 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
                }
            )


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { electricity = Nothing
    , heat = Nothing
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    }


processCountryInfo : Db -> Label -> Country2 -> Result String ProcessInfo
processCountryInfo db label country =
    Ok Tuple.pair
        |> RE.andMap (db.processes |> Process.findByUuid2 country.electricity)
        |> RE.andMap (db.processes |> Process.findByUuid2 country.heat)
        |> Result.map
            (\( electricity, heat ) ->
                case label of
                    WeavingKnitting ->
                        { defaultProcessInfo | electricity = Just electricity.name }

                    Ennoblement ->
                        { defaultProcessInfo
                            | heat = Just heat.name
                            , electricity = Just electricity.name
                            , dyeingWeighting = Just (dyeingWeightingToString country.dyeingWeighting)
                        }

                    Making ->
                        { defaultProcessInfo
                            | electricity = Just electricity.name
                            , airTransportRatio =
                                country.airTransportRatio
                                    |> airTransportRatioToString
                                    |> Just
                        }

                    _ ->
                        defaultProcessInfo
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
                        Transport.getTransportBetween current.country next.country db.transports

                    ({ road, sea, air } as summary) =
                        computeTransportSummary current transport

                    roadSeaRatio =
                        Transport.roadSeaTransportRatio summary

                    stepSummary =
                        { road = (road * roadSeaRatio) * (1 - current.airTransportRatio)
                        , sea = (sea * (1 - roadSeaRatio)) * (1 - current.airTransportRatio)
                        , air = air * current.airTransportRatio
                        }
                in
                { current
                    | transport =
                        stepSummary
                            |> computeTransportCo2 wellKnown (getRoadTransportProcess wellKnown current) next.mass
                            |> Transport.addSummary (initialTransportSummary wellKnown current)
                }
            )


computeTransportCo2 : Process.WellKnown -> Process -> Mass -> Transport -> Transport.Summary
computeTransportCo2 wellKnown roadProcess mass { road, sea, air } =
    let
        ( roadCo2, seaCo2, airCo2 ) =
            ( roadProcess |> .climateChange |> (*) (Mass.inMetricTons mass) |> (*) road
            , wellKnown.seaTransport |> .climateChange |> (*) (Mass.inMetricTons mass) |> (*) sea
            , wellKnown.airTransport |> .climateChange |> (*) (Mass.inMetricTons mass) |> (*) air
            )
    in
    { road = road
    , sea = sea
    , air = air
    , co2 = roadCo2 + seaCo2 + airCo2
    }


initialTransportSummary : Process.WellKnown -> Step -> Transport.Summary
initialTransportSummary wellKnown { label, mass } =
    case label of
        MaterialAndSpinning ->
            -- Apply initial Material to Spinning step transport data (see Excel)
            Transport.materialToSpinningTransport
                |> computeTransportCo2 wellKnown wellKnown.roadTransportPreMaking mass

        _ ->
            { road = 0, sea = 0, air = 0, co2 = 0 }


computeTransportSummary : Step -> Transport -> Transport.Summary
computeTransportSummary step transport =
    case step.label of
        Ennoblement ->
            -- Doubled transports for internal Dyeing to Treatments step, no air transport (see Excel)
            { road = transport.road * 2, sea = transport.sea * 2, air = 0, co2 = 0 }

        Making ->
            -- Air transport only applies between the Making and the Distribution steps
            { road = transport.road, sea = transport.sea, air = transport.air, co2 = 0 }

        _ ->
            -- All other steps don't use air transport at all
            { road = transport.road, sea = transport.sea, air = 0, co2 = 0 }


getRoadTransportProcess : Process.WellKnown -> Step -> Process
getRoadTransportProcess wellKnown { label } =
    case label of
        Making ->
            wellKnown.roadTransportPostMaking

        Distribution ->
            wellKnown.distribution

        _ ->
            wellKnown.roadTransportPreMaking


countryLabel : Step -> String
countryLabel step =
    -- NOTE: because ADEME requires Asia as default for the Material & Spinning step,
    -- we use Asia as a label and use China behind the scene
    if step.label == MaterialAndSpinning then
        "Asie"

    else
        step.country.name


update : Db -> Inputs -> Maybe Step -> Step -> Step
update db { dyeingWeighting, airTransportRatio } _ step =
    { step
        | processInfo = processCountryInfo db step.label step.country |> Result.withDefault defaultProcessInfo
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


decode : Decoder Step
decode =
    Decode.succeed Step
        |> Pipe.required "label" decodeLabel
        |> Pipe.required "country" Country.decode2
        |> Pipe.required "editable" Decode.bool
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "transport" Transport.decodeSummary
        |> Pipe.required "co2" Decode.float
        |> Pipe.required "heat" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "kwh" (Decode.map Energy.kilowattHours Decode.float)
        |> Pipe.required "processInfo" decodeProcessInfo
        |> Pipe.required "dyeingWeighting" Decode.float
        |> Pipe.required "airTransportRatio" Decode.float


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
        , ( "country", Country.encode2 v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "transport", Transport.encodeSummary v.transport )
        , ( "co2", Encode.float v.co2 )
        , ( "heat", Encode.float (Energy.inMegajoules v.heat) )
        , ( "kwh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        ]


decodeProcessInfo : Decoder ProcessInfo
decodeProcessInfo =
    Decode.succeed ProcessInfo
        |> Pipe.required "electricity" (Decode.maybe Decode.string)
        |> Pipe.required "heat" (Decode.maybe Decode.string)
        |> Pipe.required "dyeingWeighting" (Decode.maybe Decode.string)
        |> Pipe.required "airTransportRatio" (Decode.maybe Decode.string)


encodeProcessInfo : ProcessInfo -> Encode.Value
encodeProcessInfo v =
    Encode.object
        [ ( "electricity", Maybe.map Encode.string v.electricity |> Maybe.withDefault Encode.null )
        , ( "heat", Maybe.map Encode.string v.heat |> Maybe.withDefault Encode.null )
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
