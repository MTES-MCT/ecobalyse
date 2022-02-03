module Data.Product exposing
    ( Id(..)
    , Product
    , customDaysOfWear
    , decodeList
    , encode
    , encodeId
    , findById
    , idToString
    )

import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type alias Product =
    { id : Id
    , name : String
    , mass : Mass
    , pcrWaste : Unit.Ratio -- PCR product waste ratio
    , ppm : Int -- pick per meter
    , grammage : Int -- grammes per kg
    , knitted : Bool -- True: Tricotage (Knitting); False: Tissage (Weaving)
    , fabricProcess : Process -- Procédé de Tissage/Tricotage
    , makingProcess : Process -- Procédé de Confection
    , useIroningProcess : Process -- Procédé de repassage
    , useNonIroningProcess : Process -- Procédé composite d'utilisation hors-repassage
    , wearsPerCycle : Int -- Nombre de jours porté par cycle d'entretien

    -- Nombre par défaut de cycles d'entretien
    -- Note: only for information, not used in computations
    , useDefaultNbCycles : Int

    -- Note: only for information, not used in computations
    , useRatioDryer : Unit.Ratio -- Ratio de séchage électrique

    -- Note: only for information, not used in computations
    , useRatioIroning : Unit.Ratio -- Ratio de repassage

    -- Note: only for information, not used in computations
    , useTimeIroning : Duration -- Temps de repassage

    -- Note: only for information, not used in computations
    , daysOfWear : Duration -- Nombre de jour d'utilisation du vêtement (pour qualité=1.0)
    }


type Id
    = Id String


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id ++ ".")


idToString : Id -> String
idToString (Id string) =
    string


decode : List Process -> Decoder Product
decode processes =
    Decode.succeed Product
        |> Pipe.required "id" (Decode.map Id Decode.string)
        |> Pipe.required "name" Decode.string
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "pcrWaste" Unit.decodeRatio
        |> Pipe.required "ppm" Decode.int
        |> Pipe.required "grammage" Decode.int
        |> Pipe.required "knitted" Decode.bool
        |> Pipe.required "fabricProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "makingProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "useIroningProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "useNonIroningProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "useDefaultNbCycles" Decode.int
        |> Pipe.required "wearsPerCycle" Decode.int
        |> Pipe.required "useRatioDryer" Unit.decodeRatio
        |> Pipe.required "useRatioIroning" Unit.decodeRatio
        |> Pipe.required "useTimeIroning" (Decode.map Duration.hours Decode.float)
        |> Pipe.required "daysOfWear" (Decode.map Duration.days Decode.float)


decodeList : List Process -> Decoder (List Product)
decodeList processes =
    Decode.list (decode processes)


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", encodeId v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "pcrWaste", Unit.encodeRatio v.pcrWaste )
        , ( "ppm", Encode.int v.ppm )
        , ( "grammage", Encode.int v.grammage )
        , ( "knitted", Encode.bool v.knitted )
        , ( "fabricProcessUuid", Process.encodeUuid v.makingProcess.uuid )
        , ( "makingProcessUuid", Process.encodeUuid v.makingProcess.uuid )
        , ( "useIroningProcessUuid", Process.encodeUuid v.useIroningProcess.uuid )
        , ( "useNonIroningProcessUuid", Process.encodeUuid v.useNonIroningProcess.uuid )
        , ( "useDefaultNbCycles", Encode.int v.useDefaultNbCycles )
        , ( "wearsPerCycle", Encode.int v.wearsPerCycle )
        , ( "useRatioDryer", Unit.encodeRatio v.useRatioDryer )
        , ( "useRatioIroning", Unit.encodeRatio v.useRatioIroning )
        , ( "useTimeIroning", Encode.float (Duration.inHours v.useTimeIroning) )
        , ( "daysOfWear", Encode.float (Duration.inDays v.daysOfWear) )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


{-| Computes the number of wears and the number of maintainance cycles against a
custom product intrinsic quality coefficient.
-}
customDaysOfWear :
    Maybe Unit.Quality
    -> { product | daysOfWear : Duration, useDefaultNbCycles : Int }
    -> { daysOfWear : Duration, useNbCycles : Int }
customDaysOfWear maybeQuality { daysOfWear, useDefaultNbCycles } =
    let
        quality =
            maybeQuality
                |> Maybe.withDefault Unit.standardQuality

        newDaysOfWear =
            daysOfWear
                |> Quantity.multiplyBy (Unit.qualityToFloat quality)
    in
    { daysOfWear = newDaysOfWear
    , useNbCycles =
        Duration.inDays newDaysOfWear
            / toFloat (clamp 1 useDefaultNbCycles useDefaultNbCycles)
            |> round
    }
