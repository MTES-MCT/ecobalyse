module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.Transport as Transport
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
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
    Decode.map8 Step
        (Decode.field "label" (Decode.map labelFromString Decode.string))
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "waste" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "transport" Transport.decodeSummary)
        (Decode.field "co2" Decode.float)
        (Decode.field "heat" (Decode.map Energy.megajoules Decode.float))


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
