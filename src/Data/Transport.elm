module Data.Transport exposing (..)

import Data.Country as Country exposing (..)
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Km =
    Int


type alias Ratio =
    Float


type alias Info =
    ( Km, Ratio )


type alias Distances =
    AnyDict String Country (AnyDict String Country Transport)


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
    { road = ( 0, 0 ), sea = ( 0, 0 ), air = ( 0, 0 ) }


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0 }


defaultInitialSummary : Summary
defaultInitialSummary =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = 2000, sea = 4000, air = 0 }


defaultInland : Transport
defaultInland =
    { road = ( 500, 1 ), sea = ( 0, 0 ), air = ( 0, 0 ) }


defaultInitial : Transport
defaultInitial =
    { road = ( 2000, 1 ), sea = ( 4000, 1 ), air = ( 0, 0 ) }


distances : Distances
distances =
    Dict.fromList Country.toString
        [ ( Turkey
          , Dict.fromList Country.toString
                [ ( China, { road = ( 0, 0 ), sea = ( 16243, 1 ), air = ( 7100, 0.33 ) } )
                , ( France, { road = ( 2798, 0.9 ), sea = ( 6226, 0.1 ), air = ( 2200, 0.33 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 6655, 1 ), air = ( 4600, 0.33 ) } )
                , ( Spain, { road = ( 3312, 0.9 ), sea = ( 5576, 0.1 ), air = ( 2700, 0.33 ) } )
                , ( Tunisia, { road = ( 0, 0 ), sea = ( 2348, 1 ), air = ( 1700, 0.33 ) } )
                , ( Turkey, defaultInland )
                ]
          )
        , ( Tunisia
          , Dict.fromList Country.toString
                [ ( China, { road = ( 0, 0 ), sea = ( 17637, 1 ), air = ( 8600, 0.33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 4343, 1 ), air = ( 1500, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 8048, 1 ), air = ( 6200, 0.33 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 3693, 1 ), air = ( 1300, 0 ) } )
                , ( Tunisia, defaultInland )
                ]
          )
        , ( India
          , Dict.fromList Country.toString
                [ ( China, { road = ( 0, 0 ), sea = ( 11274, 1 ), air = ( 3800, 0.33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 11960, 1 ), air = ( 6600, 0.33 ) } )
                , ( India, defaultInland )
                , ( Spain, { road = ( 0, 0 ), sea = ( 11310, 1 ), air = ( 7300, 0 ) } )
                ]
          )
        , ( France
          , Dict.fromList Country.toString
                [ ( China, { road = ( 0, 0 ), sea = ( 21548, 1 ), air = ( 8200, 0.33 ) } )
                , ( France, defaultInland )
                , ( Spain, { road = ( 801, 0.9 ), sea = ( 1672, 0.1 ), air = ( 1100, 0 ) } )
                ]
          )
        , ( Spain
          , Dict.fromList Country.toString
                [ ( China, { road = ( 0, 0 ), sea = ( 20898, 1 ), air = ( 9200, 0.33 ) } )
                , ( Spain, defaultInland )
                ]
          )
        , ( China
          , Dict.fromList Country.toString
                [ ( China, defaultInland )
                ]
          )
        ]


addToSummary : Summary -> Transport -> Summary
addToSummary summary transport =
    { summary
        | road = summary.road + calcInfo transport.road
        , sea = summary.sea + calcInfo transport.sea
        , air = summary.air + calcInfo transport.air
    }


calcInfo : Info -> Km
calcInfo ( km, ratio ) =
    round <| toFloat km * ratio


getTransportBetween : Country -> Country -> Transport
getTransportBetween cA cB =
    distances
        |> Dict.get cA
        |> Maybe.andThen
            (\countries ->
                case Dict.get cB countries of
                    Just transport ->
                        Just transport

                    Nothing ->
                        -- reverse query source dict
                        Just (getTransportBetween cB cA)
            )
        |> Maybe.withDefault default


toSummary : Transport -> Summary
toSummary { road, air, sea } =
    { road = calcInfo road, air = calcInfo air, sea = calcInfo sea }


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
