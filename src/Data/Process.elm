module Data.Process exposing
    ( Id
    , Process
    , available
    , decode
    , decodeFromId
    , decodeId
    , decodeList
    , encode
    , encodeId
    , findById
    , getDisplayName
    , getImpact
    , getTechnicalName
    , idFromString
    , idToString
    , listByCategory
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra


type Id
    = Id Uuid


{-| A process is an entry from processes.json or processes\_impacts.json.
-}
type alias Process =
    { categories : List Category
    , comment : String
    , density : Float
    , displayName : Maybe String
    , elec : Energy
    , heat : Energy
    , id : Id
    , impacts : Impacts
    , scopes : List Scope
    , source : String
    , sourceId : SourceId
    , unit : String
    , waste : Split
    }


type SourceId
    = SourceId String


{-| List processes which ids are not part of the provided list of ids
-}
available : List Id -> List Process -> List Process
available alreadyUsedIds =
    List.filter (\{ id } -> not <| List.member id alreadyUsedIds)
        >> List.sortBy getDisplayName


decodeFromId : List Process -> Decoder Process
decodeFromId processes =
    Uuid.decoder
        |> Decode.andThen (Id >> (\id -> findById id processes) >> DE.fromResult)


getImpact : Definition.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


sourceIdFromString : String -> SourceId
sourceIdFromString =
    SourceId


sourceIdToString : SourceId -> String
sourceIdToString (SourceId string) =
    string


decode : Decoder Impact.Impacts -> Decoder Process
decode impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "categories" Category.decodeList
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "density" Decode.float
        |> DU.strictOptional "displayName" DU.decodeNonEmptyString
        |> Pipe.required "elecMJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "heatMJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "scopes" (Decode.list Scope.decode)
        |> Pipe.required "source" Decode.string
        |> Pipe.required "sourceId" (DU.decodeNonEmptyString |> Decode.map sourceIdFromString)
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "waste" Split.decodeFloat


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "categories", Encode.list Category.encode process.categories )
        , ( "comment", Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "elecMJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "heatMJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "id", encodeId process.id )
        , ( "impacts", Impact.encode process.impacts )
        , ( "scopes", process.scopes |> Encode.list Scope.encode )
        , ( "source", Encode.string process.source )
        , ( "sourceId", encodeSourceId process.sourceId )
        , ( "unit", Encode.string process.unit )
        , ( "waste", Split.encodeFloat process.waste )
        ]


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList =
    decode >> Decode.list


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encodeSourceId : SourceId -> Encode.Value
encodeSourceId =
    sourceIdToString >> Encode.string


idFromString : String -> Result String Id
idFromString str =
    str
        |> Uuid.fromString
        |> Result.fromMaybe ("Identifiant invalide : " ++ str)
        |> Result.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


findById : Id -> List Process -> Result String Process
findById id processes =
    processes
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ idToString id)


getDisplayName : Process -> String
getDisplayName process =
    case process.displayName of
        Just displayName ->
            displayName

        Nothing ->
            getTechnicalName process


getTechnicalName : Process -> String
getTechnicalName { sourceId } =
    sourceIdToString sourceId


listByCategory : Category -> List Process -> List Process
listByCategory category =
    List.filter (.categories >> List.member category)
