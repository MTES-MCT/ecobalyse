module Data.Food.Retail exposing
    ( Distribution
    , all
    , ambient
    , computeImpacts
    , decode
    , displayNeeds
    , distributionTransport
    , encode
    , fromString
    , toDisplay
    , toString
    )

{- This module allow to compute the impacts of the transport of finished products to the retail stores,
   and the impact of storing the product at the store
-}

import Data.Food.WellKnown exposing (WellKnown)
import Data.Impact as Impact exposing (Impacts)
import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Joules, kilowattHours)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Length exposing (Length)
import Quantity exposing (Quantity, Rate, rate, ratio)
import Volume exposing (CubicMeters, Volume, cubicMeters, liters)


type
    Distribution
    -- A distribution type and its needs
    -- in energy, cooling, water and transport
    = Distribution Type Needs


type Type
    = Ambient
    | Fresh
    | Frozen


type alias Needs =
    --- what it needs to store a product at the retail store
    { cooling : Quantity Float (Rate Joules CubicMeters)
    , energy : Quantity Float (Rate Joules CubicMeters)
    , transport : Length
    , water : Float
    }



-- Data table from https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/vente-au-detail


ambient : Distribution
ambient =
    Distribution Ambient
        { cooling = rate (kilowattHours 0) (cubicMeters 1)
        , energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , transport = Length.kilometers 600
        , water = ratio (liters 561.5) (cubicMeters 1)
        }


fresh : Distribution
fresh =
    Distribution Fresh
        { cooling = rate (kilowattHours 219.23) (cubicMeters 1)
        , energy = rate (kilowattHours 46.15) (cubicMeters 1)
        , transport = Length.kilometers 600
        , water = ratio (liters 210.6) (cubicMeters 1)
        }


frozen : Distribution
frozen =
    Distribution Frozen
        { cooling = rate (kilowattHours 415.38) (cubicMeters 1)
        , energy = rate (kilowattHours 61.54) (cubicMeters 1)
        , transport = Length.kilometers 600
        , water = ratio (liters 280.8) (cubicMeters 1)
        }


displayNeeds : Distribution -> String
displayNeeds (Distribution _ needs) =
    let
        energy =
            needs.energy |> Quantity.in_ (Energy.kilowattHours >> Quantity.per (Volume.cubicMeters 1)) |> String.fromFloat

        cooling =
            needs.cooling |> Quantity.in_ (Energy.kilowattHours >> Quantity.per (Volume.cubicMeters 1)) |> String.fromFloat

        water =
            needs.water / ratio (Volume.liters 1) (Volume.cubicMeters 1) |> String.fromFloat
    in
    "Énergie: " ++ energy ++ " kWh/m³, Réfrigération: " ++ cooling ++ " kWh/m³, Eau " ++ water ++ " L/m³"


all : List Distribution
all =
    -- for selection list in the recipe builder
    [ ambient, fresh, frozen ]


toString : Distribution -> String
toString (Distribution type_ _) =
    case type_ of
        Ambient ->
            "ambient"

        Fresh ->
            "fresh"

        Frozen ->
            "frozen"


fromString : String -> Result String Distribution
fromString str =
    case str of
        "ambient" ->
            Ok ambient

        "fresh" ->
            Ok fresh

        "frozen" ->
            Ok frozen

        _ ->
            Err <| "Choix invalide pour la distribution : " ++ str


toDisplay : Distribution -> String
toDisplay (Distribution t _) =
    case t of
        Ambient ->
            "Sec"

        Fresh ->
            "Frais"

        Frozen ->
            "Surgelé"


encode : Distribution -> Encode.Value
encode =
    Encode.string << toString


decode : Decoder Distribution
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


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


distributionTransport : Distribution -> Bool -> Transport
distributionTransport (Distribution _ needs) needsCooling =
    Transport.default Impact.empty
        |> Transport.addRoadWithCooling needs.transport needsCooling


computeImpacts : Volume -> Distribution -> WellKnown -> Impacts
computeImpacts volume (Distribution _ needs) wellknown =
    [ waterImpact needs.water volume wellknown.water
    , elecImpact needs.cooling volume wellknown.lowVoltageElectricity
    , elecImpact needs.energy volume wellknown.lowVoltageElectricity
    ]
        |> Impact.sumImpacts
