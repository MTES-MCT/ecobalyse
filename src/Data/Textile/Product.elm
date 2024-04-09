module Data.Textile.Product exposing
    ( Id(..)
    , Product
    , customDaysOfWear
    , decodeList
    , encode
    , encodeId
    , findById
    , getMakingDurationInMinutes
    , idToString
    , isFadedByDefault
    )

import Data.Split as Split exposing (Split)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Economics as Economics exposing (Economics)
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Volume exposing (Volume)


type alias DyeingOptions =
    { defaultMedium : DyeingMedium
    }


type alias MakingOptions =
    { pcrWaste : Split -- PCR product waste ratio
    , complexity : MakingComplexity -- How complex is this making
    }


type alias UseOptions =
    { ironingElec : Energy -- Quantitié d'éléctricité mobilisée pour repasser une pièce
    , nonIroningProcess : Process -- Procédé composite d'utilisation hors-repassage
    , wearsPerCycle : Int -- Nombre de jours porté par cycle d'entretien
    , defaultNbCycles : Int -- Nombre par défaut de cycles d'entretien (not used in computations)
    , ratioDryer : Split -- Ratio de séchage électrique (not used in computations)
    , ratioIroning : Split -- Ratio de repassage (not used in computations)
    , timeIroning : Duration -- Temps de repassage (not used in computations)
    , daysOfWear : Duration -- Nombre de jour d'utilisation du vêtement (not used in computations)
    }


type alias EndOfLifeOptions =
    { volume : Volume
    }


type alias Product =
    { id : Id
    , name : String
    , mass : Mass
    , surfaceMass : Unit.SurfaceMass
    , yarnSize : Unit.YarnSize
    , fabric : Fabric
    , economics : Economics
    , dyeing : DyeingOptions
    , making : MakingOptions
    , use : UseOptions
    , endOfLife : EndOfLifeOptions
    }


type Id
    = Id String


isFadedByDefault : Product -> Bool
isFadedByDefault product =
    product.id == Id "jean"


getMakingDurationInMinutes : Product -> Duration
getMakingDurationInMinutes =
    .making
        >> .complexity
        >> MakingComplexity.toDuration


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id ++ ".")


idToString : Id -> String
idToString (Id string) =
    string


decodeDyeingOptions : Decoder DyeingOptions
decodeDyeingOptions =
    Decode.map DyeingOptions
        (Decode.field "defaultMedium" DyeingMedium.decode)


decodeMakingOptions : Decoder MakingOptions
decodeMakingOptions =
    Decode.succeed MakingOptions
        |> Pipe.required "pcrWaste" Split.decodeFloat
        |> Pipe.required "complexity" MakingComplexity.decode


decodeUseOptions : List Process -> Decoder UseOptions
decodeUseOptions processes =
    Decode.succeed UseOptions
        |> Pipe.required "ironingElecInMJ" (Decode.map Energy.megajoules Decode.float)
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
        |> Pipe.required "yarnSize" Unit.decodeYarnSize
        |> Pipe.required "fabric" Fabric.decode
        |> Pipe.required "economics" Economics.decode
        |> Pipe.required "dyeing" decodeDyeingOptions
        |> Pipe.required "making" decodeMakingOptions
        |> Pipe.required "use" (decodeUseOptions processes)
        |> Pipe.required "endOfLife" decodeEndOfLifeOptions


decodeList : List Process -> Decoder (List Product)
decodeList processes =
    Decode.list (decode processes)


encodeMakingOptions : MakingOptions -> Encode.Value
encodeMakingOptions v =
    Encode.object
        [ ( "pcrWaste", Split.encodeFloat v.pcrWaste )
        , ( "complexity", Encode.string (MakingComplexity.toString v.complexity) )
        ]


encodeUseOptions : UseOptions -> Encode.Value
encodeUseOptions v =
    Encode.object
        [ ( "nonIroningProcessUuid", Process.encodeUuid v.nonIroningProcess.uuid )
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
        , ( "fabric", Fabric.encode v.fabric )
        , ( "making", encodeMakingOptions v.making )
        , ( "use", encodeUseOptions v.use )
        , ( "endOfLife", encodeEndOfLifeOptions v.endOfLife )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


{-| Computes the number of maintainance cycles.
-}
customDaysOfWear : { productOptions | daysOfWear : Duration, wearsPerCycle : Int } -> Int
customDaysOfWear { daysOfWear, wearsPerCycle } =
    Duration.inDays daysOfWear
        / toFloat (clamp 1 wearsPerCycle wearsPerCycle)
        |> round
