module Data.Textile.Product exposing
    ( FabricOptions(..)
    , Id(..)
    , Product
    , customDaysOfWear
    , decodeList
    , encode
    , fabricOptionsCodec
    , findById
    , getFabricProcess
    , idCodec
    , idToString
    , isKnitted
    )

import Codec exposing (Codec)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Volume exposing (Volume)


type FabricOptions
    = Knitted Process
    | Weaved Process Unit.PickPerMeter Unit.SurfaceMass


type alias MakingOptions =
    { process : Process -- Procédé de Confection
    , fadable : Bool -- Can this product be faded?
    , pcrWaste : Unit.Ratio -- PCR product waste ratio
    }


type alias UseOptions =
    { ironingProcess : Process -- Procédé de repassage
    , nonIroningProcess : Process -- Procédé composite d'utilisation hors-repassage
    , wearsPerCycle : Int -- Nombre de jours porté par cycle d'entretien
    , defaultNbCycles : Int -- Nombre par défaut de cycles d'entretien (not used in computations)
    , ratioDryer : Unit.Ratio -- Ratio de séchage électrique (not used in computations)
    , ratioIroning : Unit.Ratio -- Ratio de repassage (not used in computations)
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
    , fabric : FabricOptions
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

        Weaved process _ _ ->
            process


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id ++ ".")


idCodec : Codec Id
idCodec =
    Codec.string
        |> Codec.map Id idToString


idToString : Id -> String
idToString (Id string) =
    string


isKnitted : Product -> Bool
isKnitted { fabric } =
    case fabric of
        Knitted _ ->
            True

        Weaved _ _ _ ->
            False


fabricOptionsCodec : List Process -> Codec FabricOptions
fabricOptionsCodec processes =
    -- Note: this codec uses classic JSON encoders/decoders because of an issue with data
    -- validation of Maybe values, which would be required here.
    -- see https://github.com/miniBill/elm-codec/issues/14
    -- TL;DR: Be extra careful ensuring bidirectional consistency here.
    Codec.build
        (\v ->
            case v of
                Knitted process ->
                    Encode.object
                        [ ( "processUuid", Process.encodeUuid process.uuid )
                        ]

                Weaved process picking surfaceMass ->
                    Encode.object
                        [ ( "processUuid", Process.encodeUuid process.uuid )
                        , ( "picking", Codec.encoder Unit.pickPerMeterCodec picking )
                        , ( "surfaceMass", Codec.encoder Unit.surfaceMassCodec surfaceMass )
                        ]
        )
        (Decode.field "processUuid" (Process.decodeFromUuid processes)
            |> Decode.andThen
                (\process ->
                    case process.alias of
                        Just "knitting" ->
                            Decode.succeed (Knitted process)

                        Just "knitting-circular" ->
                            Decode.succeed (Knitted process)

                        Just "knitting-rectilinear" ->
                            Decode.succeed (Knitted process)

                        Just "weaving" ->
                            Decode.succeed (Weaved process)
                                |> Pipe.required "picking" (Codec.decoder Unit.pickPerMeterCodec)
                                |> Pipe.required "surfaceMass" (Codec.decoder Unit.surfaceMassCodec)

                        _ ->
                            Decode.fail "Le procédé fourni n'est pas un procédé de production d'étoffe."
                )
        )


makingOptionsCodec : List Process -> Codec MakingOptions
makingOptionsCodec processes =
    Codec.object MakingOptions
        |> Codec.field "processUuid" .process (Process.processUuidCodec processes)
        |> Codec.field "fadable" .fadable Codec.bool
        |> Codec.field "pcrWaste" .pcrWaste Unit.ratioCodec
        |> Codec.buildObject


decodeUseOptions : List Process -> Decoder UseOptions
decodeUseOptions processes =
    Decode.succeed UseOptions
        |> Pipe.required "ironingProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "nonIroningProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "wearsPerCycle" Decode.int
        |> Pipe.required "defaultNbCycles" Decode.int
        |> Pipe.required "ratioDryer" Unit.decodeRatio
        |> Pipe.required "ratioIroning" Unit.decodeRatio
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
        |> Pipe.required "fabric" (Codec.decoder (fabricOptionsCodec processes))
        |> Pipe.required "making" (Codec.decoder (makingOptionsCodec processes))
        |> Pipe.required "use" (decodeUseOptions processes)
        |> Pipe.required "endOfLife" decodeEndOfLifeOptions


decodeList : List Process -> Decoder (List Product)
decodeList processes =
    Decode.list (decode processes)


encodeUseOptions : UseOptions -> Encode.Value
encodeUseOptions v =
    Encode.object
        [ ( "ironingProcessUuid", Process.encodeUuid v.ironingProcess.uuid )
        , ( "nonIroningProcessUuid", Process.encodeUuid v.nonIroningProcess.uuid )
        , ( "wearsPerCycle", Encode.int v.wearsPerCycle )
        , ( "defaultNbCycles", Encode.int v.defaultNbCycles )
        , ( "ratioDryer", Unit.encodeRatio v.ratioDryer )
        , ( "ratioIroning", Unit.encodeRatio v.ratioIroning )
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
        [ ( "id", Codec.encoder idCodec v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "fabric", Codec.encoder (fabricOptionsCodec []) v.fabric )
        , ( "making", Codec.encoder (makingOptionsCodec []) v.making )
        , ( "use", encodeUseOptions v.use )
        , ( "endOfLife", encodeEndOfLifeOptions v.endOfLife )
        ]


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
