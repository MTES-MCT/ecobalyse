module Data.Process exposing
    ( Process
    , Uuid(..)
    , WellKnown
    , decodeFromUuid
    , decodeList
    , encodeUuid
    , getImpact
    , loadWellKnown
    , uuidToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
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
    , naturalSpinning : Process
    , syntheticSpinning : Process
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
        |> fromAlias "spinning-natural"
        |> fromAlias "spinning-synthetic"


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


decode : List Impact.Definition -> Decoder Process
decode impacts =
    Decode.succeed Process
        |> Pipe.required "name" Decode.string
        |> Pipe.required "info" Decode.string
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "uuid" (Decode.map Uuid Decode.string)
        |> Pipe.required "impacts" (Impact.decodeImpacts impacts)
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "alias" (Decode.maybe Decode.string)


decodeList : List Impact.Definition -> Decoder (List Process)
decodeList impacts =
    Decode.list (decode impacts)


encodeUuid : Uuid -> Encode.Value
encodeUuid =
    uuidToString >> Encode.string
