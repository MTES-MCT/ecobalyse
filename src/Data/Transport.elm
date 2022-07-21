module Data.Transport exposing
    ( Distances
    , Transport
    , add
    , codec
    , decodeDistances
    , default
    , defaultInland
    , emptyDistances
    , getTransportBetween
    , roadSeaTransportRatio
    , totalKm
    )

import Codec exposing (Codec)
import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode exposing (Decoder)
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
    AnyDict.fromList Country.codeToString []


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


getTransportBetween : Impacts -> Country.Code -> Country.Code -> Distances -> Transport
getTransportBetween impacts cA cB distances =
    if cA == cB then
        defaultInland impacts

    else
        distances
            |> AnyDict.get cA
            |> Maybe.andThen
                (\countries ->
                    case AnyDict.get cB countries of
                        Just transport ->
                            Just { transport | impacts = impacts }

                        Nothing ->
                            -- reverse query source dict
                            Just (getTransportBetween impacts cB cA distances)
                )
            |> Maybe.withDefault (default impacts)


codec : Codec Transport
codec =
    Codec.object (\road sea air -> Transport road sea air Impact.noImpacts)
        |> Codec.field "road" .road kmCodec
        |> Codec.field "sea" .sea kmCodec
        |> Codec.field "air" .air kmCodec
        |> Codec.buildObject


kmCodec : Codec Length
kmCodec =
    Codec.float
        |> Codec.map Length.kilometers Length.inKilometers
        |> Codec.maybe
        |> Codec.map (Maybe.withDefault Quantity.zero) Just


decodeDistance : Decoder Distance
decodeDistance =
    -- FIXME: Ideally we want to check for available country codes
    AnyDict.decode (\str _ -> Country.codeFromString str)
        Country.codeToString
        (Codec.decoder codec)


decodeDistances : Decoder Distances
decodeDistances =
    -- FIXME: Ideally we want to check for available country codes
    AnyDict.decode (\str _ -> Country.codeFromString str)
        Country.codeToString
        decodeDistance
