module Data.Textile.Process exposing
    ( Alias
    , Process
    , Uuid(..)
    , decodeFromUuid
    , decodeList
    , encodeUuid
    , findByAlias
    , findByUuid
    , getImpact
    , uuidToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


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
        |> Pipe.required "waste" (Unit.decodeRatio { percentage = False })
        |> Pipe.required "alias" (Decode.maybe <| Decode.map Alias Decode.string)


decodeList : Definitions -> Decoder (List Process)
decodeList definitions =
    Decode.list (decode definitions)


decodeUuid : Decoder Uuid
decodeUuid =
    Decode.map Uuid Decode.string


encodeUuid : Uuid -> Encode.Value
encodeUuid =
    uuidToString >> Encode.string
