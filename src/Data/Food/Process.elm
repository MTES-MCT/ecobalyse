module Data.Food.Process exposing
    ( Category(..)
    , Identifier
    , Process
    , ProcessName
    , categoryToLabel
    , decodeIdentifier
    , decodeList
    , encode
    , encodeIdentifier
    , findById
    , findByIdentifier
    , getDisplayName
    , identifierFromString
    , identifierToString
    , listByCategory
    , nameToString
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra


{-| Process
A process is an entry from public/data/food/processes.json. It has impacts and
various other data like categories, code, unit...
-}
type alias Process =
    { categories : List Category
    , comment : Maybe String
    , displayName : Maybe String
    , id_ : String
    , identifier : Identifier
    , impacts : Impacts
    , name : ProcessName
    , source : String
    , systemDescription : String
    , unit : String
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


type Identifier
    = Identifier String


type ProcessName
    = ProcessName String


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


identifierFromString : String -> Identifier
identifierFromString =
    Identifier


identifierToString : Identifier -> String
identifierToString (Identifier string) =
    string


nameFromString : String -> ProcessName
nameFromString =
    ProcessName


nameToString : ProcessName -> String
nameToString (ProcessName name) =
    name


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
        |> Pipe.required "categories" decodeCategories
        |> DU.strictOptional "comment" Decode.string
        |> DU.strictOptional "displayName" Decode.string
        |> Pipe.required "id" Decode.string
        |> Pipe.required "identifier" decodeIdentifier
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "name" (Decode.map nameFromString Decode.string)
        |> Pipe.required "source" Decode.string
        |> Pipe.required "system_description" Decode.string
        |> Pipe.required "unit" Decode.string


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "categories", Encode.list encodeCategory process.categories )
        , ( "comment", EncodeExtra.maybe Encode.string process.comment )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "id", Encode.string process.id_ )
        , ( "identifier", encodeIdentifier process.identifier )
        , ( "impacts", Impact.encode process.impacts )
        , ( "name", Encode.string (nameToString process.name) )
        , ( "source", Encode.string process.source )
        , ( "system_description", Encode.string process.systemDescription )
        , ( "unit", Encode.string process.unit )
        ]


decodeIdentifier : Decoder Identifier
decodeIdentifier =
    Decode.string
        |> Decode.map identifierFromString


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decodeProcess impactsDecoder)


encodeIdentifier : Identifier -> Encode.Value
encodeIdentifier =
    identifierToString >> Encode.string


findById : List Process -> String -> Result String Process
findById processes id_ =
    processes
        |> List.filter (.id_ >> (==) id_)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ id_)


findByIdentifier : Identifier -> List Process -> Result String Process
findByIdentifier ((Identifier identifierString) as identifier) processes =
    processes
        |> List.filter (.identifier >> (==) identifier)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par code : " ++ identifierString)


getDisplayName : Process -> String
getDisplayName process =
    process.displayName
        |> Maybe.withDefault (nameToString process.name)


listByCategory : Category -> List Process -> List Process
listByCategory category =
    List.filter (.categories >> List.member category)
