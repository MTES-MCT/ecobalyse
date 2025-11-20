module Data.Textile.WellKnown exposing
    ( WellKnown
    , getEnnoblingHeatProcess
    , getEnnoblingPreTreatments
    , getPrintingProcess
    , load
    , weavingElecPPPM
    )

import Data.GeoZone exposing (GeoZone)
import Data.Process as Process exposing (Process)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Textile.Printing as Printing
import Data.WorldRegion as WorldRegion
import Result.Extra as RE


type alias WellKnown =
    { airTransport : Process
    , bleaching : Process
    , degreasing : Process
    , distribution : Process
    , dyeingCellulosic : Process
    , dyeingProcessAverage : Process
    , dyeingProcessContinuous : Process
    , dyeingProcessDiscontinuous : Process
    , dyeingSynthetic : Process
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
    , lowVoltageFranceElec : Process
    , passengerCar : Process
    , printingDyes : Process
    , printingPaste : Process
    , printingPigment : Process
    , printingSubstantive : Process
    , roadTransport : Process
    , seaTransport : Process
    , trainTransport : Process
    , washingSyntheticFibers : Process
    , weaving : Process
    }


getEnnoblingHeatProcess : WellKnown -> GeoZone -> Process
getEnnoblingHeatProcess wk geoZone =
    -- Note: As per methodology documentation, retrieve a RER heat source process
    --       for european countries, RSA otherwise.
    case geoZone.worldRegion of
        WorldRegion.Europe ->
            wk.heatEurope

        _ ->
            wk.heatRoW


getEnnoblingPreTreatments : Origin -> WellKnown -> List Process
getEnnoblingPreTreatments origin { bleaching, degreasing, washingSyntheticFibers } =
    case origin of
        Origin.ArtificialFromOrganic ->
            [ bleaching ]

        Origin.NaturalFromAnimal ->
            [ bleaching, degreasing ]

        Origin.NaturalFromVegetal ->
            [ bleaching, degreasing ]

        Origin.Synthetic ->
            [ washingSyntheticFibers ]


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
        -- airTransport
        |> fromIdString "326369d9-792a-5ab5-8276-c54108c80cb1"
        -- bleaching
        |> fromIdString "b4251621-1747-526a-a54f-e4be7500efff"
        -- degreasing
        |> fromIdString "1746b5e1-1d0d-5858-a968-2ade8d778623"
        -- distribution
        |> fromIdString "46e96f29-9ca5-5475-bb3c-6397f43b7a5b"
        -- dyeingCellulosic
        |> fromIdString "c49a5379-95c4-599a-84da-b5faaa345b97"
        -- dyeingProcessAverage
        |> fromIdString "b7fa51fc-0421-57b0-bb0a-e0573e293c7a"
        -- dyeingProcessContinuous
        |> fromIdString "c8be445c-ae33-5240-9007-e7973e97fc24"
        -- dyeingProcessDiscontinuous
        |> fromIdString "7e17b44d-108a-504f-9e0d-0cfe5b5db054"
        -- dyeingSynthetic
        |> fromIdString "e5e43c57-bd12-5ab7-8a22-7d12cdcece58"
        -- elecMediumTensionAsia
        |> fromIdString "a2129ece-5dd9-5e66-969c-2603b3c97244"
        -- endOfLife
        |> fromIdString "ab96b73f-8534-59ad-9f34-a579abe3b023"
        -- fading
        |> fromIdString "24edc372-b238-5426-8ac9-059218936641"
        -- finishing
        |> fromIdString "3c66588d-fffb-55cb-b9d5-c197b7e2e591"
        -- heatEurope
        |> fromIdString "f6ea2983-e024-5de2-b323-273f2436deba"
        -- heatRoW
        |> fromIdString "3561ace1-f710-50ce-a69c-9cf842e729e4"
        -- knittingCircular
        |> fromIdString "ddcf4b23-1283-57d3-854b-be3121452d50"
        -- knittingFullyFashioned
        |> fromIdString "66ef36be-7691-5adc-a684-e83d45e53452"
        -- knittingMix
        |> fromIdString "29dc6c73-8d82-5056-8ac0-faf212bc0367"
        -- knittingSeamless
        |> fromIdString "b2dba726-83d2-55b2-8107-91c9e47bdca7"
        -- knittingStraight
        |> fromIdString "8343adad-0350-5895-a701-4db41a235ba9"
        -- lowVoltageFranceElec
        |> fromIdString "931c9bb0-619a-5f75-b41b-ab8061e2ad92"
        -- passengerCar
        |> fromIdString "2fd6b74f-600a-577c-ba37-b84d8f0482c2"
        -- printingDyes
        |> fromIdString "cfdc5e31-25fc-56ff-9a54-04670ecad301"
        -- printingPaste
        |> fromIdString "97c209ec-7782-5a29-8c47-af7f17c82d11"
        -- printingPigment
        |> fromIdString "9418bfb4-34e5-5bba-920f-b50e2feff1bd"
        -- printingSubstantive
        |> fromIdString "5c21e378-b941-57f7-98c9-67345847dbda"
        -- roadTransport
        |> fromIdString "46e96f29-9ca5-5475-bb3c-6397f43b7a5b"
        -- seaTransport
        |> fromIdString "20a62b2c-a543-5076-83aa-c5b7d340206a"
        -- trainTransport
        |> fromIdString "cdc841c2-493f-56d6-8fc2-ae5fad2a4917"
        -- washingSyntheticFibers
        |> fromIdString "7cdc9616-7fb4-5a69-9436-78e5b84ebf31"
        -- weaving
        |> fromIdString "235b3488-6157-50ed-b74a-45e5d447dd85"


weavingElecPPPM : Float
weavingElecPPPM =
    -- kWh/(pick,m) per kg of material to process
    0.0003145
