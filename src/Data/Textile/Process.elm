module Data.Textile.Process exposing
    ( Alias(..)
    , Id
    , Process
    , decodeFromId
    , decodeList
    , encode
    , encodeId
    , findByAlias
    , findById
    , getDisplayName
    , getImpact
    , idFromString
    , idToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra


type alias Process =
    { alias : Maybe Alias
    , categories : List String
    , comment : String
    , density : Float
    , displayName : Maybe String
    , elec : Energy -- MJ per kg of material to process
    , heat : Energy --  MJ per kg of material to process
    , id : Id
    , impacts : Impacts
    , name : String
    , source : String
    , unit : String
    , waste : Split -- share of raw material wasted when initially processed
    }


type Alias
    = Alias String


type Id
    = Id Uuid


findByAlias : Alias -> List Process -> Result String Process
findByAlias ((Alias str) as alias) =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ str)


findById : Id -> List Process -> Result String Process
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ idToString id)


getImpact : Definition.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


aliasToString : Alias -> String
aliasToString (Alias string) =
    string


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decode : Decoder Impact.Impacts -> Decoder Process
decode impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "alias" (Decode.maybe decodeAlias)
        |> Pipe.required "categories" (Decode.list Decode.string)
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "density" Decode.float
        |> Pipe.optional "displayName" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "name" Decode.string
        |> Pipe.required "source" Decode.string
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "waste" Split.decodeFloat


decodeFromId : List Process -> Decoder Process
decodeFromId processes =
    Uuid.decoder
        |> Decode.andThen
            (\id ->
                processes
                    |> findById (Id id)
                    |> DE.fromResult
            )


getDisplayName : Process -> String
getDisplayName process =
    process.displayName
        |> Maybe.withDefault process.name


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decode impactsDecoder)


decodeAlias : Decoder Alias
decodeAlias =
    Decode.map Alias Decode.string


encodeAlias : Alias -> Encode.Value
encodeAlias =
    aliasToString >> Encode.string


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "alias", EncodeExtra.maybe encodeAlias process.alias )
        , ( "categories", Encode.list Encode.string process.categories )
        , ( "comment", Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "elec_MJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "impacts", Impact.encode process.impacts )
        , ( "name", Encode.string process.name )
        , ( "source", Encode.string process.source )
        , ( "unit", Encode.string process.unit )
        , ( "id", encodeId process.id )
        , ( "waste", Split.encodeFloat process.waste )
        ]


idFromString : String -> Maybe Id
idFromString str =
    Uuid.fromString str |> Maybe.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid
