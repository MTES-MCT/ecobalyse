module Data.Textile.WellKnown exposing
    ( getDyeingProcess
    , getEnnoblingHeatProcess
    , getPrintingProcess
    , loadWellKnown
    , mapWellKnown
    )

import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Printing as Printing
import Data.Textile.Process as Process exposing (Process)
import Data.Zone as Zone exposing (Zone)
import Result.Extra as RE


type alias WellKnown =
    { airTransport : Process
    , bleaching : Process
    , seaTransport : Process
    , roadTransportPreMaking : Process
    , roadTransportPostMaking : Process
    , distribution : Process
    , dyeingYarn : Process
    , dyeingFabric : Process
    , dyeingArticle : Process
    , dyeingSynthetic : Process
    , dyeingCellulosic : Process
    , knittingMix : Process
    , knittingFullyFashioned : Process
    , knittingSeamless : Process
    , knittingCircular : Process
    , knittingStraight : Process
    , printingPigment : Process
    , printingSubstantive : Process
    , printingPaste : Process
    , printingDyes : Process
    , finishing : Process
    , passengerCar : Process
    , endOfLife : Process
    , fading : Process
    , steamGasRER : Process
    , steamGasRSA : Process
    , steamLightFuelRER : Process
    , steamLightFuelRSA : Process
    , steamHeavyFuelRER : Process
    , steamHeavyFuelRSA : Process
    , steamCoalRER : Process
    , steamCoalRSA : Process
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


getEnnoblingHeatProcess : WellKnown -> Zone -> HeatSource -> Process
getEnnoblingHeatProcess wk zone heatSource =
    -- Note: As per methodology documentation, retrieve a RER heat source process
    --       for european countries, RSA otherwise.
    case ( zone, heatSource ) of
        ( Zone.Europe, HeatSource.Coal ) ->
            wk.steamCoalRER

        ( Zone.Europe, HeatSource.NaturalGas ) ->
            wk.steamGasRER

        ( Zone.Europe, HeatSource.HeavyFuel ) ->
            wk.steamHeavyFuelRER

        ( Zone.Europe, HeatSource.LightFuel ) ->
            wk.steamLightFuelRER

        ( _, HeatSource.Coal ) ->
            wk.steamCoalRSA

        ( _, HeatSource.NaturalGas ) ->
            wk.steamGasRSA

        ( _, HeatSource.HeavyFuel ) ->
            wk.steamHeavyFuelRSA

        ( _, HeatSource.LightFuel ) ->
            wk.steamLightFuelRSA


getPrintingProcess : Printing.Kind -> WellKnown -> { printingProcess : Process, printingToxicityProcess : Process }
getPrintingProcess medium { printingPigment, printingSubstantive, printingDyes, printingPaste } =
    case medium of
        Printing.Pigment ->
            { printingProcess = printingPigment, printingToxicityProcess = printingPaste }

        Printing.Substantive ->
            { printingProcess = printingSubstantive, printingToxicityProcess = printingDyes }


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown processes =
    let
        map =
            { airTransport = "air-transport"
            , bleaching = "bleaching"
            , seaTransport = "sea-transport"
            , roadTransportPreMaking = "road-transport-pre-making"
            , roadTransportPostMaking = "road-transport-post-making"
            , distribution = "distribution"
            , dyeingYarn = "dyeing-yarn"
            , dyeingFabric = "dyeing-fabric"
            , dyeingArticle = "dyeing-article"
            , dyeingSynthetic = "dyeing-synthetic-fiber"
            , dyeingCellulosic = "dyeing-cellulosic-fiber"
            , printingPigment = "printing-pigment"
            , printingSubstantive = "printing-substantive"
            , printingPaste = "printing-paste"
            , printingDyes = "printing-dyes"
            , finishing = "finishing"
            , passengerCar = "passenger-car"
            , endOfLife = "end-of-life"
            , fading = "fading"
            , steamGasRER = "steam-gas-rer"
            , steamGasRSA = "steam-gas-rsa"
            , steamLightFuelRER = "steam-light-fuel-rer"
            , steamLightFuelRSA = "steam-light-fuel-rsa"
            , steamHeavyFuelRER = "steam-heavy-fuel-rer"
            , steamHeavyFuelRSA = "steam-heavy-fuel-rsa"
            , steamCoalRER = "steam-coal-rer"
            , steamCoalRSA = "steam-coal-rsa"
            , knittingMix = "knitting-mix"
            , knittingFullyFashioned = "knitting-fully-fashioned"
            , knittingSeamless = "knitting-seamless"
            , knittingCircular = "knitting-circular"
            , knittingStraight = "knitting-straight"
            , weaving = "weaving"
            }

        load get =
            RE.andMap (Process.findByAlias (get map) processes)
    in
    Ok WellKnown
        |> load .airTransport
        |> load .bleaching
        |> load .seaTransport
        |> load .roadTransportPreMaking
        |> load .roadTransportPostMaking
        |> load .distribution
        |> load .dyeingYarn
        |> load .dyeingFabric
        |> load .dyeingArticle
        |> load .dyeingSynthetic
        |> load .dyeingCellulosic
        |> load .knittingMix
        |> load .knittingFullyFashioned
        |> load .knittingSeamless
        |> load .knittingCircular
        |> load .knittingStraight
        |> load .printingPigment
        |> load .printingSubstantive
        |> load .printingPaste
        |> load .printingDyes
        |> load .finishing
        |> load .passengerCar
        |> load .endOfLife
        |> load .fading
        |> load .steamGasRER
        |> load .steamGasRSA
        |> load .steamLightFuelRER
        |> load .steamLightFuelRSA
        |> load .steamHeavyFuelRER
        |> load .steamHeavyFuelRSA
        |> load .steamCoalRER
        |> load .steamCoalRSA
        |> load .weaving


mapWellKnown : (Process -> Process) -> WellKnown -> WellKnown
mapWellKnown update wellKnown =
    { airTransport = update wellKnown.airTransport
    , bleaching = update wellKnown.bleaching
    , seaTransport = update wellKnown.seaTransport
    , roadTransportPreMaking = update wellKnown.roadTransportPreMaking
    , roadTransportPostMaking = update wellKnown.roadTransportPostMaking
    , distribution = update wellKnown.distribution
    , dyeingYarn = update wellKnown.dyeingYarn
    , dyeingFabric = update wellKnown.dyeingFabric
    , dyeingArticle = update wellKnown.dyeingArticle
    , dyeingSynthetic = update wellKnown.dyeingSynthetic
    , dyeingCellulosic = update wellKnown.dyeingCellulosic
    , printingPigment = update wellKnown.printingPigment
    , printingSubstantive = update wellKnown.printingSubstantive
    , printingPaste = update wellKnown.printingPaste
    , printingDyes = update wellKnown.printingDyes
    , finishing = update wellKnown.finishing
    , passengerCar = update wellKnown.passengerCar
    , endOfLife = update wellKnown.endOfLife
    , fading = update wellKnown.fading
    , steamGasRER = update wellKnown.steamGasRER
    , steamGasRSA = update wellKnown.steamGasRSA
    , steamLightFuelRER = update wellKnown.steamLightFuelRER
    , steamLightFuelRSA = update wellKnown.steamLightFuelRSA
    , steamHeavyFuelRER = update wellKnown.steamHeavyFuelRER
    , steamHeavyFuelRSA = update wellKnown.steamHeavyFuelRSA
    , steamCoalRER = update wellKnown.steamCoalRER
    , steamCoalRSA = update wellKnown.steamCoalRSA
    , knittingMix = update wellKnown.knittingMix
    , knittingFullyFashioned = update wellKnown.knittingFullyFashioned
    , knittingSeamless = update wellKnown.knittingSeamless
    , knittingCircular = update wellKnown.knittingCircular
    , knittingStraight = update wellKnown.knittingStraight
    , weaving = update wellKnown.weaving
    }
