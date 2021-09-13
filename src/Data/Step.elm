module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
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
    }


type Label
    = Default
    | MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Making -- Confection
    | Ennoblement -- Ennoblement
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
    }


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
    }


countryLabel : Step -> String
countryLabel step =
    -- NOTE: because ADEME requires Asia as default for the Material & Spinning step,
    -- we use Asia as a label and use China behind the scene
    if step.label == MaterialAndSpinning then
        "Asie"

    else
        Country.toString step.country


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
