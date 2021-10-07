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
    , co2 : Float
    }


default : Transport
default =
    { road = ( 0, 0 ), sea = ( 0, 0 ), air = ( 0, 0 ) }


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0, co2 = 0 }


defaultInitialSummary : Summary
defaultInitialSummary =
    { road = Tuple.first defaultInitial.road
    , sea = Tuple.first defaultInitial.sea
    , air = Tuple.first defaultInitial.air
    , co2 = 0
    }


defaultInland : Transport
defaultInland =
    { road = ( 500, 1 ), sea = ( 0, 0 ), air = ( 0, 0 ) }


defaultInitial : Transport
defaultInitial =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = ( 2000, 1 ), sea = ( 4000, 1 ), air = ( 0, 0 ) }


roadSeaTransportRatio : Int -> Float
roadSeaTransportRatio roadDistance =
    -- FIXME: this is unused for now, but should be eventually for computing
    -- road/sea transport ratios from initial distances. Meaning we'll eventually
    -- get rid of the tuples in the Transport type.
    if roadDistance < 1000 then
        0.9

    else if roadDistance < 2000 then
        0.5

    else
        0.25


defaultAirTransportRatio : Country -> Float
defaultAirTransportRatio country =
    if List.member country [ Bangladesh, China, India, Turkey ] then
        0.33

    else
        0


distances : Distances
distances =
    Dict.fromList Country.toString
        [ ( Turkey
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 5416, 0 ), sea = ( 9545, 1 ), air = ( 6000, 0.33 ) } )
                , ( Portugal, { road = ( 3709, 0.25 ), sea = ( 4876, 0.75 ), air = ( 3200, 0.33 ) } )
                , ( China, { road = ( 0, 0 ), sea = ( 16243, 1 ), air = ( 7100, 0.33 ) } )
                , ( France, { road = ( 2798, 0.25 ), sea = ( 6226, 0.75 ), air = ( 2200, 0.33 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 6655, 1 ), air = ( 4600, 0.33 ) } )
                , ( Spain, { road = ( 3312, 0.25 ), sea = ( 5576, 0.75 ), air = ( 2700, 0.33 ) } )
                , ( Tunisia, { road = ( 0, 0 ), sea = ( 2348, 1 ), air = ( 1700, 0.33 ) } )
                , ( Turkey, defaultInland )
                ]
          )
        , ( Tunisia
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 0, 0 ), sea = ( 10605, 1 ), air = ( 7600, 0 ) } )
                , ( Portugal, { road = ( 0, 0 ), sea = ( 2660, 1 ), air = ( 1700, 0 ) } )
                , ( China, { road = ( 0, 0 ), sea = ( 17637, 1 ), air = ( 8600, 0.33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 4343, 1 ), air = ( 1500, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 8048, 1 ), air = ( 6200, 0.33 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 3693, 1 ), air = ( 1300, 0 ) } )
                , ( Tunisia, defaultInland )
                ]
          )
        , ( India
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 1222, 0.5 ), sea = ( 4631, 0.5 ), air = ( 1400, 0 ) } )
                , ( Portugal, { road = ( 8339, 0 ), sea = ( 10705, 1 ), air = ( 7800, 0.33 ) } )
                , ( China, { road = ( 0, 0 ), sea = ( 11274, 1 ), air = ( 3800, 0.33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 11960, 1 ), air = ( 6600, 0.33 ) } )
                , ( India, defaultInland )
                , ( Spain, { road = ( 0, 0 ), sea = ( 11310, 1 ), air = ( 7300, 0 ) } )
                ]
          )
        , ( France
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 7995, 0 ), sea = ( 14614, 1 ), air = ( 7900, 0.33 ) } )
                , ( Portugal, { road = ( 1138, 0.5 ), sea = ( 2425, 0.5 ), air = ( 1500, 0.33 ) } )
                , ( China, { road = ( 0, 0 ), sea = ( 21548, 1 ), air = ( 8200, 0.33 ) } )
                , ( France, defaultInland )
                , ( Spain, { road = ( 801, 0.9 ), sea = ( 1672, 0.1 ), air = ( 1100, 0 ) } )
                ]
          )
        , ( Spain
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 8653, 0 ), sea = ( 13820, 1 ), air = ( 8600, 0.33 ) } )
                , ( Portugal, { road = ( 399, 0.9 ), sea = ( 1632, 0.1 ), air = ( 500, 0.33 ) } )
                , ( China, { road = ( 0, 0 ), sea = ( 20898, 1 ), air = ( 9200, 0.33 ) } )
                , ( Spain, defaultInland )
                ]
          )
        , ( China
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = ( 1897, 0 ), sea = ( 9309, 1 ), air = ( 3200, 0 ) } )
                , ( Portugal, { road = ( 9157, 0 ), sea = ( 19863, 1 ), air = ( 10700, 0.33 ) } )
                , ( China, defaultInland )
                ]
          )
        , ( Bangladesh
          , Dict.fromList Country.toString
                [ ( Bangladesh, defaultInland )
                , ( Portugal, { road = ( 9051, 0 ), sea = ( 12723, 1 ), air = ( 9200, 0.33 ) } )
                ]
          )
        , ( Portugal
          , Dict.fromList Country.toString
                [ ( Portugal, defaultInland )
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
    { road = calcInfo road
    , air = calcInfo air
    , sea = calcInfo sea
    , co2 = 0
    }


decodeSummary : Decoder Summary
decodeSummary =
    Decode.map4 Summary
        (Decode.field "road" Decode.int)
        (Decode.field "air" Decode.int)
        (Decode.field "sea" Decode.int)
        (Decode.field "co2" Decode.float)


encodeSummary : Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "road", Encode.int summary.road )
        , ( "air", Encode.int summary.air )
        , ( "sea", Encode.int summary.sea )
        , ( "co2", Encode.float summary.co2 )
        ]
