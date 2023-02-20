module Data.Food.Retail exposing
    ( Conservation
    , all
    , ambient
    , computeImpacts
    , decode
    , displayNeeds
    , encode
    , fromString
    , toDisplay
    , toString
    )

{- This module allow to compute the impacts of the transport of finished products to the retail stores,
   and the impact of storing the product at the store
-}

import Data.Food.Builder.Db exposing (Db)
import Data.Food.Process exposing (Process, WellKnown)
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Joules, kilowattHours)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity, Rate, rate, ratio)
import Result.Extra as RE
import Volume exposing (CubicMeters, Volume, cubicMeters, liters)


type
    Conservation
    -- A consevation type and its needs in energy, cooling, water and transport
    = Conservation Type Needs


type Type
    = Ambient
    | Fresh
    | Frozen


type alias Needs =
    --- what it needs to store a product at the retail store
    { energy : Quantity Float (Rate Joules CubicMeters)
    , cooling : Quantity Float (Rate Joules CubicMeters)
    , water : Float
    , transport : Length
    }



-- Data table from https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/vente-au-detail


ambient : Conservation
ambient =
    Conservation Ambient
        { energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , cooling = rate (kilowattHours 0) (cubicMeters 1)
        , water = ratio (liters 561.5) (cubicMeters 1)
        , transport = Length.kilometers 600
        }


fresh : Conservation
fresh =
    Conservation Fresh
        { energy = rate (kilowattHours 46.15) (cubicMeters 1)
        , cooling = rate (kilowattHours 219.23) (cubicMeters 1)
        , water = ratio (liters 210.6) (cubicMeters 1)
        , transport = Length.kilometers 600
        }


frozen : Conservation
frozen =
    Conservation Frozen
        { energy = rate (kilowattHours 61.54) (cubicMeters 1)
        , cooling = rate (kilowattHours 415.38) (cubicMeters 1)
        , water = ratio (liters 280.8) (cubicMeters 1)
        , transport = Length.kilometers 600
        }


displayNeeds : Conservation -> String
displayNeeds (Conservation type_ needs) =
    let
        energy =
            needs.energy |> Quantity.in_ (Energy.kilowattHours >> Quantity.per (Volume.cubicMeters 1)) |> String.fromFloat

        cooling =
            needs.cooling |> Quantity.in_ (Energy.kilowattHours >> Quantity.per (Volume.cubicMeters 1)) |> String.fromFloat

        water =
            needs.water / ratio (Volume.liters 1) (Volume.cubicMeters 1) |> String.fromFloat

        transport =
            needs.transport |> Length.inKilometers |> String.fromFloat
    in
    case type_ of
        Ambient ->
            "Énergie: " ++ energy ++ " kWh/m³, Réfrigération: " ++ cooling ++ " kWh/m³, Eau " ++ water ++ " L/m³, Transport: " ++ transport ++ "km"

        Fresh ->
            "Énergie: " ++ energy ++ " kWh/m³, Réfrigération: " ++ cooling ++ " kWh/m³, Eau " ++ water ++ " L/m³, Transpor" ++ transport ++ "km"

        Frozen ->
            "Énergie: " ++ energy ++ " kWh/m³, Réfrigération: " ++ cooling ++ " kWh/m³, Eau " ++ water ++ " L/m³, Transport: " ++ transport ++ "km"


all : List Conservation
all =
    -- for selection list in the builder
    [ ambient, fresh, frozen ]


toString : Conservation -> String
toString (Conservation type_ _) =
    case type_ of
        Ambient ->
            "ambient"

        Fresh ->
            "fresh"

        Frozen ->
            "frozen"


fromString : String -> Result String Conservation
fromString str =
    case str of
        "ambient" ->
            Ok ambient

        "fresh" ->
            Ok fresh

        "frozen" ->
            Ok frozen

        _ ->
            Err <| "Type de conservation inconnue : " ++ str


toDisplay : Conservation -> String
toDisplay (Conservation t _) =
    case t of
        Ambient ->
            "Sec"

        Fresh ->
            "Frais"

        Frozen ->
            "Surgelé"


encode : Conservation -> Encode.Value
encode =
    Encode.string << toString


decode : Decoder Conservation
decode =
    Decode.string
        |> Decode.andThen (fromString >> RE.unpack Decode.fail Decode.succeed)


waterImpact : Float -> Volume -> Process -> Impacts
waterImpact waterNeeds volume =
    .impacts
        >> Impact.mapImpacts
            (\_ impact ->
                impact
                    |> Unit.impactToFloat
                    |> (*) (Quantity.multiplyBy waterNeeds volume |> Volume.inLiters)
                    |> Unit.impact
            )


elecImpact : Quantity Float (Rate Joules CubicMeters) -> Volume -> Process -> Impacts
elecImpact elecNeeds volume =
    .impacts
        >> Impact.mapImpacts
            (\_ impact ->
                impact
                    |> Unit.impactToFloat
                    |> (*) (Quantity.at elecNeeds volume |> Energy.inKilowattHours)
                    |> Unit.impact
            )


transportImpact : Length -> Mass -> Process -> Impacts
transportImpact distance mass =
    .impacts
        >> Impact.mapImpacts
            (\_ impact ->
                impact
                    |> Unit.impactToFloat
                    |> (*) (Length.inKilometers distance * Mass.inMetricTons mass)
                    |> Unit.impact
            )


computeImpacts : Db -> Mass -> Volume -> Conservation -> WellKnown -> Impacts
computeImpacts db mass volume (Conservation _ needs) wellknown =
    [ waterImpact needs.water volume wellknown.water
    , elecImpact needs.cooling volume wellknown.electricity
    , elecImpact needs.energy volume wellknown.electricity
    , transportImpact needs.transport mass wellknown.lorryTransport
    ]
        |> Impact.sumImpacts db.impacts
        |> Impact.updateAggregatedScores db.impacts
