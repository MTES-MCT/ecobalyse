module Data.Process exposing (..)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Process =
    { id : String
    , name : String
    , country : Country
    }


spinning : Process
spinning =
    { id = "1"
    , name = "Matière & filature"
    , country = Country.France
    }


weaving : Process
weaving =
    { id = "2"
    , name = "Tissage & tricotage"
    , country = Country.France
    }


confection : Process
confection =
    { id = "3"
    , name = "Confection"
    , country = Country.France
    }


ennoblement : Process
ennoblement =
    { id = "4"
    , name = "Ennoblissement"
    , country = Country.France
    }


distribution : Process
distribution =
    { id = "6"
    , name = "Distribution"
    , country = Country.France
    }


default : Array Process
default =
    Array.fromList
        [ spinning
        , weaving
        , confection
        , ennoblement
        , distribution
        ]


decode : Decoder Process
decode =
    Decode.map3 Process
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "country" Country.decode)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "country", Country.encode v.country )
        ]
