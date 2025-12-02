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
        |> fromIdString "20a62b2c-a543-5076-83aa-c5b7d340206a"
        -- cooking
        |> fromIdString "a2836bb8-7f45-5cfa-bb00-8b38046291cf"
        -- domestic-gas-heat
        |> fromIdString "6cbd45fb-83ff-5852-97a7-87fffecc20f5"
        -- lorry-cooling
        |> fromIdString "219b986c-9751-58cf-977e-7ba8f0b4ae2b"
        -- lorry
        |> fromIdString "46e96f29-9ca5-5475-bb3c-6397f43b7a5b"
        -- low-voltage-electricity
        |> fromIdString "931c9bb0-619a-5f75-b41b-ab8061e2ad92"
        -- plane
        |> fromIdString "326369d9-792a-5ab5-8276-c54108c80cb1"
        -- tap-water
        |> fromIdString "7e1fb122-1320-519c-8751-2d926eb435da"
