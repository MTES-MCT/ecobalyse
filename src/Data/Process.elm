module Data.Process exposing
    ( Category(..)
    , Id
    , Process
    , categoryToLabel
    , decodeFromId
    , decodeId
    , decodeList
    , encode
    , encodeId
    , findByAlias
    , findById
    , getDisplayName
    , getImpact
    , idFromString
    , idToString
    , listByCategory
    , sourceIdToString
    )

import Data.Common.DecodeUtils as DU
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


type Id
    = Id Uuid


{-| A process is an entry from processes.json or processes\_impacts.json.
-}
type alias Process =
    { alias : Maybe String
    , categories : List Category
    , comment : Maybe String
    , density : Float
    , displayName : Maybe String
    , elec : Energy
    , heat : Energy
    , id : Id
    , impacts : Impacts
    , name : String
    , source : String
    , sourceId : Maybe SourceId
    , unit : String
    , waste : Split
    }


type Category
    = Energy
    | Ingredient
    | Material
    | Packaging
    | Processing
    | Transform
    | Transport
    | WasteTreatment


type SourceId
    = SourceId String


categoryFromString : String -> Result String Category
categoryFromString string =
    case string of
        "energy" ->
            Ok Energy

        "ingredient" ->
            Ok Ingredient

        "material" ->
            Ok Material

        "packaging" ->
            Ok Packaging

        "processing" ->
            Ok Processing

        "transformation" ->
            Ok Transform

        "transport" ->
            Ok Transport

        "waste treatment" ->
            Ok WasteTreatment

        _ ->
            Err <| "Catégorie de procédé invalide: " ++ string


categoryToString : Category -> String
categoryToString category =
    case category of
        Energy ->
            "energy"

        Ingredient ->
            "ingredient"

        Material ->
            "material"

        Packaging ->
            "packaging"

        Processing ->
            "processing"

        Transform ->
            "transformation"

        Transport ->
            "transport"

        WasteTreatment ->
            "waste treatment"


categoryToLabel : Category -> String
categoryToLabel category =
    case category of
        Energy ->
            "Énergie"

        Ingredient ->
            "Ingrédient"

        Material ->
            "Matériau"

        Packaging ->
            "Emballage"

        Processing ->
            "Traitement"

        Transform ->
            "Transformation"

        Transport ->
            "Transport"

        WasteTreatment ->
            "Traitement des déchets"


decodeFromId : List Process -> Decoder Process
decodeFromId processes =
    Uuid.decoder
        |> Decode.andThen
            (\id ->
                findById processes (Id id)
                    |> DE.fromResult
            )


getImpact : Definition.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


sourceIdFromString : String -> SourceId
sourceIdFromString =
    SourceId


sourceIdToString : SourceId -> String
sourceIdToString (SourceId string) =
    string


decodeCategories : Decoder (List Category)
decodeCategories =
    Decode.string
        |> Decode.andThen (categoryFromString >> DE.fromResult)
        |> Decode.list


encodeCategory : Category -> Encode.Value
encodeCategory =
    categoryToString >> Encode.string


decodeProcess : Decoder Impact.Impacts -> Decoder Process
decodeProcess impactsDecoder =
    Decode.succeed Process
        |> DU.strictOptional "alias" Decode.string
        |> Pipe.required "categories" decodeCategories
        |> DU.strictOptional "comment" Decode.string
        |> Pipe.required "density" Decode.float
        |> DU.strictOptional "displayName" Decode.string
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "name" Decode.string
        |> Pipe.required "source" Decode.string
        |> DU.strictOptional "sourceId" decodeSourceId
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "waste" Split.decodeFloat


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "alias", EncodeExtra.maybe Encode.string process.alias )
        , ( "categories", Encode.list encodeCategory process.categories )
        , ( "comment", EncodeExtra.maybe Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "elec_MJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "id", encodeId process.id )
        , ( "impacts", Impact.encode process.impacts )
        , ( "name", Encode.string process.name )
        , ( "source", Encode.string process.source )
        , ( "sourceId", EncodeExtra.maybe encodeSourceId process.sourceId )
        , ( "unit", Encode.string process.unit )
        , ( "waste", Split.encodeFloat process.waste )
        ]


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decodeSourceId : Decoder SourceId
decodeSourceId =
    Decode.string
        |> Decode.map sourceIdFromString


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decodeProcess impactsDecoder)


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encodeSourceId : SourceId -> Encode.Value
encodeSourceId =
    sourceIdToString >> Encode.string


idFromString : String -> Maybe Id
idFromString str =
    Uuid.fromString str |> Maybe.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


findByAlias : List Process -> String -> Result String Process
findByAlias processes alias_ =
    processes
        |> List.filter (.alias >> (==) (Just alias_))
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par alias : " ++ alias_)


findById : List Process -> Id -> Result String Process
findById processes id =
    processes
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ idToString id)


getDisplayName : Process -> String
getDisplayName process =
    process.displayName
        |> Maybe.withDefault process.name


listByCategory : Category -> List Process -> List Process
listByCategory category =
    List.filter (.categories >> List.member category)
