module Data.Transport exposing
    ( Distance
    , Distances
    , Transport
    , add
    , addRoadWithCooling
    , applyTransportRatios
    , computeImpacts
    , decode
    , decodeDistances
    , default
    , encode
    , getTransportBetween
    , sum
    , totalKm
    )

import Data.Country as Country
import Data.Food.WellKnown exposing (WellKnown)
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Dict.Any as Dict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity


type alias Distance =
    AnyDict String Country.Code Transport


type alias Distances =
    AnyDict String Country.Code Distance


type alias Transport =
    { air : Length
    , impacts : Impacts
    , road : Length
    , roadCooled : Length
    , sea : Length
    , seaCooled : Length
    }


default : Impacts -> Transport
default impacts =
    { air = Quantity.zero
    , impacts = impacts
    , road = Quantity.zero
    , roadCooled = Quantity.zero
    , sea = Quantity.zero
    , seaCooled = Quantity.zero
    }


erroneous : Impacts -> Transport
erroneous impacts =
    -- FIXME temporary data to display something weird instead of zero, until
    -- we use of a Result String Transport in the transport computations
    { air = Quantity.infinity
    , impacts = impacts
    , road = Quantity.infinity
    , roadCooled = Quantity.infinity
    , sea = Quantity.infinity
    , seaCooled = Quantity.infinity
    }


add : Transport -> Transport -> Transport
add a b =
    { b
        | air = b.air |> Quantity.plus a.air
        , road = b.road |> Quantity.plus a.road
        , sea = b.sea |> Quantity.plus a.sea
    }


addRoadWithCooling : Length.Length -> Bool -> Transport -> Transport
addRoadWithCooling distance withCooling transport =
    if withCooling then
        { transport | roadCooled = transport.roadCooled |> Quantity.plus distance }

    else
        { transport | road = transport.road |> Quantity.plus distance }


{-| Applies transportation modes distribution strategies (see methodology docs and the
`roadSeaTransportRatio` function in this modules)
-}
applyTransportRatios : Split -> Transport -> Transport
applyTransportRatios airTransportRatio ({ air, road, sea } as transport) =
    let
        nonAirTransportRatio =
            Split.complement airTransportRatio

        roadRatio =
            roadSeaTransportRatio transport

        seaRatio =
            Split.complement roadRatio
    in
    { transport
        | air = air |> Quantity.multiplyBy (Split.toFloat airTransportRatio)
        , road = road |> Quantity.multiplyBy (Split.apply (Split.toFloat roadRatio) nonAirTransportRatio)
        , sea = sea |> Quantity.multiplyBy (Split.apply (Split.toFloat seaRatio) nonAirTransportRatio)
    }


computeImpacts : WellKnown -> Mass -> Transport -> Transport
computeImpacts wellKnown mass transport =
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
        (\{ air, impacts, road, roadCooled, sea, seaCooled } acc ->
            { acc
                | air = acc.air |> Quantity.plus air
                , impacts = Impact.sumImpacts [ acc.impacts, impacts ]
                , road = acc.road |> Quantity.plus road
                , roadCooled = acc.roadCooled |> Quantity.plus roadCooled
                , sea = acc.sea |> Quantity.plus sea
                , seaCooled = acc.seaCooled |> Quantity.plus seaCooled
            }
        )
        (default Impact.empty)


totalKm : Transport -> Float
totalKm { air, road, sea } =
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
    Impacts
    -> Country.Code
    -> Country.Code
    -> Distances
    -> Transport
getTransportBetween impacts cA cB distances =
    case
        ( distances |> Dict.get cA |> Maybe.andThen (Dict.get cB)
        , distances |> Dict.get cB |> Maybe.andThen (Dict.get cA)
        )
    of
        ( Just transport, _ ) ->
            { transport | impacts = impacts }

        ( _, Just transport ) ->
            { transport | impacts = impacts }

        ( Nothing, Nothing ) ->
            erroneous impacts


decodeKm : Decoder Length
decodeKm =
    Decode.maybe Decode.float
        |> Decode.map (Maybe.map Length.kilometers >> Maybe.withDefault Quantity.zero)


encodeKm : Length -> Encode.Value
encodeKm =
    Length.inKilometers >> Encode.float


decode : Decoder Transport
decode =
    Decode.succeed Transport
        |> Decode.required "air" decodeKm
        |> Decode.hardcoded Impact.empty
        |> Decode.required "road" decodeKm
        -- roadCooled
        |> Decode.hardcoded Quantity.zero
        |> Decode.required "sea" decodeKm
        -- seaCooled
        |> Decode.hardcoded Quantity.zero


encode : Transport -> Encode.Value
encode v =
    Encode.object
        [ ( "air", encodeKm v.air )
        , ( "impacts", Impact.encode v.impacts )
        , ( "road", encodeKm v.road )
        , ( "roadCooled", encodeKm v.roadCooled )
        , ( "sea", encodeKm v.sea )
        , ( "seaCooled", encodeKm v.seaCooled )
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
