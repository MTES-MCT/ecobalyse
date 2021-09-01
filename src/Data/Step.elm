module Data.Step exposing (..)

-- import Data.Product exposing (Product)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-- type alias StepData =
--     { country : Country
--     , massKg : MassKg
--     , product : Product
--     , editable : Bool
--     }


type alias Steps =
    { material : Step
    , spinning : Step
    , weaving : Step
    , confection : Step
    , ennoblement : Step
    , distribution : Step
    }


type alias Step =
    { id : String
    , name : String
    , country : Country
    , editable : Bool
    , mass : Float
    }


material : Step
material =
    { id = "p0"
    , name = "Matière première"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    }


spinning : Step
spinning =
    { id = "p1"
    , name = "Filature"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    , mass = 0
    }


weaving : Step
weaving =
    { id = "p2"
    , name = "Tissage & tricotage"
    , country = Country.China -- note: ADEME makes Asia the default for weaving
    , editable = False
    , mass = 0
    }


confection : Step
confection =
    { id = "p3"
    , name = "Confection"
    , country = Country.France
    , editable = True
    , mass = 0
    }


ennoblement : Step
ennoblement =
    { id = "p4"
    , name = "Ennoblissement"
    , country = Country.France
    , editable = True
    , mass = 0
    }


distribution : Step
distribution =
    { id = "p5"
    , name = "Distribution"
    , country = Country.France
    , editable = True
    , mass = 0
    }


default : Array Step
default =
    Array.fromList
        [ material
        , spinning
        , weaving
        , confection
        , ennoblement
        , distribution
        ]


decode : Decoder Step
decode =
    Decode.map5 Step
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)
        (Decode.field "mass" Decode.float)


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "mass", Encode.float v.mass )
        ]


computeTransportSummary : Array Step -> Transport.Summary
computeTransportSummary steps =
    steps
        |> Array.toIndexedList
        |> List.foldl
            (\( index, current ) summary ->
                case
                    steps
                        |> Array.get (index - 1)
                        |> Maybe.map (.country >> Transport.getTransportBetween current.country)
                of
                    Just transport ->
                        Transport.addToSummary transport summary

                    Nothing ->
                        summary
            )
            Transport.defaultSummary


updateCountryAt : String -> Country -> Array Step -> Array Step
updateCountryAt id country =
    Array.map
        (\p ->
            if p.id == id then
                { p | country = country }

            else
                p
        )
