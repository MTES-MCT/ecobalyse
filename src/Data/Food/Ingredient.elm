module Data.Food.Ingredient exposing
    ( Complements
    , Id(..)
    , Ingredient
    , PlaneTransport(..)
    , TransportCooling(..)
    , autocomplete
    , byPlaneAllowed
    , byPlaneByDefault
    , decodeComplements
    , decodeId
    , decodeIngredients
    , encodeComplements
    , encodeId
    , encodePlaneTransport
    , findByID
    , getDefaultOriginTransport
    , groupCategories
    , idFromString
    , idToString
    )

import Data.Food.Ingredient.Category as IngredientCategory
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
import List.Extra as LE
import String.Normalize as Normalize


type alias Ingredient =
    { id : Id
    , name : String
    , categories : List IngredientCategory.Category
    , default : Process
    , defaultOrigin : Origin
    , inediblePart : Split
    , rawToCookedRatio : Unit.Ratio
    , density : Density
    , transportCooling : TransportCooling
    , visible : Bool
    , complements : Complements
    }


type alias Complements =
    { agroDiversity : Split
    , agroEcology : Split
    , animalWelfare : Split
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


autocomplete : String -> List Ingredient -> List Ingredient
autocomplete query =
    let
        toWords =
            String.toLower
                >> Normalize.removeDiacritics
                >> String.foldl
                    (\c acc ->
                        if not (List.member c [ '(', ')' ]) then
                            String.cons c acc

                        else
                            acc
                    )
                    ""
                >> String.split " "

        searchWords =
            toWords (String.trim query)
    in
    List.map (\ingredient -> ( toWords ingredient.name, ingredient ))
        >> List.filter
            (\( words, _ ) ->
                query == "" || List.all (\w -> List.any (String.contains w) words) searchWords
            )
        >> List.sortBy (Tuple.second >> .name)
        >> List.map Tuple.second


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


encodeComplements : Complements -> Encode.Value
encodeComplements v =
    Encode.object
        [ ( "agro-diversity", Split.encodePercent v.agroDiversity )
        , ( "agro-ecology", Split.encodePercent v.agroEcology )
        , ( "animal-welfare", Split.encodePercent v.animalWelfare )
        ]


encodeId : Id -> Encode.Value
encodeId (Id str) =
    Encode.string str


encodePlaneTransport : PlaneTransport -> Maybe Encode.Value
encodePlaneTransport planeTransport =
    case planeTransport of
        PlaneNotApplicable ->
            Nothing

        ByPlane ->
            Just <| Encode.string "byPlane"

        NoPlane ->
            Just <| Encode.string "noPlane"


idFromString : String -> Id
idFromString str =
    Id str


idToString : Id -> String
idToString (Id str) =
    str


decodeComplements : Decoder Complements
decodeComplements =
    Decode.succeed Complements
        |> Pipe.required "agro-diversity" Split.decodePercent
        |> Pipe.required "agro-ecology" Split.decodePercent
        |> Pipe.optional "animal-welfare" Split.decodePercent Split.zero


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    processes
        |> List.map (\process -> ( Process.codeToString process.code, process ))
        |> Dict.fromList
        |> decodeIngredient
        |> Decode.list
        -- Don't use ingredients that aren't visible.
        |> Decode.map (List.filter .visible)


decodeIngredient : Dict String Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "id" decodeId
        |> Pipe.required "name" Decode.string
        |> Pipe.required "categories" (Decode.list IngredientCategory.decode)
        |> Pipe.required "default" (linkProcess processes)
        |> Pipe.required "default_origin" Origin.decode
        |> Pipe.required "inedible_part" Split.decodeFloat
        |> Pipe.required "raw_to_cooked_ratio" (Unit.decodeRatio { percentage = False })
        |> Pipe.required "density" (Decode.float |> Decode.andThen (gramsPerCubicCentimeter >> Decode.succeed))
        |> Pipe.required "transport_cooling" decodeTransportCooling
        |> Pipe.required "visible" Decode.bool
        |> Pipe.required "complements" decodeComplements


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


findByID : Id -> List Ingredient -> Result String Ingredient
findByID id ingredients =
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


groupCategories : List Ingredient -> List ( IngredientCategory.Category, List Ingredient )
groupCategories =
    let
        getFirst =
            List.head >> Maybe.withDefault IngredientCategory.Misc
    in
    List.sortBy (.categories >> getFirst >> IngredientCategory.toLabel)
        >> LE.groupWhile (\a b -> getFirst a.categories == getFirst b.categories)
        >> List.map (\( first, rest ) -> ( getFirst first.categories, first :: rest ))


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
