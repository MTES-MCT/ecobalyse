module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.CountryProcess as CountryProcess
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
    }


type alias ProcessInfo =
    { electricity : Maybe String
    , heat : Maybe String
    , dyeing : Maybe String
    }


type Label
    = Default
    | MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Ennoblement -- Ennoblement
    | Making -- Confection
    | Distribution -- Distribution


default : Step
default =
    { label = MaterialAndSpinning
    , country = Country.France
    , editable = False
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry MaterialAndSpinning Country.France
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { electricity = Nothing
    , heat = Nothing
    , dyeing = Nothing
    }


processInfoForCountry : Label -> Country -> ProcessInfo
processInfoForCountry label country =
    let
        processes =
            CountryProcess.get country
    in
    case ( label, processes ) of
        ( WeavingKnitting, Just { electricity, dyeing } ) ->
            { heat = Nothing
            , electricity = Just electricity.name
            , dyeing = Just dyeing.name
            }

        ( Ennoblement, Just { heat, electricity, dyeing } ) ->
            { heat = Just heat.name
            , electricity = Just electricity.name
            , dyeing = Just dyeing.name
            }

        ( Making, Just { electricity } ) ->
            { heat = Nothing
            , electricity = Just electricity.name
            , dyeing = Nothing
            }

        _ ->
            defaultProcessInfo


materialAndSpinning : Step
materialAndSpinning =
    { label = MaterialAndSpinning
    , country = Country.China -- note: ADEME makes Asia the default for raw material + spinning
    , editable = False
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultInitialSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry MaterialAndSpinning Country.China
    }


weavingKnitting : Step
weavingKnitting =
    { label = WeavingKnitting
    , country = Country.France
    , editable = True
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry WeavingKnitting Country.France
    }


confection : Step
confection =
    { label = Making
    , country = Country.France
    , editable = True
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry Making Country.France
    }


ennoblement : Step
ennoblement =
    { label = Ennoblement
    , country = Country.France
    , editable = True
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry Ennoblement Country.France
    }


distribution : Step
distribution =
    { label = Distribution
    , country = Country.France
    , editable = False
    , mass = Mass.kilograms 0
    , waste = Mass.kilograms 0
    , transport = Transport.defaultSummary
    , co2 = 0
    , heat = Energy.megajoules 0
    , kwh = Energy.kilowattHours 0
    , processInfo = processInfoForCountry Distribution Country.France
    }


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
        , processInfo = processInfoForCountry step.label country
    }


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
        |> Pipe.required "dyeing" (Decode.maybe Decode.string)


encodeProcessInfo : ProcessInfo -> Encode.Value
encodeProcessInfo v =
    Encode.object
        [ ( "electricity", Maybe.map Encode.string v.electricity |> Maybe.withDefault Encode.null )
        , ( "heat", Maybe.map Encode.string v.heat |> Maybe.withDefault Encode.null )
        , ( "dyeing", Maybe.map Encode.string v.dyeing |> Maybe.withDefault Encode.null )
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
