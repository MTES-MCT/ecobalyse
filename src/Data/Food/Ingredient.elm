module Data.Food.Ingredient exposing
    ( Id
    , Ingredient
    , PlaneTransport(..)
    , TransportCooling(..)
    , byPlaneAllowed
    , byPlaneByDefault
    , decodeId
    , decodeIngredients
    , encodeId
    , findByID
    , getDefaultOriginTransport
    , idFromString
    , idToString
    )

import Data.Food.Origin as Origin exposing (Origin)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Density exposing (Density, gramsPerCubicCentimeter)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Length


type alias Ingredient =
    { id : Id
    , name : String
    , default : Process
    , defaultOrigin : Origin
    , rawToCookedRatio : Unit.Ratio
    , variants : Variants
    , density : Density
    , transportCooling : TransportCooling
    }


type Id
    = Id String


type PlaneTransport
    = PlaneNotApplicable
    | ByPlane
    | NoPlane


type TransportCooling
    = NoCooling
    | AlwaysCool
    | CoolOnceTransformed


byPlaneAllowed : PlaneTransport -> Ingredient -> Result String PlaneTransport
byPlaneAllowed planeTransport ingredient =
    if byPlaneByDefault ingredient == PlaneNotApplicable && planeTransport /= PlaneNotApplicable then
        Err byPlaneErrorMessage

    else
        Ok planeTransport


byPlaneByDefault : Ingredient -> PlaneTransport
byPlaneByDefault ingredient =
    if ingredient.defaultOrigin == Origin.OutOfEuropeAndMaghrebByPlane then
        ByPlane

    else
        PlaneNotApplicable


byPlaneErrorMessage : String
byPlaneErrorMessage =
    "Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas."


decodeId : Decode.Decoder Id
decodeId =
    Decode.string
        |> Decode.map idFromString


encodeId : Id -> Encode.Value
encodeId (Id str) =
    Encode.string str


idFromString : String -> Id
idFromString str =
    Id str


idToString : Id -> String
idToString (Id str) =
    str


type alias Variants =
    { organic : Maybe OrganicVariant
    }


type alias OrganicVariant =
    { process : Process
    , defaultBeyondLCA : BeyondLCA
    }


type alias BeyondLCA =
    { agroDiversity : Split
    , agroEcology : Split
    , animalWellness : Split
    }


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    processes
        |> List.map (\process -> ( Process.codeToString process.code, process ))
        |> Dict.fromList
        |> decodeIngredient
        |> Decode.list


decodeIngredient : Dict String Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "id" decodeId
        |> Pipe.required "name" Decode.string
        |> Pipe.required "default" (linkProcess processes)
        |> Pipe.required "default_origin" Origin.decode
        |> Pipe.required "raw_to_cooked_ratio" (Unit.decodeRatio { percentage = False })
        |> Pipe.required "variants" (decodeVariants processes)
        |> Pipe.required "density" (Decode.float |> Decode.andThen (gramsPerCubicCentimeter >> Decode.succeed))
        |> Pipe.required "transport_cooling" decodeTransportCooling


decodeTransportCooling : Decoder TransportCooling
decodeTransportCooling =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "none" ->
                        Decode.succeed NoCooling

                    "always" ->
                        Decode.succeed AlwaysCool

                    "once_transformed" ->
                        Decode.succeed CoolOnceTransformed

                    invalid ->
                        Decode.fail <| "Valeur de transport frigorifique invalide : " ++ invalid
            )


decodeVariants : Dict String Process -> Decoder Variants
decodeVariants processes =
    Decode.succeed Variants
        |> Pipe.optional "organic" (Decode.maybe (linkOrganicVariant processes)) Nothing


findByID : Id -> List Ingredient -> Result String Ingredient
findByID id ingredients =
    ingredients
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Ingrédient introuvable par id : " ++ idToString id)


getDefaultOriginTransport : List Impact.Definition -> PlaneTransport -> Origin -> Transport
getDefaultOriginTransport defs planeTransport origin =
    let
        default =
            Transport.default (Impact.impactsFromDefinitons defs)
    in
    case origin of
        Origin.France ->
            default

        Origin.EuropeAndMaghreb ->
            { default | road = Length.kilometers 2500 }

        Origin.OutOfEuropeAndMaghreb ->
            { default | road = Length.kilometers 2500, sea = Length.kilometers 18000 }

        Origin.OutOfEuropeAndMaghrebByPlane ->
            if planeTransport == ByPlane then
                { default | road = Length.kilometers 2500, air = Length.kilometers 18000 }

            else
                { default | road = Length.kilometers 2500, sea = Length.kilometers 18000 }


linkProcess : Dict String Process -> Decoder Process
linkProcess processes =
    Decode.string
        |> Decode.andThen
            (DE.fromResult
                << (\processCode ->
                        Dict.get processCode processes
                            |> Result.fromMaybe ("Procédé introuvable par code : " ++ processCode)
                   )
            )


linkOrganicVariant : Dict String Process -> Decoder OrganicVariant
linkOrganicVariant processes =
    Decode.succeed OrganicVariant
        |> Pipe.required "process" (linkProcess processes)
        |> Pipe.required "beyondLCA" decodeBeyondLCA


decodeBeyondLCA : Decoder BeyondLCA
decodeBeyondLCA =
    Decode.succeed BeyondLCA
        |> Pipe.required "agro-diversity" Split.decode
        |> Pipe.required "agro-ecology" Split.decode
        |> Pipe.optional "animal-wellness" Split.decode Split.zero
