module Data.Textile.WellKnown exposing
    ( WellKnown
    , getDyeingProcess
    , getEnnoblingHeatProcess
    , getPrintingProcess
    , load
    , weavingElecPPPM
    )

import Data.Country exposing (Country)
import Data.Process as Process exposing (Process)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Printing as Printing
import Data.Zone as Zone
import Result.Extra as RE


type alias WellKnown =
    { airTransport : Process
    , bleaching : Process
    , distribution : Process
    , dyeingArticle : Process
    , dyeingCellulosic : Process
    , dyeingFabric : Process
    , dyeingSynthetic : Process
    , dyeingYarn : Process
    , elecMediumTensionAsia : Process
    , endOfLife : Process
    , fading : Process
    , finishing : Process
    , heatEurope : Process
    , heatRoW : Process
    , knittingCircular : Process
    , knittingFullyFashioned : Process
    , knittingMix : Process
    , knittingSeamless : Process
    , knittingStraight : Process
    , passengerCar : Process
    , printingDyes : Process
    , printingPaste : Process
    , printingPigment : Process
    , printingSubstantive : Process
    , roadTransport : Process
    , seaTransport : Process
    , trainTransport : Process
    , weaving : Process
    }


getDyeingProcess : DyeingMedium -> WellKnown -> Process
getDyeingProcess medium { dyeingArticle, dyeingFabric, dyeingYarn } =
    case medium of
        DyeingMedium.Article ->
            dyeingArticle

        DyeingMedium.Fabric ->
            dyeingFabric

        DyeingMedium.Yarn ->
            dyeingYarn


getEnnoblingHeatProcess : WellKnown -> Country -> Process
getEnnoblingHeatProcess wk country =
    -- Note: As per methodology documentation, retrieve a RER heat source process
    --       for european countries, RSA otherwise.
    case country.zone of
        Zone.Europe ->
            wk.heatEurope

        _ ->
            wk.heatRoW


getPrintingProcess : Printing.Kind -> WellKnown -> { printingProcess : Process, printingToxicityProcess : Process }
getPrintingProcess medium { printingDyes, printingPaste, printingPigment, printingSubstantive } =
    case medium of
        Printing.Pigment ->
            { printingProcess = printingPigment, printingToxicityProcess = printingPaste }

        Printing.Substantive ->
            { printingProcess = printingSubstantive, printingToxicityProcess = printingDyes }


load : List Process -> Result String WellKnown
load processes =
    let
        fromIdString =
            Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
                >> RE.andMap
    in
    Ok WellKnown
        -- air-transport
        |> fromIdString "247ab69c-daa5-4f81-879f-fac0d33880f2"
        -- bleaching
        |> fromIdString "5c92e205-3fc7-4890-839f-a91e2442b7fb"
        -- road-transport
        |> fromIdString "463aa3d1-287e-4d4c-a4ed-78d47600a4b1"
        -- dyeing-article
        |> fromIdString "af54556c-5f74-4f2c-8531-d002eda9d793"
        -- dyeing-cellulosic-fiber
        |> fromIdString "da9d1c32-a166-41ab-bac6-f67aff0cf44a"
        -- dyeing-fabric
        |> fromIdString "03c769d5-46b6-4cf9-80f8-f2712692a6ab"
        -- dyeing-synthetic-fiber
        |> fromIdString "ae9cbbad-7982-4f3c-9220-edf27946d347"
        -- dyeing-yarn
        |> fromIdString "b15afd1b-e7c0-4fbf-9f7b-b2a8b7e74bc7"
        -- elec-medium-region-asia
        |> fromIdString "9c70a439-ee05-4fc4-9598-7448345f7081"
        -- end-of-life
        |> fromIdString "266fa378-77c0-11ec-90d6-0242ac120003"
        -- fading
        |> fromIdString "49adf2a8-c74f-46af-b4c7-e1a8e1f5a6cb"
        -- finishing
        |> fromIdString "63baddae-e05d-404b-a73f-371044a24fe9"
        -- heat-europe
        |> fromIdString "9ad21879-ce00-4d50-b1d8-c719585e24ca"
        -- heat-row
        |> fromIdString "e70b2dc1-41be-4db6-8267-4e9f4822e8bc"
        -- knitting-circular
        |> fromIdString "2e16787c-7a89-4883-acdf-37d3d362bdab"
        -- knitting-fully-fashioned
        |> fromIdString "6524ac1e-cc95-4b5a-b462-2fccad7a0bce"
        -- knitting-mix
        |> fromIdString "9c478d79-ff6b-45e1-9396-c3bd897faa1d"
        -- knitting-seamless
        |> fromIdString "11648b33-f117-4eca-bb09-233c0ad0757f"
        -- knitting-straight
        |> fromIdString "364298ad-2058-4ec4-b2d0-47f5214abffb"
        -- passenger-car
        |> fromIdString "1ead35dd-fc71-4b0c-9410-7e39da95c7dc"
        -- printing-dyes
        |> fromIdString "859a3065-416a-4506-a667-1de480938ba5"
        -- printing-paste
        |> fromIdString "d66055e3-34eb-4343-8192-fb21be40063b"
        -- printing-pigment
        |> fromIdString "710987ca-f483-4f1c-9122-38b620f4062b"
        -- printing-substantive
        |> fromIdString "0810b8e5-a3d9-4607-bccc-83d112573260"
        -- road-transport
        |> fromIdString "463aa3d1-287e-4d4c-a4ed-78d47600a4b1"
        -- sea-transport
        |> fromIdString "b5ae1d24-51ca-4867-b487-abee44e72858"
        -- train-transport
        |> fromIdString "f3735a48-3438-4523-8263-5cb101597d82"
        -- weaving
        |> fromIdString "f9686809-f55e-4b96-b1f0-3298959de7d0"


weavingElecPPPM : Float
weavingElecPPPM =
    -- kWh/(pick,m) per kg of material to process
    0.0003145
