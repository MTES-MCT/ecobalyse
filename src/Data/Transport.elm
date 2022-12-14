module Data.Transport exposing
    ( Distances
    , Transport
    , add
    , decodeDistances
    , default
    , defaultInland
    , emptyDistances
    , encode
    , getTransportBetween
    , roadSeaTransportRatio
    , totalKm
    )

import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
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
    { road : Length
    , sea : Length
    , air : Length
    , impacts : Impacts
    }


default : Impacts -> Transport
default impacts =
    { road = Quantity.zero
    , sea = Quantity.zero
    , air = Quantity.zero
    , impacts = impacts
    }


defaultInland : Impacts -> Transport
defaultInland impacts =
    { road = Length.kilometers 500
    , sea = Quantity.zero
    , air = Length.kilometers 500
    , impacts = impacts
    }


add : Transport -> Transport -> Transport
add a b =
    { b
        | road = b.road |> Quantity.plus a.road
        , sea = b.sea |> Quantity.plus a.sea
        , air = b.air |> Quantity.plus a.air
    }


emptyDistances : Distances
emptyDistances =
    Dict.fromList Country.codeToString []


totalKm : Transport -> Float
totalKm { road, sea, air } =
    Quantity.sum [ road, sea, air ]
        |> Length.inKilometers


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

    else if Length.inKilometers road < 3000 then
        0.25

    else
        0


getTransportBetween :
    Impacts
    -> Country.Code
    -> Country.Code
    -> Distances
    -> Transport
getTransportBetween impacts cA cB distances =
    if cA == cB then
        defaultInland impacts

    else
        distances
            |> Dict.get cA
            |> Maybe.map
                (\countries ->
                    case Dict.get cB countries of
                        Just transport ->
                            { transport | impacts = impacts }

                        Nothing ->
                            -- reverse query source dict
                            getTransportBetween impacts cB cA distances
                )
            |> Maybe.withDefault (default impacts)


decodeKm : Decoder Length
decodeKm =
    Decode.maybe Decode.float
        |> Decode.map (Maybe.map Length.kilometers >> Maybe.withDefault Quantity.zero)


encodeKm : Length -> Encode.Value
encodeKm =
    Length.inKilometers >> Encode.float


decode : Decoder Transport
decode =
    Decode.map4 Transport
        (Decode.field "road" decodeKm)
        (Decode.field "sea" decodeKm)
        (Decode.field "air" decodeKm)
        (Decode.succeed Impact.noImpacts)


encode : List Impact.Definition -> Transport -> Encode.Value
encode definitions v =
    Encode.object
        [ ( "road", encodeKm v.road )
        , ( "sea", encodeKm v.sea )
        , ( "air", encodeKm v.air )
        , ( "impacts", Impact.encodeImpacts definitions Impact.Textile v.impacts )
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
