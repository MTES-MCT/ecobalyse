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
        fromIdString =
            Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
                >> RE.andMap
    in
    Ok WellKnown
        -- boat-cooling
        |> fromIdString "c739cf97-d424-5abd-b6ad-4c21d66081bb"
        -- boat
        |> fromIdString "54145f9e-1a8e-5a69-96d9-d3b92f9a1cee"
        -- domestic-gas-heat
        |> fromIdString "a21ee9bf-675f-502b-a9a3-395686a429e0"
        -- lorry-cooling
        |> fromIdString "a79eb385-fa19-590c-8e3b-16f6048c4303"
        -- lorry
        |> fromIdString "1f30553d-df08-5f07-b035-ba3ce5af7cf1"
        -- low-voltage-electricity
        |> fromIdString "931c9bb0-619a-5f75-b41b-ab8061e2ad92"
        -- plane
        |> fromIdString "c8bca164-5574-5232-84b9-46c5b734cd0c"
        -- tap-water
        |> fromIdString "d3fc19a4-7ace-5870-aeb3-fe35a8189d94"
