module Data.Textile.Product exposing
    ( FabricOptions(..)
    , Id(..)
    , Product
    , codec
    , customDaysOfWear
    , fabricOptionsCodec
    , findById
    , getFabricProcess
    , idCodec
    , idToString
    , isKnitted
    , listCodec
    )

import Codec exposing (Codec)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode
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
                            Decode.map2 (Weaved process)
                                (Decode.field "picking" (Codec.decoder Unit.pickPerMeterCodec))
                                (Decode.field "surfaceMass" (Codec.decoder Unit.surfaceMassCodec))

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


useOptionsCodec : List Process -> Codec UseOptions
useOptionsCodec processes =
    Codec.object UseOptions
        |> Codec.field "ironingProcessUuid" .ironingProcess (Process.processUuidCodec processes)
        |> Codec.field "nonIroningProcessUuid" .nonIroningProcess (Process.processUuidCodec processes)
        |> Codec.field "wearsPerCycle" .wearsPerCycle Codec.int
        |> Codec.field "defaultNbCycles" .defaultNbCycles Codec.int
        |> Codec.field "ratioDryer" .ratioDryer Unit.ratioCodec
        |> Codec.field "ratioIroning" .ratioIroning Unit.ratioCodec
        |> Codec.field "timeIroning" .timeIroning (Codec.map Duration.hours Duration.inHours Codec.float)
        |> Codec.field "daysOfWear" .daysOfWear (Codec.map Duration.days Duration.inDays Codec.float)
        |> Codec.buildObject


endOfLifeOptionsCodec : Codec EndOfLifeOptions
endOfLifeOptionsCodec =
    Codec.object EndOfLifeOptions
        |> Codec.field "volume" .volume (Codec.map Volume.cubicMeters Volume.inCubicMeters Codec.float)
        |> Codec.buildObject


codec : List Process -> Codec Product
codec processes =
    Codec.object Product
        |> Codec.field "id" .id idCodec
        |> Codec.field "name" .name Codec.string
        |> Codec.field "mass" .mass (Codec.map Mass.kilograms Mass.inKilograms Codec.float)
        |> Codec.field "fabric" .fabric (fabricOptionsCodec processes)
        |> Codec.field "making" .making (makingOptionsCodec processes)
        |> Codec.field "use" .use (useOptionsCodec processes)
        |> Codec.field "endOfLife" .endOfLife endOfLifeOptionsCodec
        |> Codec.buildObject


listCodec : List Process -> Codec (List Product)
listCodec processes =
    Codec.list (codec processes)


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
