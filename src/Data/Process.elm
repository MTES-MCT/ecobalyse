module Data.Process exposing (..)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Process =
    { id : String
    , name : String
    , country : Country
    , editable : Bool
    }


material : Process
material =
    { id = "p0"
    , name = "Matière première"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    }


spinning : Process
spinning =
    { id = "p1"
    , name = "Filature"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    , editable = False
    }


weaving : Process
weaving =
    { id = "p2"
    , name = "Tissage & tricotage"
    , country = Country.China -- note: ADEME makes Asia the default for weaving
    , editable = False
    }


confection : Process
confection =
    { id = "p3"
    , name = "Confection"
    , country = Country.France
    , editable = True
    }


ennoblement : Process
ennoblement =
    { id = "p4"
    , name = "Ennoblissement"
    , country = Country.France
    , editable = True
    }


distribution : Process
distribution =
    { id = "p5"
    , name = "Distribution"
    , country = Country.France
    , editable = True
    }


default : Array Process
default =
    Array.fromList
        [ material
        , spinning
        , weaving
        , confection
        , ennoblement
        , distribution
        ]


decode : Decoder Process
decode =
    Decode.map4 Process
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "country" Country.decode)
        (Decode.field "editable" Decode.bool)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        ]


computeTransportSummary : Array Process -> Transport.Summary
computeTransportSummary processes =
    processes
        |> Array.toIndexedList
        |> List.foldl
            (\( index, current ) acc ->
                case
                    processes
                        |> Array.get (index - 1)
                        |> Maybe.map (.country >> Transport.getDistanceInfo current.country)
                of
                    Just info ->
                        { acc
                            | road = acc.road + Tuple.first info.road
                            , sea = acc.sea + Tuple.first info.sea
                            , air = acc.air + Tuple.first info.air
                        }

                    Nothing ->
                        acc
            )
            Transport.defaultSummary


updateCountryAt : String -> Country -> Array Process -> Array Process
updateCountryAt id country =
    Array.map
        (\p ->
            if p.id == id then
                { p | country = country }

            else
                p
        )
