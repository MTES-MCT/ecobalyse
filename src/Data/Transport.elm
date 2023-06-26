module Data.Transport exposing
    ( Distances
    , Transport
    , add
    , addRoadWithCooling
    , computeImpacts
    , decodeDistances
    , default
    , defaultInland
    , emptyDistances
    , encode
    , getTransportBetween
    , roadSeaTransportRatio
    , sum
    , totalKm
    )

import Data.Country as Country
import Data.Food.Process as Process
import Data.Impact as Impact exposing (Impacts)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity


type alias Distance =
    AnyDict String Country.Code Transport


type alias Distances =
    AnyDict String Country.Code Distance


type alias Transport =
    { road : Length
    , roadCooled : Length
    , sea : Length
    , seaCooled : Length
    , air : Length
    , impacts : Impacts
    }


default : Impacts -> Transport
default impacts =
    { road = Quantity.zero
    , roadCooled = Quantity.zero
    , sea = Quantity.zero
    , seaCooled = Quantity.zero
    , air = Quantity.zero
    , impacts = impacts
    }


defaultInland : Scope -> Impacts -> Transport
defaultInland scope impacts =
    { road =
        case scope of
            Scope.Food ->
                Length.kilometers 0

            Scope.Textile ->
                Length.kilometers 500
    , roadCooled = Quantity.zero
    , sea = Quantity.zero
    , seaCooled = Quantity.zero
    , air = Quantity.zero
    , impacts = impacts
    }


add : Transport -> Transport -> Transport
add a b =
    { b
        | road = b.road |> Quantity.plus a.road
        , sea = b.sea |> Quantity.plus a.sea
        , air = b.air |> Quantity.plus a.air
    }


addRoadWithCooling : Length.Length -> Bool -> Transport -> Transport
addRoadWithCooling distance withCooling transport =
    if withCooling then
        { transport | roadCooled = transport.roadCooled |> Quantity.plus distance }

    else
        { transport | road = transport.road |> Quantity.plus distance }


computeImpacts : { a | wellKnown : Process.WellKnown } -> Mass -> Transport -> Transport
computeImpacts { wellKnown } mass transport =
    let
        transportImpacts =
            [ ( wellKnown.lorryTransport, transport.road )
            , ( wellKnown.lorryCoolingTransport, transport.roadCooled )
            , ( wellKnown.boatTransport, transport.sea )
            , ( wellKnown.boatCoolingTransport, transport.seaCooled )
            , ( wellKnown.planeTransport, transport.air )
            ]
                |> List.map
                    (\( transportProcess, distance ) ->
                        transportProcess.impacts
                            |> Impact.mapImpacts
                                (\_ impact ->
                                    impact
                                        |> Unit.impactToFloat
                                        |> (*) (Mass.inMetricTons mass * Length.inKilometers distance)
                                        |> Unit.impact
                                )
                    )
                |> Impact.sumImpacts
    in
    { transport | impacts = transportImpacts }


sum : List Transport -> Transport
sum =
    List.foldl
        (\{ road, roadCooled, sea, seaCooled, air, impacts } acc ->
            { acc
                | road = acc.road |> Quantity.plus road
                , roadCooled = acc.roadCooled |> Quantity.plus roadCooled
                , sea = acc.sea |> Quantity.plus sea
                , seaCooled = acc.seaCooled |> Quantity.plus seaCooled
                , air = acc.air |> Quantity.plus air
                , impacts = Impact.sumImpacts [ acc.impacts, impacts ]
            }
        )
        (default Impact.empty)


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
roadSeaTransportRatio : Transport -> Split
roadSeaTransportRatio { road, sea } =
    if Length.inKilometers road == 0 then
        Split.zero

    else if Length.inKilometers sea == 0 then
        Split.full

    else if Length.inKilometers road <= 500 then
        Split.full

    else if Length.inKilometers road < 1000 then
        -- 0.9
        Split.tenth
            |> Split.complement

    else if Length.inKilometers road < 2000 then
        Split.half

    else if Length.inKilometers road < 3000 then
        Split.quarter

    else
        Split.zero


getTransportBetween :
    Scope
    -> Impacts
    -> Country.Code
    -> Country.Code
    -> Distances
    -> Transport
getTransportBetween scope impacts cA cB distances =
    if cA == cB then
        defaultInland scope impacts

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
                            getTransportBetween scope impacts cB cA distances
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
    Decode.map6 Transport
        (Decode.field "road" decodeKm)
        -- roadCooled
        (Decode.succeed Quantity.zero)
        (Decode.field "sea" decodeKm)
        -- seaCooled
        (Decode.succeed Quantity.zero)
        (Decode.field "air" decodeKm)
        (Decode.succeed Impact.empty)


encode : Transport -> Encode.Value
encode v =
    Encode.object
        [ ( "road", encodeKm v.road )
        , ( "roadCooled", encodeKm v.roadCooled )
        , ( "sea", encodeKm v.sea )
        , ( "seaCooled", encodeKm v.seaCooled )
        , ( "air", encodeKm v.air )
        , ( "impacts", Impact.encodeImpacts Scope.Textile v.impacts )
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
