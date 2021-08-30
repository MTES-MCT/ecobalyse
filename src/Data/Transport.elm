module Data.Transport exposing (..)

import Data.Country as Country exposing (..)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Km =
    Int


type alias Ratio =
    Int


type alias Info =
    ( Km, Ratio )


type alias Transport =
    { road : ( Km, Ratio )
    , air : ( Km, Ratio )
    , sea : ( Km, Ratio )
    }


type alias Summary =
    { road : Km
    , sea : Km
    , air : Km
    }


default : Transport
default =
    Transport ( 0, 0 ) ( 0, 0 ) ( 0, 0 )


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0 }


toDict : List ( Country, a ) -> Dict String a
toDict =
    List.map (Tuple.mapFirst Country.toString) >> Dict.fromList


defaultInland : Transport
defaultInland =
    { road = ( 500, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) }


distances : Dict String (Dict String Transport)
distances =
    toDict
        [ ( Turkey
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 16243, 100 ), air = ( 7100, 33 ) } )
                , ( France, { road = ( 2798, 90 ), sea = ( 6226, 10 ), air = ( 2200, 33 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 6655, 100 ), air = ( 4600, 33 ) } )
                , ( Spain, { road = ( 3312, 90 ), sea = ( 5576, 10 ), air = ( 2700, 33 ) } )
                , ( Tunisia, { road = ( 0, 0 ), sea = ( 2348, 100 ), air = ( 1700, 33 ) } )
                , ( Turkey, defaultInland )
                ]
          )
        , ( Tunisia
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 17637, 100 ), air = ( 8600, 33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 4343, 100 ), air = ( 1500, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 8048, 100 ), air = ( 6200, 33 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 3693, 100 ), air = ( 1300, 0 ) } )
                , ( Tunisia, defaultInland )
                ]
          )
        , ( India
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 11274, 100 ), air = ( 3800, 33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 11960, 100 ), air = ( 6600, 33 ) } )
                , ( India, defaultInland )
                , ( Spain, { road = ( 0, 0 ), sea = ( 11310, 100 ), air = ( 7300, 0 ) } )
                ]
          )
        , ( France
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 21548, 100 ), air = ( 8200, 33 ) } )
                , ( France, defaultInland )
                , ( Spain, { road = ( 801, 90 ), sea = ( 1672, 10 ), air = ( 1100, 0 ) } )
                ]
          )
        , ( Spain
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 20898, 100 ), air = ( 9200, 33 ) } )
                , ( Spain, defaultInland )
                ]
          )
        , ( China
          , toDict
                [ ( China, defaultInland )
                ]
          )
        ]


addToSummary : Transport -> Summary -> Summary
addToSummary transport summary =
    { summary
        | road = summary.road + calcInfo transport.road
        , sea = summary.sea + calcInfo transport.sea
        , air = summary.air + calcInfo transport.air
    }


calcInfo : Info -> Km
calcInfo ( km, ratio ) =
    round <| toFloat km * (toFloat ratio / toFloat 100)


getTransportBetween : Country -> Country -> Transport
getTransportBetween cA cB =
    distances
        |> Dict.get (Country.toString cA)
        |> Maybe.andThen
            (\countries ->
                case Dict.get (Country.toString cB) countries of
                    Just transport ->
                        Just transport

                    Nothing ->
                        -- reverse query source dict
                        Just (getTransportBetween cB cA)
            )
        |> Maybe.withDefault default


decodeSummary : Decoder Summary
decodeSummary =
    Decode.map3 Summary
        (Decode.field "road" Decode.int)
        (Decode.field "air" Decode.int)
        (Decode.field "sea" Decode.int)


encodeSummary : Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "road", Encode.int summary.road )
        , ( "air", Encode.int summary.air )
        , ( "sea", Encode.int summary.sea )
        ]
