module Data.Step exposing (..)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Step =
    { id : String
    , name : String
    , country : Country
    , editable : Bool
    }


material : Step
material =
    { id = "p0"
    , name = "Matière première"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    }


spinning : Step
spinning =
    { id = "p1"
    , name = "Filature"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    }


weaving : Step
weaving =
    { id = "p2"
    , name = "Tissage & tricotage"
    , country = Country.China -- note: ADEME makes Asia the default for weaving
    , editable = False
    }


confection : Step
confection =
    { id = "p3"
    , name = "Confection"
    , country = Country.France
    , editable = True
    }


ennoblement : Step
ennoblement =
    { id = "p4"
    , name = "Ennoblissement"
    , country = Country.France
    , editable = True
    }


distribution : Step
distribution =
    { id = "p5"
    , name = "Distribution"
    , country = Country.France
    , editable = True
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
    Decode.map4 Step
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
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
