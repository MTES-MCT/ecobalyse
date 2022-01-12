module Data.Process exposing (..)

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
    , uuid : Uuid
    , impacts : Impacts
    , heat : Energy --  MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process
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
    }


noOpProcess : Process
noOpProcess =
    { name = "void"
    , info = ""
    , uuid = Uuid ""
    , impacts = Impact.noImpacts
    , heat = Energy.megajoules 0
    , elec_pppm = 0
    , elec = Energy.megajoules 0
    , waste = Mass.kilograms 0
    , alias = Nothing
    }


findByUuid : Uuid -> List Process -> Result String Process
findByUuid uuid =
    List.filter (.uuid >> (==) uuid)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ uuidToString uuid)


findByName : String -> List Process -> Result String Process
findByName name =
    List.filter (.name >> (==) name)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par nom: " ++ name)


findByAlias : String -> List Process -> Result String Process
findByAlias alias =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ alias)


getImpact : Impact.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


updateImpact : Impact.Trigram -> Unit.Impact -> Process -> Process
updateImpact trigram value process =
    { process
        | impacts =
            process.impacts
                |> Impact.updateImpact trigram value
    }


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown p =
    Ok WellKnown
        |> RE.andMap (findByAlias "airTransport" p)
        |> RE.andMap (findByAlias "seaTransport" p)
        |> RE.andMap (findByAlias "roadTransportPreMaking" p)
        |> RE.andMap (findByAlias "roadTransportPostMaking" p)
        |> RE.andMap (findByAlias "distribution" p)
        |> RE.andMap (findByAlias "dyeingHigh" p)
        |> RE.andMap (findByAlias "dyeingLow" p)


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
        |> Pipe.required "uuid" (Decode.map Uuid Decode.string)
        |> Pipe.required "impacts" (Impact.decodeImpacts impacts)
        |> Pipe.required "heat" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "alias" (Decode.maybe Decode.string)


decodeList : List Impact.Definition -> Decoder (List Process)
decodeList impacts =
    Decode.list (decode impacts)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "name", Encode.string v.name )
        , ( "info", Encode.string v.name )
        , ( "uuid", v.uuid |> uuidToString |> Encode.string )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "heat", v.heat |> Energy.inMegajoules |> Encode.float )
        , ( "elec_pppm", Encode.float v.elec_pppm )
        , ( "elec", v.elec |> Energy.inMegajoules |> Encode.float )
        , ( "waste", v.waste |> Mass.inKilograms |> Encode.float )
        , ( "alias", v.alias |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


encodeAll : List Process -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
