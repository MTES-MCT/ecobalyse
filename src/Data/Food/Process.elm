module Data.Food.Process exposing
    ( Category(..)
    , Identifier
    , Process
    , ProcessName
    , categoryToString
    , codeFromString
    , codeToString
    , decodeIdentifier
    , decodeList
    , encode
    , encodeIdentifier
    , findById
    , findByIdentifier
    , getDisplayName
    , listByCategory
    , nameToString
    )

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
    { name : ProcessName
    , displayName : Maybe String
    , impacts : Impacts
    , unit : String
    , code : Identifier
    , category : Category
    , systemDescription : String
    , comment : Maybe String
    , id_ : String
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


codeFromString : String -> Identifier
codeFromString =
    Identifier


codeToString : Identifier -> String
codeToString (Identifier string) =
    string


nameFromString : String -> ProcessName
nameFromString =
    ProcessName


nameToString : ProcessName -> String
nameToString (ProcessName name) =
    name


decodeCategory : Decoder Category
decodeCategory =
    Decode.string
        |> Decode.andThen (categoryFromString >> DE.fromResult)


encodeCategory : Category -> Encode.Value
encodeCategory =
    categoryToString >> Encode.string


decodeProcess : Decoder Impact.Impacts -> Decoder Process
decodeProcess impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "name" (Decode.map nameFromString Decode.string)
        |> Pipe.optional "displayName" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "unit" decodeStringUnit
        |> Pipe.required "identifier" decodeIdentifier
        |> Pipe.required "category" decodeCategory
        |> Pipe.required "system_description" Decode.string
        |> Pipe.optional "comment" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "id" Decode.string


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "name", Encode.string (nameToString process.name) )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "impacts", Impact.encode process.impacts )
        , ( "unit", encodeStringUnit process.unit )
        , ( "identifier", encodeIdentifier process.code )
        , ( "category", encodeCategory process.category )
        , ( "system_description", Encode.string process.systemDescription )
        , ( "comment", EncodeExtra.maybe Encode.string process.comment )
        , ( "id", Encode.string process.id_ )
        ]


decodeIdentifier : Decoder Identifier
decodeIdentifier =
    Decode.string
        |> Decode.map codeFromString


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decodeProcess impactsDecoder)


encodeIdentifier : Identifier -> Encode.Value
encodeIdentifier =
    codeToString >> Encode.string


findById : List Process -> String -> Result String Process
findById processes id_ =
    processes
        |> List.filter (.id_ >> (==) id_)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ id_)


findByIdentifier : Identifier -> List Process -> Result String Process
findByIdentifier ((Identifier codeString) as code) processes =
    processes
        |> List.filter (.code >> (==) code)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par code : " ++ codeString)


decodeStringUnit : Decoder String
decodeStringUnit =
    Decode.string
        |> Decode.andThen
            (\str ->
                -- TODO : modify the export to have the proper unit instead of converting here?
                case str of
                    "cubic meter" ->
                        Decode.succeed "m³"

                    "kilogram" ->
                        Decode.succeed "kg"

                    "kilometer" ->
                        Decode.succeed "km"

                    "kilowatt hour" ->
                        Decode.succeed "kWh"

                    "litre" ->
                        Decode.succeed "l"

                    "megajoule" ->
                        Decode.succeed "MJ"

                    "ton kilometer" ->
                        Decode.succeed "ton.km"

                    _ ->
                        Decode.fail <| "Could not decode unit " ++ str
            )


encodeStringUnit : String -> Encode.Value
encodeStringUnit unit =
    case unit of
        "m³" ->
            Encode.string "cubic meter"

        "kg" ->
            Encode.string "kilogram"

        "km" ->
            Encode.string "kilometer"

        "kWh" ->
            Encode.string "kilowatt hour"

        "l" ->
            Encode.string "litre"

        "MJ" ->
            Encode.string "megajoule"

        "ton.km" ->
            Encode.string "ton kilometer"

        _ ->
            Encode.string "Could not decode unit"


getDisplayName : Process -> String
getDisplayName process =
    case process.displayName of
        Just displayName ->
            displayName

        Nothing ->
            nameToString process.name


listByCategory : Category -> List Process -> List Process
listByCategory category =
    List.filter (.category >> (==) category)
