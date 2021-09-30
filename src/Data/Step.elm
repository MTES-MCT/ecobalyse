module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.CountryProcess as CountryProcess
import Data.Process exposing (Cat3(..))
import Data.Transport as Transport
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
    }


type alias ProcessInfo =
    { electricity : Maybe String
    , heat : Maybe String
    , dyeingWeighting : Maybe String
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
            Transport.defaultInitialSummary

        else
            Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processCountryInfo label country
    , dyeingWeighting = getDyeingWeighting country
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { electricity = Nothing
    , heat = Nothing
    , dyeingWeighting = Nothing
    }


processCountryInfo : Label -> Country -> ProcessInfo
processCountryInfo label country =
    case ( label, CountryProcess.get country ) of
        ( WeavingKnitting, Just { electricity } ) ->
            { heat = Nothing
            , electricity = Just electricity.name
            , dyeingWeighting = Nothing
            }

        ( Ennoblement, Just { heat, electricity, dyeingWeighting } ) ->
            { heat = Just heat.name
            , electricity = Just electricity.name
            , dyeingWeighting = Just (dyeingWeightingToString dyeingWeighting)
            }

        ( Making, Just { electricity } ) ->
            { heat = Nothing
            , electricity = Just electricity.name
            , dyeingWeighting = Nothing
            }

        _ ->
            defaultProcessInfo


getDyeingWeighting : Country -> Float
getDyeingWeighting =
    CountryProcess.get >> Maybe.map .dyeingWeighting >> Maybe.withDefault 0


countryLabel : Step -> String
countryLabel step =
    -- NOTE: because ADEME requires Asia as default for the Material & Spinning step,
    -- we use Asia as a label and use China behind the scene
    if step.label == MaterialAndSpinning then
        "Asie"

    else
        Country.toString step.country


updateCountry : Country -> Step -> Step
updateCountry country step =
    { step
        | country = country
        , processInfo = processCountryInfo step.label country
        , dyeingWeighting =
            if step.label == Ennoblement then
                getDyeingWeighting country

            else
                step.dyeingWeighting
    }


updateDyeingWeighting : Float -> Step -> Step
updateDyeingWeighting dyeingWeighting ({ processInfo } as step) =
    { step
        | dyeingWeighting = dyeingWeighting
        , processInfo =
            if step.label == Ennoblement then
                { processInfo | dyeingWeighting = Just (dyeingWeightingToString dyeingWeighting) }

            else
                processInfo
    }


dyeingWeightingToString : Float -> String
dyeingWeightingToString dyeingWeighting =
    let
        p =
            round (dyeingWeighting * 100)
    in
    if p == 0 then
        "Procédé représentatif"

    else
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
        ]


decodeProcessInfo : Decoder ProcessInfo
decodeProcessInfo =
    Decode.succeed ProcessInfo
        |> Pipe.required "electricity" (Decode.maybe Decode.string)
        |> Pipe.required "heat" (Decode.maybe Decode.string)
        |> Pipe.required "dyeingWeighting" (Decode.maybe Decode.string)


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
