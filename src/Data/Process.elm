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
    }


material : Process
material =
    { id = "0"
    , name = "Matière première"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    }


spinning : Process
spinning =
    { id = "1"
    , name = "Filature"
    , country = Country.China -- note: ADEME makes Asia the default for spinning
    }


weaving : Process
weaving =
    { id = "2"
    , name = "Tissage & tricotage"
    , country = Country.China -- note: ADEME makes Asia the default for weaving
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
        [ material
        , spinning
        , weaving
        , confection
        , ennoblement
        , distribution
        ]


editable : Process -> Bool
editable process =
    List.member process.name [ "Matière", "Filature", "Tissage & tricotage" ]


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


computeTransportSummary : Array Process -> Transport.Summary
computeTransportSummary processes =
    processes
        |> Array.toIndexedList
        |> List.foldl
            (\( index, current ) acc ->
                case Array.get (index - 1) processes of
                    Just previous ->
                        let
                            info =
                                Transport.getDistanceInfo previous.country current.country
                        in
                        { acc
                            | road = acc.road + Tuple.first info.road
                            , sea = acc.sea + Tuple.first info.sea
                            , air = acc.air + Tuple.first info.air
                        }

                    Nothing ->
                        acc
            )
            Transport.defaultSummary
