module Data.Food.WellKnown exposing
    ( WellKnown
    , load
    )

import Data.Process as Process exposing (Process)
import Result.Extra as RE


type alias WellKnown =
    { boatCoolingTransport : Process
    , boatTransport : Process
    , cooking : Process
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
        fromIdString =
            Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
                >> RE.andMap
    in
    Ok WellKnown
        -- boat-cooling
        |> fromIdString "3cb99d44-24f6-5f6e-a8f8-f754fe44d641"
        -- boat
        |> fromIdString "0c36759c-4480-53eb-add1-77ecfb2b202e"
        -- cooking
        |> fromIdString "a2836bb8-7f45-5cfa-bb00-8b38046291cf"
        -- domestic-gas-heat
        |> fromIdString "6cbd45fb-83ff-5852-97a7-87fffecc20f5"
        -- lorry-cooling
        |> fromIdString "219b986c-9751-58cf-977e-7ba8f0b4ae2b"
        -- lorry
        |> fromIdString "0a3b3388-472c-58e5-9d1b-441cdda023f3"
        -- low-voltage-electricity
        |> fromIdString "931c9bb0-619a-5f75-b41b-ab8061e2ad92"
        -- plane
        |> fromIdString "3364ef93-b936-531a-8f5a-432349aef398"
        -- tap-water
        |> fromIdString "7e1fb122-1320-519c-8751-2d926eb435da"
