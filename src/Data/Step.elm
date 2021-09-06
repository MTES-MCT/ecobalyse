module Data.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Step =
    { label : Label
    , country : Country
    , editable : Bool
    , mass : Float
    , waste : Float
    , transport : Transport.Summary
    , co2 : Float
    }


type Label
    = Default
    | Material -- Matière
    | Spinning -- Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Making -- Confection
    | Ennoblement -- Ennoblement
    | Distribution -- Distribution


default : Step
default =
    { label = Material
    , country = Country.France
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


material : Step
material =
    { label = Material
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultInitialSummary
    , co2 = 0
    }


spinning : Step
spinning =
    { label = Spinning
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


weavingKnitting : Step
weavingKnitting =
    { label = WeavingKnitting
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


confection : Step
confection =
    { label = Making
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


ennoblement : Step
ennoblement =
    { label = Ennoblement
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


distribution : Step
distribution =
    { label = Distribution
    , country = Country.France
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    , co2 = 0
    }


decode : Decoder Step
decode =
    Decode.map7 Step
        (Decode.field "label" (Decode.map labelFromString Decode.string))
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)
        (Decode.field "mass" Decode.float)
        (Decode.field "waste" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)
        (Decode.field "co2" Decode.float)


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "label", Encode.string (labelToString v.label) )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "mass", Encode.float v.mass )
        , ( "waste", Encode.float v.waste )
        , ( "transport", Transport.encodeSummary v.transport )
        , ( "co2", Encode.float v.co2 )
        ]


labelToString : Label -> String
labelToString label =
    case label of
        Default ->
            "Par défaut"

        Material ->
            "Matière première"

        Spinning ->
            "Filature"

        WeavingKnitting ->
            "Tissage & tricotage"

        Making ->
            "Confection"

        Ennoblement ->
            "Ennoblissement"

        Distribution ->
            "Distribution"


labelFromString : String -> Label
labelFromString label =
    case label of
        "Matière première" ->
            Material

        "Filature" ->
            Spinning

        "Tissage & tricotage" ->
            WeavingKnitting

        "Confection" ->
            Making

        "Ennoblissement" ->
            Ennoblement

        "Distribution" ->
            Distribution

        _ ->
            Default
