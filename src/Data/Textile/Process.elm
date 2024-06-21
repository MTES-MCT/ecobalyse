module Data.Textile.Process exposing
    ( Alias(..)
    , Process
    , Uuid(..)
    , decodeFromUuid
    , decodeList
    , encode
    , encodeUuid
    , findByAlias
    , findByUuid
    , getImpact
    , uuidToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import Time exposing (Month(..))


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
    , waste : Unit.Ratio -- share of raw material wasted when initially processed
    , alias : Maybe Alias
    }


type Alias
    = Alias String


type Uuid
    = Uuid String


findByAlias : Alias -> List Process -> Result String Process
findByAlias ((Alias str) as alias) =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ str)


findByUuid : Uuid -> List Process -> Result String Process
findByUuid uuid =
    List.filter (.uuid >> (==) uuid)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ uuidToString uuid)


getImpact : Definition.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


aliasToString : Alias -> String
aliasToString (Alias string) =
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


decode : Decoder Impact.Impacts -> Decoder Process
decode impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "name" Decode.string
        |> Pipe.required "info" Decode.string
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "source" Decode.string
        |> Pipe.required "correctif" Decode.string
        |> Pipe.required "step_usage" Decode.string
        |> Pipe.required "uuid" decodeUuid
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Unit.decodeRatio { percentage = False })
        |> Pipe.required "alias" (Decode.maybe decodeAlias)


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decode impactsDecoder)


decodeUuid : Decoder Uuid
decodeUuid =
    Decode.map Uuid Decode.string


decodeAlias : Decoder Alias
decodeAlias =
    Decode.map Alias Decode.string


encodeAlias : Alias -> Encode.Value
encodeAlias =
    aliasToString >> Encode.string


encodeUuid : Uuid -> Encode.Value
encodeUuid =
    uuidToString >> Encode.string


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "name", Encode.string process.name )
        , ( "info", Encode.string process.info )
        , ( "unit", Encode.string process.unit )
        , ( "source", Encode.string process.source )
        , ( "correctif", Encode.string process.correctif )
        , ( "step_usage", Encode.string process.stepUsage )
        , ( "uuid", encodeUuid process.uuid )
        , ( "impacts", Impact.encode process.impacts )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "elec_pppm", Encode.float process.elec_pppm )
        , ( "elec_MJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "waste", Unit.encodeRatio process.waste )
        , ( "alias", EncodeExtra.maybe encodeAlias process.alias )
        ]
