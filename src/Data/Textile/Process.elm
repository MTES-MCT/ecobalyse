module Data.Textile.Process exposing
    ( Process
    , Uuid(..)
    , WellKnown
    , decodeFromUuid
    , decodeList
    , encodeUuid
    , findByUuid
    , getDyeingProcess
    , getEnnoblingHeatProcess
    , getImpact
    , getKnittingProcess
    , getPrintingProcess
    , loadWellKnown
    , uuidToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Knitting as Knitting exposing (Knitting)
import Data.Textile.Printing as Printing
import Data.Unit as Unit
import Data.Zone as Zone exposing (Zone)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE


type alias Process =
    { name : String
    , info : String
    , unit : String
    , source : String
    , correctif : String
    , stepUsage : String
    , uuid : Uuid
    , impacts : Impacts
    , heat : Energy --  MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process

    -- FIXME: waste should probably be Unit.Ratio
    , waste : Mass -- kg of textile wasted per kg of material to process
    , alias : Maybe Alias
    }


type Alias
    = Alias String


type Uuid
    = Uuid String


type alias WellKnown =
    { airTransport : Process
    , seaTransport : Process
    , roadTransportPreMaking : Process
    , roadTransportPostMaking : Process
    , distribution : Process
    , dyeingYarn : Process
    , dyeingFabric : Process
    , dyeingArticle : Process
    , knittingMix : Process
    , knittingFullyFashioned : Process
    , knittingSeamless : Process
    , knittingCircular : Process
    , knittingStraight : Process
    , printingPigment : Process
    , printingSubstantive : Process
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
    }


findByAlias : Alias -> List Process -> Result String Process
findByAlias alias =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ aliasToString alias)


findByUuid : Uuid -> List Process -> Result String Process
findByUuid uuid =
    List.filter (.uuid >> (==) uuid)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ uuidToString uuid)


getDyeingProcess : DyeingMedium -> WellKnown -> Process
getDyeingProcess medium { dyeingArticle, dyeingFabric, dyeingYarn } =
    case medium of
        DyeingMedium.Article ->
            dyeingArticle

        DyeingMedium.Fabric ->
            dyeingFabric

        DyeingMedium.Yarn ->
            dyeingYarn


getKnittingProcess : Knitting -> WellKnown -> Process
getKnittingProcess knittingProcess { knittingMix, knittingFullyFashioned, knittingSeamless, knittingCircular, knittingStraight } =
    case knittingProcess of
        Knitting.Mix ->
            knittingMix

        Knitting.FullyFashioned ->
            knittingFullyFashioned

        Knitting.Seamless ->
            knittingSeamless

        Knitting.Circular ->
            knittingCircular

        Knitting.Straight ->
            knittingStraight


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


getPrintingProcess : Printing.Kind -> WellKnown -> Process
getPrintingProcess medium { printingPigment, printingSubstantive } =
    case medium of
        Printing.Pigment ->
            printingPigment

        Printing.Substantive ->
            printingSubstantive


getImpact : Definition.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown processes =
    let
        map =
            { airTransport = "air-transport"
            , seaTransport = "sea-transport"
            , roadTransportPreMaking = "road-transport-pre-making"
            , roadTransportPostMaking = "road-transport-post-making"
            , distribution = "distribution"
            , dyeingYarn = "dyeing-yarn"
            , dyeingFabric = "dyeing-fabric"
            , dyeingArticle = "dyeing-article"
            , printingPigment = "printing-pigment"
            , printingSubstantive = "printing-substantive"
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
            }

        load get =
            RE.andMap (findByAlias (Alias <| get map) processes)
    in
    Ok WellKnown
        |> load .airTransport
        |> load .seaTransport
        |> load .roadTransportPreMaking
        |> load .roadTransportPostMaking
        |> load .distribution
        |> load .dyeingYarn
        |> load .dyeingFabric
        |> load .dyeingArticle
        |> load .knittingMix
        |> load .knittingFullyFashioned
        |> load .knittingSeamless
        |> load .knittingCircular
        |> load .knittingStraight
        |> load .printingPigment
        |> load .printingSubstantive
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


aliasToString : Alias -> String
aliasToString (Alias string) =
    string


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


decodeFromUuid : List Process -> Decoder Process
decodeFromUuid processes =
    Decode.string
        |> Decode.andThen
            (\uuid ->
                processes
                    |> findByUuid (Uuid uuid)
                    |> DecodeExtra.fromResult
            )


decode : Definitions -> Decoder Process
decode definitions =
    Decode.succeed Process
        |> Pipe.required "name" Decode.string
        |> Pipe.required "info" Decode.string
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "source" Decode.string
        |> Pipe.required "correctif" Decode.string
        |> Pipe.required "step_usage" Decode.string
        |> Pipe.required "uuid" decodeUuid
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "alias" (Decode.maybe decodeAlias)


decodeList : Definitions -> Decoder (List Process)
decodeList definitions =
    Decode.list (decode definitions)


decodeUuid : Decoder Uuid
decodeUuid =
    Decode.map Uuid Decode.string


decodeAlias : Decoder Alias
decodeAlias =
    Decode.map Alias Decode.string


encodeUuid : Uuid -> Encode.Value
encodeUuid =
    uuidToString >> Encode.string
