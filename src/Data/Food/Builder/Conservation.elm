module Data.Food.Builder.Conservation exposing (..)

{- This module allow to compute the impacts of the transport of finished products to the retail stores,
   and the impact of storing the product at the store
-}

import Data.Food.Builder.Db exposing (Db)
import Data.Food.Process as Process
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Joules, inKilowattHours, kilowattHours)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity, Rate, rate, ratio)
import Result.Extra as RE
import Volume exposing (CubicMeters, cubicMeters, liters)


type alias Needs =
    --- what it needs to store a product at the retail store
    { energy : Quantity Float (Rate Joules CubicMeters)
    , cooling : Quantity Float (Rate Joules CubicMeters)
    , water : Float
    }


type Type
    = Ambient Needs
    | Chilled Needs
    | Frozen Needs


type alias Query =
    -- TODO remove ?
    { type_ : Type
    }


type alias Conservation =
    -- TODO remove ?
    { type_ : Type
    }



-- Data table from https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/vente-au-detail


ambient : Type
ambient =
    Ambient
        { energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , cooling = rate (kilowattHours 0) (cubicMeters 1)
        , water = ratio (liters 561.5) (cubicMeters 1)
        }


chilled : Type
chilled =
    Chilled
        { energy = rate (kilowattHours 61.54) (cubicMeters 1)
        , cooling = rate (kilowattHours 415.38) (cubicMeters 1)
        , water = ratio (liters 280.8) (cubicMeters 1)
        }


frozen : Type
frozen =
    Frozen
        { energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , cooling = rate (kilowattHours 0) (cubicMeters 1)
        , water = ratio (liters 561.5) (cubicMeters 1)
        }


all : List Type
all =
    -- for selection list in the builder
    [ ambient, chilled, frozen ]


toString : Type -> String
toString t =
    case t of
        Ambient _ ->
            "ambient"

        Chilled _ ->
            "frais"

        Frozen _ ->
            "frozen"


fromString : String -> Result String Type
fromString str =
    case str of
        "ambient" ->
            Ok ambient

        "chilled" ->
            Ok chilled

        "frozen" ->
            Ok frozen

        _ ->
            Err "Type de conservation incorrect"


toDisplay : Type -> String
toDisplay t =
    case t of
        Ambient _ ->
            "Sec"

        Chilled _ ->
            "Frais"

        Frozen _ ->
            "Surgelé"


encodeQuery : Query -> Encode.Value
encodeQuery c =
    Encode.object
        [ ( "type", encodeType c.type_ )
        ]


encodeType : Type -> Encode.Value
encodeType =
    Encode.string << toString


decodeQuery : Decoder Query
decodeQuery =
    Decode.map Query
        (Decode.field "type" decodeType)


decodeType : Decoder Type
decodeType =
    Decode.string
        |> Decode.andThen (fromString >> RE.unpack Decode.fail Decode.succeed)


fromQuery : Db -> Maybe Query -> Result String (Maybe Type)
fromQuery { processes } mquery =
    mquery
        |> Maybe.map .type_
        |> Ok


waterImpact : Float -> Quantity Float CubicMeters -> Impacts -> Impacts
waterImpact waterNeeds volume unitImpacts =
    unitImpacts
        |> Impact.mapImpacts
            (\_ impact ->
                impact
                    |> Unit.impactToFloat
                    |> (*) (Quantity.multiplyBy waterNeeds volume |> Volume.inCubicMeters)
                    |> Unit.impact
            )


elecImpact : Quantity Float (Rate Joules CubicMeters) -> Quantity Float CubicMeters -> Impacts -> Impacts
elecImpact elecNeeds volume unitImpacts =
    unitImpacts
        |> Impact.mapImpacts
            (\_ impact ->
                impact
                    |> Unit.impactToFloat
                    |> (*) (Quantity.at elecNeeds volume |> Energy.inJoules)
                    |> Unit.impact
            )


extractNeeds : Type -> Needs
extractNeeds type_ =
    case type_ of
        Ambient needs ->
            needs

        Chilled needs ->
            needs

        Frozen needs ->
            needs


waterUnitImpact : Db -> Impacts
waterUnitImpact db =
    Process.codeFromString "224411d9aa3c0ed3cf9b5fc590c237d2" |> Process.findByCode db.processes |> Result.map .impacts |> Result.withDefault Impact.noImpacts


elecUnitImpact : Db -> Impacts
elecUnitImpact db =
    Process.codeFromString "ef953c00d48ee59f57773534f6487b09" |> Process.findByCode db.processes |> Result.map .impacts |> Result.withDefault Impact.noImpacts


impacts : Db -> Needs -> Quantity Float CubicMeters -> Impacts
impacts db needs volume =
    [ waterImpact needs.water volume (waterUnitImpact db)
    , elecImpact needs.cooling volume (elecUnitImpact db)
    , elecImpact needs.energy volume (elecUnitImpact db)
    ]
        |> Impact.sumImpacts db.impacts
        |> Impact.updateAggregatedScores db.impacts


computeImpacts : Db -> Quantity Float CubicMeters -> Type -> Impacts
computeImpacts db volume conservation =
    impacts db (extractNeeds conservation) volume
