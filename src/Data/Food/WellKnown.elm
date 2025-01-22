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
        |> fromIdString "8f1efc54-b468-4ab8-9ea6-ef533bf74be5"
        -- boat
        |> fromIdString "247b42b9-d629-4006-86a4-4c255f5b8e4b"
        -- domestic-gas-heat
        |> fromIdString "63bb1a62-15d9-4a56-82f3-c42ab92c31ae"
        -- lorry-cooling
        |> fromIdString "da60057d-d42c-4892-84fe-a802f294821d"
        -- lorry
        |> fromIdString "a938b45f-688d-4265-b6af-c11a9fa91c36"
        -- low-voltage-electricity
        |> fromIdString "a094f56a-ae26-469a-8639-c2f447919eb6"
        -- plane
        |> fromIdString "3bb59715-9944-4512-ae71-232109c83794"
        -- tap-water
        |> fromIdString "36b3ffec-51e7-4e26-b1b5-7d52554e0aa6"
