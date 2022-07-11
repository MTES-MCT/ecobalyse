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
import Volume exposing (Volume)


type alias Product =
    { id : Id
    , name : String
    , mass : Mass

    -- Fabric step specific options
    , fabricProcess : Process -- Procédé de Tissage/Tricotage
    , knitted : Bool -- True: Tricotage (Knitting); False: Tissage (Weaving)
    , picking : Unit.PickPerMeter -- Duitage: pick/m (picks per meter)
    , surfaceMass : Unit.SurfaceMass -- Grammage: gr/m² par kg de produit

    -- Making step specific options
    , makingProcess : Process -- Procédé de Confection
    , fadable : Bool -- Can this product be faded?
    , pcrWaste : Unit.Ratio -- PCR product waste ratio

    -- Use step specific options
    , useIroningProcess : Process -- Procédé de repassage
    , useNonIroningProcess : Process -- Procédé composite d'utilisation hors-repassage
    , wearsPerCycle : Int -- Nombre de jours porté par cycle d'entretien
    , useDefaultNbCycles : Int -- Nombre par défaut de cycles d'entretien (not used in computations)
    , useRatioDryer : Unit.Ratio -- Ratio de séchage électrique (not used in computations)
    , useRatioIroning : Unit.Ratio -- Ratio de repassage (not used in computations)
    , useTimeIroning : Duration -- Temps de repassage (not used in computations)
    , daysOfWear : Duration -- Nombre de jour d'utilisation du vêtement (pour qualité=1.0) (not used in computations)

    -- End of Life step specific options
    , volume : Volume
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
        |> Pipe.requiredAt [ "fabric", "processUuid" ] (Process.decodeFromUuid processes)
        |> Pipe.requiredAt [ "fabric", "type" ]
            (Decode.string
                |> Decode.andThen
                    (\str ->
                        case String.toLower str of
                            "weaving" ->
                                Decode.succeed False

                            "knitting" ->
                                Decode.succeed True

                            _ ->
                                Decode.fail ("Type de production d'étoffe inconnu\u{00A0}: " ++ str)
                    )
            )
        |> Pipe.optionalAt [ "fabric", "picking" ] Unit.decodePickPerMeter (Unit.pickPerMeter 0)
        |> Pipe.optionalAt [ "fabric", "surfaceMass" ] Unit.decodeSurfaceMass (Unit.surfaceMass 0)
        |> Pipe.requiredAt [ "making", "processUuid" ] (Process.decodeFromUuid processes)
        |> Pipe.optionalAt [ "making", "fadable" ] Decode.bool False
        |> Pipe.requiredAt [ "making", "pcrWaste" ] Unit.decodeRatio
        |> Pipe.requiredAt [ "use", "ironingProcessUuid" ] (Process.decodeFromUuid processes)
        |> Pipe.requiredAt [ "use", "nonIroningProcessUuid" ] (Process.decodeFromUuid processes)
        |> Pipe.requiredAt [ "use", "wearsPerCycle" ] Decode.int
        |> Pipe.requiredAt [ "use", "defaultNbCycles" ] Decode.int
        |> Pipe.requiredAt [ "use", "ratioDryer" ] Unit.decodeRatio
        |> Pipe.requiredAt [ "use", "ratioIroning" ] Unit.decodeRatio
        |> Pipe.requiredAt [ "use", "timeIroning" ] (Decode.map Duration.hours Decode.float)
        |> Pipe.requiredAt [ "use", "daysOfWear" ] (Decode.map Duration.days Decode.float)
        |> Pipe.requiredAt [ "endOfLife", "volume" ] (Decode.map Volume.cubicMeters Decode.float)


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
        , ( "picking", Unit.encodePickPerMeter v.picking )
        , ( "surfaceMass", Unit.encodeSurfaceMass v.surfaceMass )
        , ( "knitted", Encode.bool v.knitted )
        , ( "fadable", Encode.bool v.fadable )
        , ( "fabricProcessUuid", Process.encodeUuid v.makingProcess.uuid )
        , ( "makingProcessUuid", Process.encodeUuid v.makingProcess.uuid )
        , ( "useIroningProcessUuid", Process.encodeUuid v.useIroningProcess.uuid )
        , ( "useNonIroningProcessUuid", Process.encodeUuid v.useNonIroningProcess.uuid )
        , ( "wearsPerCycle", Encode.int v.wearsPerCycle )
        , ( "volume", Encode.float (Volume.inCubicMeters v.volume) )
        , ( "useDefaultNbCycles", Encode.int v.useDefaultNbCycles )
        , ( "useRatioDryer", Unit.encodeRatio v.useRatioDryer )
        , ( "useRatioIroning", Unit.encodeRatio v.useRatioIroning )
        , ( "useTimeIroning", Encode.float (Duration.inHours v.useTimeIroning) )
        , ( "daysOfWear", Encode.float (Duration.inDays v.daysOfWear) )
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
    -> { product | daysOfWear : Duration, wearsPerCycle : Int }
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
