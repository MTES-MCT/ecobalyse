module Data.Textile.Product exposing
    ( FabricOptions(..)
    , Id(..)
    , Product
    , customDaysOfWear
    , decodeList
    , encode
    , encodeId
    , findById
    , getFabricProcess
    , getMakingDurationInMinutes
    , idToString
    , isKnitted
    , makingComplexityToString
    )

import Data.Split as Split exposing (Split)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Volume exposing (Volume)


type alias DyeingOptions =
    { defaultMedium : DyeingMedium
    }


type FabricOptions
    = Knitted Process
    | Weaved Process


type MakingComplexity
    = High
    | Medium
    | Low


type alias MakingOptions =
    { process : Process -- Procédé de Confection
    , fadable : Bool -- Can this product be faded?
    , pcrWaste : Split -- PCR product waste ratio
    , complexity : MakingComplexity -- How complex is this making
    , durationInMinutes : Duration -- How long does it take
    }


type alias UseOptions =
    { ironingProcess : Process -- Procédé de repassage
    , nonIroningProcess : Process -- Procédé composite d'utilisation hors-repassage
    , wearsPerCycle : Int -- Nombre de jours porté par cycle d'entretien
    , defaultNbCycles : Int -- Nombre par défaut de cycles d'entretien (not used in computations)
    , ratioDryer : Split -- Ratio de séchage électrique (not used in computations)
    , ratioIroning : Split -- Ratio de repassage (not used in computations)
    , timeIroning : Duration -- Temps de repassage (not used in computations)
    , daysOfWear : Duration -- Nombre de jour d'utilisation du vêtement (pour qualité=1.0) (not used in computations)
    }


type alias EndOfLifeOptions =
    { volume : Volume
    }


type alias Product =
    { id : Id
    , name : String
    , mass : Mass
    , surfaceMass : Unit.SurfaceMass
    , yarnSize : Maybe Unit.YarnSize
    , fabric : FabricOptions
    , dyeing : DyeingOptions
    , making : MakingOptions
    , use : UseOptions
    , endOfLife : EndOfLifeOptions
    }


type Id
    = Id String


getFabricProcess : Product -> Process
getFabricProcess { fabric } =
    case fabric of
        Knitted process ->
            process

        Weaved process ->
            process


makingComplexityToString : MakingComplexity -> String
makingComplexityToString makingComplexity =
    case makingComplexity of
        High ->
            "Elevée"

        Medium ->
            "Moyenne"

        Low ->
            "Faible"


getMakingDurationInMinutes : Product -> Duration
getMakingDurationInMinutes =
    .making >> .durationInMinutes


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id ++ ".")


idToString : Id -> String
idToString (Id string) =
    string


isKnitted : Product -> Bool
isKnitted { fabric } =
    case fabric of
        Knitted _ ->
            True

        Weaved _ ->
            False


decodeFabricOptions : List Process -> Decoder FabricOptions
decodeFabricOptions processes =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\str ->
                case String.toLower str of
                    "knitting" ->
                        Decode.succeed Knitted
                            |> Pipe.required "processUuid" (Process.decodeFromUuid processes)

                    "weaving" ->
                        Decode.succeed Weaved
                            |> Pipe.required "processUuid" (Process.decodeFromUuid processes)

                    _ ->
                        Decode.fail ("Type de production d'étoffe inconnu\u{00A0}: " ++ str)
            )


decodeDyeingOptions : Decoder DyeingOptions
decodeDyeingOptions =
    Decode.map DyeingOptions
        (Decode.field "defaultMedium" DyeingMedium.decode)


decodeMakingComplexity : Decoder MakingComplexity
decodeMakingComplexity =
    Decode.string
        |> Decode.andThen
            (\complexityStr ->
                case complexityStr of
                    "high" ->
                        Decode.succeed High

                    "medium" ->
                        Decode.succeed Medium

                    "low" ->
                        Decode.succeed Low

                    str ->
                        Decode.fail ("Type de complexité de fabrication inconnu\u{00A0}: " ++ str)
            )


decodeMakingOptions : List Process -> Decoder MakingOptions
decodeMakingOptions processes =
    Decode.succeed MakingOptions
        |> Pipe.required "processUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "fadable" Decode.bool
        |> Pipe.required "pcrWaste" Split.decodeFloat
        |> Pipe.required "complexity" decodeMakingComplexity
        |> Pipe.required "durationInMinutes" (Decode.int |> Decode.map toFloat |> Decode.map Duration.minutes)


decodeUseOptions : List Process -> Decoder UseOptions
decodeUseOptions processes =
    Decode.succeed UseOptions
        |> Pipe.required "ironingProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "nonIroningProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "wearsPerCycle" Decode.int
        |> Pipe.required "defaultNbCycles" Decode.int
        |> Pipe.required "ratioDryer" Split.decodeFloat
        |> Pipe.required "ratioIroning" Split.decodeFloat
        |> Pipe.required "timeIroning" (Decode.map Duration.hours Decode.float)
        |> Pipe.required "daysOfWear" (Decode.map Duration.days Decode.float)


decodeEndOfLifeOptions : Decoder EndOfLifeOptions
decodeEndOfLifeOptions =
    Decode.succeed EndOfLifeOptions
        |> Pipe.required "volume" (Decode.map Volume.cubicMeters Decode.float)


decode : List Process -> Decoder Product
decode processes =
    Decode.succeed Product
        |> Pipe.required "id" (Decode.map Id Decode.string)
        |> Pipe.required "name" Decode.string
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "surfaceMass" Unit.decodeSurfaceMass
        |> Pipe.required "yarnSize" (Decode.maybe Unit.decodeYarnSize)
        |> Pipe.required "fabric" (decodeFabricOptions processes)
        |> Pipe.required "dyeing" decodeDyeingOptions
        |> Pipe.required "making" (decodeMakingOptions processes)
        |> Pipe.required "use" (decodeUseOptions processes)
        |> Pipe.required "endOfLife" decodeEndOfLifeOptions


decodeList : List Process -> Decoder (List Product)
decodeList processes =
    Decode.list (decode processes)


encodeFabricOptions : FabricOptions -> Encode.Value
encodeFabricOptions v =
    case v of
        Knitted process ->
            Encode.object
                [ ( "type", Encode.string "knitting" )
                , ( "processUuid", Process.encodeUuid process.uuid )
                ]

        Weaved process ->
            Encode.object
                [ ( "type", Encode.string "weaving" )
                , ( "processUuid", Process.encodeUuid process.uuid )
                ]


encodeMakingOptions : MakingOptions -> Encode.Value
encodeMakingOptions v =
    Encode.object
        [ ( "processUuid", Process.encodeUuid v.process.uuid )
        , ( "fadable", Encode.bool v.fadable )
        , ( "pcrWaste", Split.encodeFloat v.pcrWaste )
        , ( "complexity", Encode.string (makingComplexityToString v.complexity) )
        , ( "durationInMinutes", Duration.inMinutes v.durationInMinutes |> round |> Encode.int )
        ]


encodeUseOptions : UseOptions -> Encode.Value
encodeUseOptions v =
    Encode.object
        [ ( "ironingProcessUuid", Process.encodeUuid v.ironingProcess.uuid )
        , ( "nonIroningProcessUuid", Process.encodeUuid v.nonIroningProcess.uuid )
        , ( "wearsPerCycle", Encode.int v.wearsPerCycle )
        , ( "defaultNbCycles", Encode.int v.defaultNbCycles )
        , ( "ratioDryer", Split.encodeFloat v.ratioDryer )
        , ( "ratioIroning", Split.encodeFloat v.ratioIroning )
        , ( "timeIroning", Encode.float (Duration.inHours v.timeIroning) )
        , ( "daysOfWear", Encode.float (Duration.inDays v.daysOfWear) )
        ]


encodeEndOfLifeOptions : EndOfLifeOptions -> Encode.Value
encodeEndOfLifeOptions v =
    Encode.object
        [ ( "volume", v.volume |> Volume.inCubicMeters |> Encode.float ) ]


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", encodeId v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "fabric", encodeFabricOptions v.fabric )
        , ( "making", encodeMakingOptions v.making )
        , ( "use", encodeUseOptions v.use )
        , ( "endOfLife", encodeEndOfLifeOptions v.endOfLife )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


{-| Computes the number of wears and the number of maintainance cycles against
quality and reparability coefficients.
-}
customDaysOfWear :
    Maybe Unit.Quality
    -> Maybe Unit.Reparability
    -> { productOptions | daysOfWear : Duration, wearsPerCycle : Int }
    -> { daysOfWear : Duration, useNbCycles : Int }
customDaysOfWear maybeQuality maybeReparability { daysOfWear, wearsPerCycle } =
    let
        ( quality, reparability ) =
            ( maybeQuality |> Maybe.withDefault Unit.standardQuality
            , maybeReparability |> Maybe.withDefault Unit.standardReparability
            )

        newDaysOfWear =
            daysOfWear
                |> Quantity.multiplyBy (Unit.qualityToFloat quality)
                |> Quantity.multiplyBy (Unit.reparabilityToFloat reparability)
    in
    { daysOfWear = newDaysOfWear
    , useNbCycles =
        Duration.inDays newDaysOfWear
            / toFloat (clamp 1 wearsPerCycle wearsPerCycle)
            |> round
    }
