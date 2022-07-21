module Data.Textile.Process exposing
    ( Process
    , Uuid(..)
    , WellKnown
    , findByUuid
    , getImpact
    , listCodec
    , loadWellKnown
    , processUuidCodec
    )

import Codec exposing (Codec)
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Energy)
import Mass exposing (Mass)
import Result.Extra as RE


type alias Process =
    { name : String
    , info : String
    , unit : String
    , uuid : Uuid
    , impacts : Impacts
    , heat : Energy --  MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process

    -- FIXME: waste should probably be Unit.Ratio
    , waste : Mass -- kg of textile wasted per kg of material to process
    , alias : Maybe String
    }


type Uuid
    = Uuid String


type alias WellKnown =
    { airTransport : Process
    , seaTransport : Process
    , roadTransportPreMaking : Process
    , roadTransportPostMaking : Process
    , distribution : Process
    , dyeingHigh : Process
    , dyeingLow : Process
    , passengerCar : Process
    , endOfLife : Process
    , fading : Process
    }


findByUuid : Uuid -> List Process -> Result String Process
findByUuid uuid =
    List.filter (.uuid >> (==) uuid)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ uuidToString uuid)


findByAlias : String -> List Process -> Result String Process
findByAlias alias =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ alias)


getImpact : Impact.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown processes =
    let
        fromAlias alias =
            RE.andMap (findByAlias alias processes)
    in
    Ok WellKnown
        |> fromAlias "air-transport"
        |> fromAlias "sea-transport"
        |> fromAlias "road-transport-pre-making"
        |> fromAlias "road-transport-post-making"
        |> fromAlias "distribution"
        |> fromAlias "dyeing-high"
        |> fromAlias "dyeing-low"
        |> fromAlias "passenger-car"
        |> fromAlias "end-of-life"
        |> fromAlias "fading"


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


processUuidCodec : List Process -> Codec Process
processUuidCodec processes =
    Codec.string
        |> Codec.andThen
            -- decoder : uuid string -> Process
            (\uuid ->
                case findByUuid (Uuid uuid) processes of
                    Ok process ->
                        Codec.succeed process

                    Err error ->
                        Codec.fail error
            )
            -- encoder : Process -> uuid string
            (.uuid >> uuidToString)


codec : List Impact.Definition -> Codec Process
codec definitions =
    Codec.object Process
        |> Codec.field "name" .name Codec.string
        |> Codec.field "info" .info Codec.string
        |> Codec.field "unit" .unit Codec.string
        |> Codec.field "uuid" .uuid uuidCodec
        |> Codec.field "impacts" .impacts (Impact.impactsCodec definitions)
        |> Codec.field "heat_MJ" .heat (Codec.map Energy.megajoules Energy.inMegajoules Codec.float)
        |> Codec.field "elec_pppm" .elec_pppm Codec.float
        |> Codec.field "elec_MJ" .elec (Codec.map Energy.megajoules Energy.inMegajoules Codec.float)
        |> Codec.field "waste" .waste (Codec.map Mass.kilograms Mass.inKilograms Codec.float)
        |> Codec.field "alias" .alias (Codec.maybe Codec.string)
        |> Codec.buildObject


uuidCodec : Codec Uuid
uuidCodec =
    Codec.string
        |> Codec.map Uuid uuidToString


listCodec : List Impact.Definition -> Codec (List Process)
listCodec impacts =
    Codec.list (codec impacts)
