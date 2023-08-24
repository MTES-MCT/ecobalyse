module Data.Food.Process exposing
    ( Category(..)
    , Identifier
    , Process
    , ProcessName
    , WellKnown
    , codeFromString
    , codeToString
    , decodeIdentifier
    , decodeList
    , encodeIdentifier
    , findByIdentifier
    , getDisplayName
    , listByCategory
    , loadWellKnown
    , nameToString
    )

import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Result.Extra as RE


{-| Process
A process is an entry from public/data/food/processes.json. It has impacts and
various other data like categories, code, unit...
-}
type alias Process =
    { name : ProcessName
    , displayName : Maybe String
    , impacts : Impact.Impacts
    , unit : String
    , code : Identifier
    , category : Category
    , systemDescription : String
    , comment : Maybe String
    , id_ : Maybe String
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


decodeProcess : Definitions -> Decoder Process
decodeProcess definitions =
    Decode.succeed Process
        |> Pipe.required "name" (Decode.map nameFromString Decode.string)
        |> Pipe.optional "displayName" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)
        |> Pipe.required "unit" decodeStringUnit
        |> Pipe.required "identifier" decodeIdentifier
        |> Pipe.required "category" decodeCategory
        |> Pipe.required "system_description" Decode.string
        |> Pipe.optional "comment" (Decode.maybe Decode.string) Nothing
        |> Pipe.required "id" (Decode.maybe Decode.string)


decodeIdentifier : Decoder Identifier
decodeIdentifier =
    Decode.string
        |> Decode.map codeFromString


decodeList : Definitions -> Decoder (List Process)
decodeList definitions =
    Decode.list (decodeProcess definitions)


encodeIdentifier : Identifier -> Encode.Value
encodeIdentifier =
    codeToString >> Encode.string


findById : List Process -> String -> Result String Process
findById processes id_ =
    processes
        |> List.filter (.id_ >> (==) (Just id_))
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ id_)


findByIdentifier : List Process -> Identifier -> Result String Process
findByIdentifier processes ((Identifier codeString) as code) =
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
        resolve id_ =
            RE.andMap (findById processes id_)
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
