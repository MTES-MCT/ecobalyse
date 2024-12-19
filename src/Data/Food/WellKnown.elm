module Data.Food.WellKnown exposing
    ( WellKnown
    , load
    )

import Data.Process as Process exposing (Process)
import Result.Extra as RE


type alias WellKnown =
    { boatCoolingTransport : Process
    , boatTransport : Process
    , domesticGasHeat : Process
    , lorryCoolingTransport : Process
    , lorryTransport : Process
    , lowVoltageElectricity : Process
    , planeTransport : Process
    , water : Process
    }


load : List Process -> Result String WellKnown
load processes =
    let
        resolve alias =
            RE.andMap (Process.findByAlias alias processes)
    in
    Ok WellKnown
        |> resolve "boat-cooling"
        |> resolve "boat"
        |> resolve "domestic-gas-heat"
        |> resolve "lorry-cooling"
        |> resolve "lorry"
        |> resolve "low-voltage-electricity"
        |> resolve "plane"
        |> resolve "tap-water"
