module Data.Transport exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Country as Country
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity


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
    { road : Km, sea : Km, air : Km, co2 : Co2e }


default : Transport
default =
    { road = 0, sea = 0, air = 0 }


emptyDistances : Distances
emptyDistances =
    Dict.fromList Country.codeToString []


defaultSummary : Summary
defaultSummary =
    { road = 0, sea = 0, air = 0, co2 = Co2.kgCo2e 0 }


defaultInland : Transport
defaultInland =
    { road = 500, sea = 0, air = 500 }


addSummary : Summary -> Summary -> Summary
addSummary sA sB =
    { sA
        | road = sA.road + sB.road
        , sea = sA.sea + sB.sea
        , air = sA.air + sB.air
        , co2 = sA.co2 |> Quantity.plus sB.co2
    }


materialToSpinningTransport : Transport
materialToSpinningTransport =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = 2000, sea = 4000, air = 0 }


{-| Determine road/sea transport ratio, so road transport is priviledged
for shorter distances. A few notes:

  - When road distance is 0, we fully take sea distance
  - When sea distance is 0, we fully take road distance
  - Otherwise we can apply specific ratios

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


getTransportBetween : Country.Code -> Country.Code -> Distances -> Transport
getTransportBetween cA cB distances =
    if cA == cB then
        defaultInland

    else
        distances
            |> Dict.get cA
            |> Maybe.andThen
                (\countries ->
                    case Dict.get cB countries of
                        Just transport ->
                            Just transport

                        Nothing ->
                            -- reverse query source dict
                            Just (getTransportBetween cB cA distances)
                )
            |> Maybe.withDefault default


toSummary : Transport -> Summary
toSummary { road, air, sea } =
    { road = road, sea = sea, air = air, co2 = Co2.kgCo2e 0 }


decodeTransport : Decoder Transport
decodeTransport =
    Decode.map3 Transport
        (Decode.field "road" Decode.float)
        (Decode.field "sea" Decode.float)
        (Decode.field "air" Decode.float)


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
        (Decode.field "sea" Decode.float)
        (Decode.field "air" Decode.float)
        (Decode.field "co2" Co2.decodeKgCo2e)


encodeSummary : Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "road", Encode.float summary.road )
        , ( "sea", Encode.float summary.sea )
        , ( "air", Encode.float summary.air )
        , ( "co2", Co2.encodeKgCo2e summary.co2 )
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
