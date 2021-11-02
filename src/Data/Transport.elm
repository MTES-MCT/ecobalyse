module Data.Transport exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Country as Country
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Quantity


type alias Distance =
    AnyDict String Country.Code Transport


type alias Distances =
    AnyDict String Country.Code Distance


type alias Transport =
    { road : Length, sea : Length, air : Length, co2 : Co2e }


default : Transport
default =
    { road = Quantity.zero
    , sea = Quantity.zero
    , air = Quantity.zero
    , co2 = Quantity.zero
    }


emptyDistances : Distances
emptyDistances =
    Dict.fromList Country.codeToString []


defaultInland : Transport
defaultInland =
    { road = Length.kilometers 500
    , sea = Quantity.zero
    , air = Length.kilometers 500
    , co2 = Quantity.zero
    }


add : Transport -> Transport -> Transport
add sA sB =
    { sA
        | road = sA.road |> Quantity.plus sB.road
        , sea = sA.sea |> Quantity.plus sB.sea
        , air = sA.air |> Quantity.plus sB.air
        , co2 = sA.co2 |> Quantity.plus sB.co2
    }


materialToSpinningTransport : Transport
materialToSpinningTransport =
    -- Note: used as the defaults for the initial Material&Spinning step
    { road = Length.kilometers 2000
    , sea = Length.kilometers 4000
    , air = Length.kilometers 0
    , co2 = Quantity.zero
    }


{-| Determine road/sea transport ratio, so road transport is priviledged
for shorter distances. A few notes:

  - When road distance is 0, we fully take sea distance
  - When sea distance is 0, we fully take road distance
  - Otherwise we can apply specific ratios

-}
roadSeaTransportRatio : Transport -> Float
roadSeaTransportRatio { road, sea } =
    if Length.inKilometers road == 0 then
        0

    else if Length.inKilometers sea == 0 then
        1

    else if Length.inKilometers road <= 500 then
        1

    else if Length.inKilometers road < 1000 then
        0.9

    else if Length.inKilometers road < 2000 then
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


decodeKm : Decoder Length
decodeKm =
    Decode.float |> Decode.andThen (Length.kilometers >> Decode.succeed)


encodeKm : Length -> Encode.Value
encodeKm =
    Length.inKilometers >> Encode.float


decode : Decoder Transport
decode =
    Decode.map4 Transport
        (Decode.field "road" decodeKm)
        (Decode.field "sea" decodeKm)
        (Decode.field "air" decodeKm)
        (Decode.succeed Quantity.zero)


encode : Transport -> Encode.Value
encode v =
    Encode.object
        [ ( "road", encodeKm v.road )
        , ( "sea", encodeKm v.sea )
        , ( "air", encodeKm v.air )
        , ( "co2", Co2.encodeKgCo2e v.co2 )
        ]


decodeDistance : Decoder Distance
decodeDistance =
    -- FIXME: Ideally we want to check for available country codes
    Dict.decode
        (\str _ -> Country.codeFromString str)
        Country.codeToString
        decode


decodeDistances : Decoder Distances
decodeDistances =
    -- FIXME: Ideally we want to check for available country codes
    Dict.decode
        (\str _ -> Country.codeFromString str)
        Country.codeToString
        decodeDistance
