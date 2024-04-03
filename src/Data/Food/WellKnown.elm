module Data.Food.WellKnown exposing
    ( WellKnown
    , load
    , map
    )

import Data.Food.Process as Process exposing (Process)
import Result.Extra as RE


type alias WellKnown =
    { lorryTransport : Process
    , boatTransport : Process
    , planeTransport : Process
    , lorryCoolingTransport : Process
    , boatCoolingTransport : Process
    , water : Process
    , lowVoltageElectricity : Process
    , domesticGasHeat : Process
    }


load : List Process -> Result String WellKnown
load processes =
    let
        resolve id_ =
            RE.andMap (Process.findById processes id_)
    in
    Ok WellKnown
        |> resolve "lorry"
        |> resolve "boat"
        |> resolve "plane"
        |> resolve "lorry-cooling"
        |> resolve "boat-cooling"
        |> resolve "tap-water"
        |> resolve "low-voltage-electricity"
        |> resolve "domestic-gas-heat"


map : (Process -> Process) -> WellKnown -> WellKnown
map update wellKnown =
    { lorryTransport = update wellKnown.lorryTransport
    , boatTransport = update wellKnown.boatTransport
    , planeTransport = update wellKnown.planeTransport
    , lorryCoolingTransport = update wellKnown.lorryCoolingTransport
    , boatCoolingTransport = update wellKnown.boatCoolingTransport
    , water = update wellKnown.water
    , lowVoltageElectricity = update wellKnown.lowVoltageElectricity
    , domesticGasHeat = update wellKnown.domesticGasHeat
    }
