module Data.Food.Process exposing
    ( Category(..)
    , Code
    , Process
    , ProcessName
    , WellKnown
    , codeFromString
    , codeToString
    , decodeCode
    , decodeList
    , encodeCode
    , findByCode
    , findByName
    , getDisplayName
    , listByCategory
    , loadWellKnown
    , nameFromString
    , nameToString
    )

import Data.Impact as Impact
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Result.Extra as RE


{-| Process
A process is an entry from public/data/food/processes/(explorer|builder).json. It has impacts and
various other data like categories, code, unit...
-}
type alias Process =
    { name : ProcessName
    , displayName : Maybe String
    , impacts : Impact.Impacts
    , unit : String
    , code : Code
    , category : Category
    , systemDescription : String
    , categoryTags : List String
    , comment : Maybe String
    , alias : Maybe String
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


type Code
    = Code String


type ProcessName
    = ProcessName String


type alias WellKnown =
    { lorryTransport : Process
    , boatTransport : Process
    , planeTransport : Process
    , lorryCoolingTransport : Process
    , boatCoolingTransport : Process
    , water : Process
    , lowVoltageElectricity : Process
    , domesticGasHeat : Process
    }


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


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
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


decodeProcess : Decoder Process
decodeProcess =
    Decode.succeed Process
        |> Pipe.required "name" (Decode.map nameFromString Decode.string)
        |> Pipe.optional "displayName" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "impacts" Impact.decodeImpacts
        |> Pipe.required "unit" decodeStringUnit
        |> Pipe.required "identifier" decodeCode
        |> Pipe.required "category" decodeCategory
        |> Pipe.required "system_description" Decode.string
        |> Pipe.required "category_tags" (Decode.list Decode.string)
        |> Pipe.optional "comment" (Decode.maybe Decode.string) Nothing
        |> Pipe.optional "alias" (Decode.maybe Decode.string) Nothing


decodeCode : Decoder Code
decodeCode =
    Decode.string
        |> Decode.map codeFromString


decodeList : Decoder (List Process)
decodeList =
    Decode.list decodeProcess


encodeCode : Code -> Encode.Value
encodeCode =
    codeToString >> Encode.string


findByAlias : List Process -> String -> Result String Process
findByAlias processes alias =
    processes
        |> List.filter (.alias >> (==) (Just alias))
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par alias : " ++ alias)


findByCode : List Process -> Code -> Result String Process
findByCode processes ((Code codeString) as code) =
    processes
        |> List.filter (.code >> (==) code)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par code : " ++ codeString)


findByName : List Process -> ProcessName -> Result String Process
findByName processes ((ProcessName name) as procName) =
    processes
        |> List.filter (.name >> (==) procName)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


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


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown processes =
    let
        resolve alias =
            RE.andMap (findByAlias processes alias)
    in
    Ok WellKnown
        |> resolve "lorry"
        |> resolve "boat"
        |> resolve "plane"
        |> resolve "lorry-cooling"
        |> resolve "boat-cooling"
        |> resolve "tapwater"
        |> resolve "low-voltage-electricity"
        |> resolve "domestic-gas-heat"
