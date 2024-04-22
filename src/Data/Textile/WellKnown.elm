module Data.Textile.WellKnown exposing
    ( WellKnown
    , getDyeingProcess
    , getEnnoblingHeatProcess
    , getPrintingProcess
    , load
    , map
    )

import Data.Country exposing (Country)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Printing as Printing
import Data.Textile.Process as Process exposing (Alias(..), Process)
import Data.Zone as Zone
import Result.Extra as RE


type alias WellKnown =
    { airTransport : Process
    , bleaching : Process
    , seaTransport : Process
    , roadTransport : Process
    , trainTransport : Process
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
    , heatEurope : Process
    , heatRoW : Process
    , weaving : Process
    , scouring : Process
    , mercerising : Process
    , washing : Process
    , desizing : Process
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
getPrintingProcess medium { printingPigment, printingSubstantive, printingDyes, printingPaste } =
    case medium of
        Printing.Pigment ->
            { printingProcess = printingPigment, printingToxicityProcess = printingPaste }

        Printing.Substantive ->
            { printingProcess = printingSubstantive, printingToxicityProcess = printingDyes }


load : List Process -> Result String WellKnown
load processes =
    let
        mapping =
            { airTransport = "air-transport"
            , bleaching = "bleaching"
            , seaTransport = "sea-transport"
            , roadTransport = "road-transport"
            , trainTransport = "train-transport"
            , distribution = "road-transport"
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
            , heatEurope = "heat-europe"
            , heatRoW = "heat-row"
            , knittingMix = "knitting-mix"
            , knittingFullyFashioned = "knitting-fully-fashioned"
            , knittingSeamless = "knitting-seamless"
            , knittingCircular = "knitting-circular"
            , knittingStraight = "knitting-straight"
            , weaving = "weaving"
            , scouring = "scouring"
            , mercerising = "mercerising"
            , washing = "washing"
            , desizing = "desizing"
            }

        find get =
            RE.andMap (Process.findByAlias (Alias <| get mapping) processes)
    in
    Ok WellKnown
        |> find .airTransport
        |> find .bleaching
        |> find .seaTransport
        |> find .roadTransport
        |> find .trainTransport
        |> find .distribution
        |> find .dyeingYarn
        |> find .dyeingFabric
        |> find .dyeingArticle
        |> find .dyeingSynthetic
        |> find .dyeingCellulosic
        |> find .knittingMix
        |> find .knittingFullyFashioned
        |> find .knittingSeamless
        |> find .knittingCircular
        |> find .knittingStraight
        |> find .printingPigment
        |> find .printingSubstantive
        |> find .printingPaste
        |> find .printingDyes
        |> find .finishing
        |> find .passengerCar
        |> find .endOfLife
        |> find .fading
        |> find .heatEurope
        |> find .heatRoW
        |> find .weaving
        |> find .scouring
        |> find .mercerising
        |> find .washing
        |> find .desizing


map : (Process -> Process) -> WellKnown -> WellKnown
map update wellKnown =
    { airTransport = update wellKnown.airTransport
    , bleaching = update wellKnown.bleaching
    , seaTransport = update wellKnown.seaTransport
    , roadTransport = update wellKnown.roadTransport
    , trainTransport = update wellKnown.trainTransport
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
    , heatEurope = update wellKnown.heatEurope
    , heatRoW = update wellKnown.heatRoW
    , knittingMix = update wellKnown.knittingMix
    , knittingFullyFashioned = update wellKnown.knittingFullyFashioned
    , knittingSeamless = update wellKnown.knittingSeamless
    , knittingCircular = update wellKnown.knittingCircular
    , knittingStraight = update wellKnown.knittingStraight
    , weaving = update wellKnown.weaving
    , scouring = update wellKnown.scouring
    , mercerising = update wellKnown.mercerising
    , washing = update wellKnown.washing
    , desizing = update wellKnown.desizing
    }
