module Data.Food.Ingredient exposing
    ( Id(..)
    , Ingredient
    , PlaneTransport(..)
    , TransportCooling(..)
    , byPlaneAllowed
    , byPlaneByDefault
    , decodeId
    , decodeIngredients
    , encodeId
    , encodePlaneTransport
    , findById
    , getDefaultOriginTransport
    , idFromString
    , idToString
    )

import Data.Food.EcosystemicServices as EcosystemicServices exposing (EcosystemicServices)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Origin as Origin exposing (Origin)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Density exposing (Density, gramsPerCubicCentimeter)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Length


type alias Ingredient =
    { categories : List IngredientCategory.Category
    , default : Process
    , defaultOrigin : Origin
    , density : Density
    , ecosystemicServices : EcosystemicServices
    , id : Id
    , inediblePart : Split
    , name : String
    , rawToCookedRatio : Unit.Ratio
    , transportCooling : TransportCooling
    , visible : Bool
    }


type Id
    = Id Uuid


type PlaneTransport
    = ByPlane
    | NoPlane
    | PlaneNotApplicable


type TransportCooling
    = AlwaysCool
    | CoolOnceTransformed
    | NoCooling


byPlaneAllowed : PlaneTransport -> Ingredient -> Result String PlaneTransport
byPlaneAllowed planeTransport ingredient =
    case ( planeTransport, byPlaneByDefault ingredient ) of
        ( ByPlane, PlaneNotApplicable ) ->
            Err "Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas."

        -- Note: PlaneNotApplicable is used for conveying both the absence of air transport AND impossible plane transport;
        --       here we treat it as the equivalent of a `Nothing` where the ingredient default origin would suggest a
        --       transport by air (eg. Non-EU Mango)
        ( PlaneNotApplicable, ByPlane ) ->
            Ok ByPlane

        _ ->
            Ok planeTransport


byPlaneByDefault : Ingredient -> PlaneTransport
byPlaneByDefault ingredient =
    if ingredient.defaultOrigin == Origin.OutOfEuropeAndMaghrebByPlane then
        ByPlane

    else
        PlaneNotApplicable


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encodePlaneTransport : PlaneTransport -> Maybe Encode.Value
encodePlaneTransport planeTransport =
    case planeTransport of
        ByPlane ->
            Just <| Encode.string "byPlane"

        NoPlane ->
            Just <| Encode.string "noPlane"

        PlaneNotApplicable ->
            Nothing


idFromString : String -> Maybe Id
idFromString str =
    Uuid.fromString str |> Maybe.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    processes
        |> List.map (\process -> ( Process.sourceIdToString process.sourceId, process ))
        |> Dict.fromList
        |> decodeIngredient
        |> Decode.list
        -- Don't use ingredients that aren't visible.
        |> Decode.map (List.filter .visible)


decodeIngredient : Dict String Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "categories" (Decode.list IngredientCategory.decode)
        |> Pipe.required "default" (linkProcess processes)
        |> Pipe.required "default_origin" Origin.decode
        |> Pipe.required "density" (Decode.float |> Decode.map gramsPerCubicCentimeter)
        |> Pipe.optional "ecosystemicServices" EcosystemicServices.decode EcosystemicServices.empty
        |> Pipe.required "id" decodeId
        |> Pipe.required "inedible_part" Split.decodeFloat
        |> Pipe.required "name" Decode.string
        |> Pipe.required "raw_to_cooked_ratio" Unit.decodeRatio
        |> Pipe.required "transport_cooling" decodeTransportCooling
        |> Pipe.required "visible" Decode.bool


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


findById : Id -> List Ingredient -> Result String Ingredient
findById id ingredients =
    ingredients
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Ingrédient introuvable par id : " ++ idToString id)


getDefaultOriginTransport : PlaneTransport -> Origin -> Transport
getDefaultOriginTransport planeTransport origin =
    let
        default =
            Transport.default Impact.empty
    in
    case origin of
        Origin.EuropeAndMaghreb ->
            { default | road = Length.kilometers 2500 }

        Origin.France ->
            default

        Origin.OutOfEuropeAndMaghreb ->
            { default | road = Length.kilometers 2500, sea = Length.kilometers 18000 }

        Origin.OutOfEuropeAndMaghrebByPlane ->
            if planeTransport == ByPlane then
                { default | air = Length.kilometers 18000, road = Length.kilometers 2500 }

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
