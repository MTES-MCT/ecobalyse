module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.CountryProcess as CountryProcess
import Data.Inputs exposing (Inputs)
import Data.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Step =
    { label : Label
    , country : Country
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
    = Default
    | MaterialAndSpinning -- Matière & Filature
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
    , transport =
        if label == MaterialAndSpinning then
            Transport.materialAndSpinningSummary

        else
            Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processCountryInfo label country
    , dyeingWeighting = getDyeingWeighting country
    , airTransportRatio = 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { electricity = Nothing
    , heat = Nothing
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    }


processCountryInfo : Label -> Country -> ProcessInfo
processCountryInfo label country =
    case ( label, CountryProcess.get country ) of
        ( WeavingKnitting, Just { electricity } ) ->
            { defaultProcessInfo | electricity = Just electricity.name }

        ( Ennoblement, Just { heat, electricity, dyeingWeighting } ) ->
            { defaultProcessInfo
                | heat = Just heat.name
                , electricity = Just electricity.name
                , dyeingWeighting = Just (dyeingWeightingToString dyeingWeighting)
            }

        ( Making, Just { electricity } ) ->
            { defaultProcessInfo
                | electricity = Just electricity.name
                , airTransportRatio =
                    country
                        |> Transport.defaultAirTransportRatio
                        |> airTransportRatioToString
                        |> Just
            }

        _ ->
            defaultProcessInfo


getDyeingWeighting : Country -> Float
getDyeingWeighting =
    CountryProcess.get >> Maybe.map .dyeingWeighting >> Maybe.withDefault 0


{-| Computes step transport distances and co2 scores regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/transport>

-}
computeTransports : Step -> Step -> Step
computeTransports next current =
    let
        { road, sea, air } =
            Transport.getTransportBetween current.country next.country
                |> computeTransportSummary current

        initial =
            initialTransport current

        roadSeaRatio =
            Transport.roadSeaTransportRatio (max road sea)

        ( handledRoad, handledSea, handledAir ) =
            ( initial.road + ((toFloat road * roadSeaRatio) * (1 - current.airTransportRatio))
            , initial.sea + ((toFloat sea * (1 - roadSeaRatio)) * (1 - current.airTransportRatio))
            , initial.air + (toFloat air * current.airTransportRatio)
            )

        ( roadCo2, seaCo2, airCo2 ) =
            ( getRoadTransportProcess current |> .climateChange |> (*) (Mass.inMetricTons current.mass) |> (*) handledRoad
            , Process.seaTransport |> .climateChange |> (*) (Mass.inMetricTons current.mass) |> (*) handledSea
            , Process.airTransport |> .climateChange |> (*) (Mass.inMetricTons current.mass) |> (*) handledAir
            )
    in
    { current
        | transport =
            { road = round handledRoad
            , sea = round handledSea
            , air = round handledAir
            , co2 = airCo2 + seaCo2 + roadCo2
            }
    }


initialTransport : Step -> { road : Float, sea : Float, air : Float }
initialTransport { label } =
    case label of
        MaterialAndSpinning ->
            -- Apply initial Material to Spinning step transport data (see Excel)
            { road = toFloat Transport.materialAndSpinningSummary.road
            , sea = toFloat Transport.materialAndSpinningSummary.sea
            , air = toFloat Transport.materialAndSpinningSummary.air
            }

        _ ->
            { road = 0, sea = 0, air = 0 }


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


getRoadTransportProcess : Step -> Process
getRoadTransportProcess { label } =
    case label of
        Making ->
            Process.roadTransportPostMaking

        Distribution ->
            Process.distribution

        _ ->
            Process.roadTransportPreMaking


countryLabel : Step -> String
countryLabel step =
    -- NOTE: because ADEME requires Asia as default for the Material & Spinning step,
    -- we use Asia as a label and use China behind the scene
    if step.label == MaterialAndSpinning then
        "Asie"

    else
        Country.toString step.country


update : Inputs -> Maybe Step -> Step -> Step
update { dyeingWeighting, airTransportRatio } _ step =
    { step
        | processInfo = processCountryInfo step.label step.country
        , dyeingWeighting =
            if step.label == Ennoblement then
                dyeingWeighting |> Maybe.withDefault (getDyeingWeighting step.country)

            else
                step.dyeingWeighting
        , airTransportRatio =
            if step.label == Making then
                airTransportRatio |> Maybe.withDefault (Transport.defaultAirTransportRatio step.country)

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
        |> Pipe.required "label" (Decode.map labelFromString Decode.string)
        |> Pipe.required "country" Country.decode
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


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "label", Encode.string (labelToString v.label) )
        , ( "country", Country.encode v.country )
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
        Default ->
            "Par défaut"

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


labelFromString : String -> Label
labelFromString label =
    case label of
        "Matière & Filature" ->
            MaterialAndSpinning

        "Tissage & Tricotage" ->
            WeavingKnitting

        "Confection" ->
            Making

        "Teinture" ->
            Ennoblement

        "Distribution" ->
            Distribution

        _ ->
            Default
