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
    }


material : Step
material =
    { label = Material
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultInitialSummary
    }


spinning : Step
spinning =
    { label = Spinning
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    }


weaving : Step
weaving =
    { label = WeavingKnitting
    , country = Country.China -- note: ADEME makes Asia the default for weaving
    , editable = False
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    }


confection : Step
confection =
    { label = Making
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    }


ennoblement : Step
ennoblement =
    { label = Ennoblement
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    }


distribution : Step
distribution =
    { label = Distribution
    , country = Country.France
    , editable = True
    , mass = 0
    , waste = 0
    , transport = Transport.defaultSummary
    }


decode : Decoder Step
decode =
    Decode.map6 Step
        (Decode.field "label" (Decode.map labelFromString Decode.string))
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)
        (Decode.field "mass" Decode.float)
        (Decode.field "waste" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "label", Encode.string (labelToString v.label) )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "mass", Encode.float v.mass )
        , ( "waste", Encode.float v.waste )
        , ( "transport", Transport.encodeSummary v.transport )
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
