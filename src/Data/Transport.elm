module Data.Transport exposing (..)

import Data.Country as Country exposing (Country2)
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Km =
    Float


type alias Ratio =
    Float


type alias Distance =
    AnyDict String Country.Code Transport


type alias Distances =
    AnyDict String Country.Code Distance


type alias Transport =
    -- TODO: use elm-unit Distance.kilometers
    { road : Km, sea : Km, air : Km }


type alias Summary =
    -- TODO: use elm-unit Distance.kilometers
    { road : Km, sea : Km, air : Km, co2 : Float }


default : Transport
default =
    { road = 0, sea = 0, air = 0 }


emptyDistances : Distances
emptyDistances =
    Dict.fromList Country.codeToString []


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0, co2 = 0 }


defaultInland : Transport
defaultInland =
    { road = 500, sea = 0, air = 500 }


addSummary : Summary -> Summary -> Summary
addSummary sA sB =
    { sA
        | road = sA.road + sB.road
        , sea = sA.sea + sB.sea
        , air = sA.air + sB.air
        , co2 = sA.co2 + sB.co2
    }


materialToSpinningTransport : Transport
materialToSpinningTransport =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = 2000, sea = 4000, air = 0 }


{-| Determine road/sea transport ratio, so rad transport is priviledged
for shorter distances. A few notes:

  - When no road distance, we fully take sea distance
  - When no sea distance, we fully take road distance
  - Otherwise we can apply distinct ratios

-}
roadSeaTransportRatio : Summary -> Float
roadSeaTransportRatio { road, sea } =
    if road == 0 then
        0

    else if sea == 0 then
        1

    else if road <= 500 then
        1

    else if road < 1000 then
        0.9

    else if road < 2000 then
        0.5

    else
        0.25


distances : Distances
distances =
    Dict.fromList Country.codeToString
        [ ( Country.Code "TR"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 5416, sea = 9545, air = 6000 } )
                , ( Country.Code "PT", { road = 3709, sea = 4876, air = 3200 } )
                , ( Country.Code "CN", { road = 0, sea = 16243, air = 7100 } )
                , ( Country.Code "FR", { road = 2798, sea = 6226, air = 2200 } )
                , ( Country.Code "IN", { road = 0, sea = 6655, air = 4600 } )
                , ( Country.Code "ES", { road = 3312, sea = 5576, air = 2700 } )
                , ( Country.Code "TN", { road = 0, sea = 2348, air = 1700 } )
                , ( Country.Code "TR", defaultInland )
                ]
          )
        , ( Country.Code "TN"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 0, sea = 10605, air = 7600 } )
                , ( Country.Code "PT", { road = 0, sea = 2660, air = 1700 } )
                , ( Country.Code "CN", { road = 0, sea = 17637, air = 8600 } )
                , ( Country.Code "FR", { road = 0, sea = 4343, air = 1500 } )
                , ( Country.Code "IN", { road = 0, sea = 8048, air = 6200 } )
                , ( Country.Code "ES", { road = 0, sea = 3693, air = 1300 } )
                , ( Country.Code "TN", defaultInland )
                ]
          )
        , ( Country.Code "IN"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 1222, sea = 4631, air = 1400 } )
                , ( Country.Code "PT", { road = 8339, sea = 10705, air = 7800 } )
                , ( Country.Code "CN", { road = 0, sea = 11274, air = 3800 } )
                , ( Country.Code "FR", { road = 0, sea = 11960, air = 6600 } )
                , ( Country.Code "IN", defaultInland )
                , ( Country.Code "ES", { road = 0, sea = 11310, air = 7300 } )
                ]
          )
        , ( Country.Code "FR"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 7995, sea = 14614, air = 7900 } )
                , ( Country.Code "PT", { road = 1138, sea = 2425, air = 1500 } )
                , ( Country.Code "CN", { road = 0, sea = 21548, air = 8200 } )
                , ( Country.Code "FR", defaultInland )
                , ( Country.Code "ES", { road = 801, sea = 1672, air = 1100 } )
                ]
          )
        , ( Country.Code "ES"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 8653, sea = 13820, air = 8600 } )
                , ( Country.Code "PT", { road = 399, sea = 1632, air = 500 } )
                , ( Country.Code "CN", { road = 0, sea = 20898, air = 9200 } )
                , ( Country.Code "ES", defaultInland )
                ]
          )
        , ( Country.Code "CN"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", { road = 1897, sea = 9309, air = 3200 } )
                , ( Country.Code "PT", { road = 9157, sea = 19863, air = 10700 } )
                , ( Country.Code "CN", defaultInland )
                ]
          )
        , ( Country.Code "BD"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "BD", defaultInland )
                , ( Country.Code "PT", { road = 9051, sea = 12723, air = 9200 } )
                ]
          )
        , ( Country.Code "PT"
          , Dict.fromList Country.codeToString
                [ ( Country.Code "PT", defaultInland )
                ]
          )
        ]


getTransportBetween : Country2 -> Country2 -> Transport
getTransportBetween cA cB =
    -- FIXME:
    -- - if cA == cB -> defaultTransportInland
    -- - remove duplicates from transports.json
    -- - make this a Result String Transport
    distances
        |> Dict.get cA.code
        |> Maybe.andThen
            (\countries ->
                case Dict.get cB.code countries of
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


decodeTransport : Decoder Transport
decodeTransport =
    Decode.map3 Transport
        (Decode.field "road" Decode.float)
        (Decode.field "air" Decode.float)
        (Decode.field "sea" Decode.float)


encodeTransport : Transport -> Encode.Value
encodeTransport v =
    Encode.object
        [ ( "road", Encode.float v.road )
        , ( "sea", Encode.float v.sea )
        , ( "air", Encode.float v.air )
        ]


decodeSummary : Decoder Summary
decodeSummary =
    Decode.map4 Summary
        (Decode.field "road" Decode.float)
        (Decode.field "air" Decode.float)
        (Decode.field "sea" Decode.float)
        (Decode.field "co2" Decode.float)


encodeSummary : Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "road", Encode.float summary.road )
        , ( "air", Encode.float summary.air )
        , ( "sea", Encode.float summary.sea )
        , ( "co2", Encode.float summary.co2 )
        ]


decodeDistance : Decoder Distance
decodeDistance =
    -- FIXME: Ideally we want to check for available country codes
    Dict.decode
        (\str _ -> Country.codeFromString str)
        Country.codeToString
        decodeTransport


decodeDistances : Decoder Distances
decodeDistances =
    -- FIXME: Ideally we want to check for available country codes
    Dict.decode
        (\str _ -> Country.codeFromString str)
        Country.codeToString
        decodeDistance
