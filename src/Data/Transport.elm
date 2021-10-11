module Data.Transport exposing (..)

import Data.Country as Country exposing (..)
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Km =
    Int


type alias Ratio =
    Float


type alias Distances =
    AnyDict String Country (AnyDict String Country Transport)


type alias Transport =
    -- TODO: use elm-unit Distance.kilometers
    { road : Km, air : Km, sea : Km }


type alias Summary =
    -- TODO: use elm-unit Distance.kilometers
    { road : Km, sea : Km, air : Km, co2 : Float }


default : Transport
default =
    { road = 0, sea = 0, air = 0 }


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0, co2 = 0 }


defaultInland : Transport
defaultInland =
    { road = 500, sea = 0, air = 500 }


materialAndSpinningSummary : Summary
materialAndSpinningSummary =
    { road = materialToSpinningTransport.road
    , sea = materialToSpinningTransport.sea
    , air = materialToSpinningTransport.air
    , co2 = 0
    }


materialToSpinningTransport : Transport
materialToSpinningTransport =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = 2000, sea = 4000, air = 0 }


roadSeaTransportRatio : Int -> Float
roadSeaTransportRatio roadDistance =
    if roadDistance <= 500 then
        1

    else if roadDistance < 1000 then
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
                [ ( Bangladesh, { road = 5416, sea = 9545, air = 6000 } )
                , ( Portugal, { road = 3709, sea = 4876, air = 3200 } )
                , ( China, { road = 0, sea = 16243, air = 7100 } )
                , ( France, { road = 2798, sea = 6226, air = 2200 } )
                , ( India, { road = 0, sea = 6655, air = 4600 } )
                , ( Spain, { road = 3312, sea = 5576, air = 2700 } )
                , ( Tunisia, { road = 0, sea = 2348, air = 1700 } )
                , ( Turkey, defaultInland )
                ]
          )
        , ( Tunisia
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = 0, sea = 10605, air = 7600 } )
                , ( Portugal, { road = 0, sea = 2660, air = 1700 } )
                , ( China, { road = 0, sea = 17637, air = 8600 } )
                , ( France, { road = 0, sea = 4343, air = 1500 } )
                , ( India, { road = 0, sea = 8048, air = 6200 } )
                , ( Spain, { road = 0, sea = 3693, air = 1300 } )
                , ( Tunisia, defaultInland )
                ]
          )
        , ( India
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = 1222, sea = 4631, air = 1400 } )
                , ( Portugal, { road = 8339, sea = 10705, air = 7800 } )
                , ( China, { road = 0, sea = 11274, air = 3800 } )
                , ( France, { road = 0, sea = 11960, air = 6600 } )
                , ( India, defaultInland )
                , ( Spain, { road = 0, sea = 11310, air = 7300 } )
                ]
          )
        , ( France
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = 7995, sea = 14614, air = 7900 } )
                , ( Portugal, { road = 1138, sea = 2425, air = 1500 } )
                , ( China, { road = 0, sea = 21548, air = 8200 } )
                , ( France, defaultInland )
                , ( Spain, { road = 801, sea = 1672, air = 1100 } )
                ]
          )
        , ( Spain
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = 8653, sea = 13820, air = 8600 } )
                , ( Portugal, { road = 399, sea = 1632, air = 500 } )
                , ( China, { road = 0, sea = 20898, air = 9200 } )
                , ( Spain, defaultInland )
                ]
          )
        , ( China
          , Dict.fromList Country.toString
                [ ( Bangladesh, { road = 1897, sea = 9309, air = 3200 } )
                , ( Portugal, { road = 9157, sea = 19863, air = 10700 } )
                , ( China, defaultInland )
                ]
          )
        , ( Bangladesh
          , Dict.fromList Country.toString
                [ ( Bangladesh, defaultInland )
                , ( Portugal, { road = 9051, sea = 12723, air = 9200 } )
                ]
          )
        , ( Portugal
          , Dict.fromList Country.toString
                [ ( Portugal, defaultInland )
                ]
          )
        ]


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
    { road = road, air = air, sea = sea, co2 = 0 }


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
