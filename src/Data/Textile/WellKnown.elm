module Data.Textile.WellKnown exposing
    ( WellKnown
    , getDyeingProcess
    , getEnnoblingHeatProcess
    , getPrintingProcess
    , load
    , weavingElecPPPM
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
    , distribution : Process
    , dyeingArticle : Process
    , dyeingCellulosic : Process
    , dyeingFabric : Process
    , dyeingSynthetic : Process
    , dyeingYarn : Process
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
        fromAlias key =
            RE.andMap (Process.findByAlias (Alias key) processes)
    in
    Ok WellKnown
        |> fromAlias "air-transport"
        |> fromAlias "bleaching"
        |> fromAlias "road-transport"
        |> fromAlias "dyeing-article"
        |> fromAlias "dyeing-cellulosic-fiber"
        |> fromAlias "dyeing-fabric"
        |> fromAlias "dyeing-synthetic-fiber"
        |> fromAlias "dyeing-yarn"
        |> fromAlias "end-of-life"
        |> fromAlias "fading"
        |> fromAlias "finishing"
        |> fromAlias "heat-europe"
        |> fromAlias "heat-row"
        |> fromAlias "knitting-circular"
        |> fromAlias "knitting-fully-fashioned"
        |> fromAlias "knitting-mix"
        |> fromAlias "knitting-seamless"
        |> fromAlias "knitting-straight"
        |> fromAlias "passenger-car"
        |> fromAlias "printing-dyes"
        |> fromAlias "printing-paste"
        |> fromAlias "printing-pigment"
        |> fromAlias "printing-substantive"
        |> fromAlias "road-transport"
        |> fromAlias "sea-transport"
        |> fromAlias "train-transport"
        |> fromAlias "weaving"


weavingElecPPPM : Float
weavingElecPPPM =
    -- kWh/(pick,m) per kg of material to process
    0.0003145
