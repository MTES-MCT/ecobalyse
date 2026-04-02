module Data.Food.Ingredient exposing
    ( FoodOriginDistances
    , FoodOriginTransport
    , Id(..)
    , Ingredient
    , PlaneTransport(..)
    , TransportCooling(..)
    , byPlaneAllowed
    , byPlaneByDefault
    , decodeFoodOriginDistances
    , decodeId
    , decodeIngredients
    , encodeId
    , encodePlaneTransport
    , findById
    , getDefaultOriginTransport
    , idFromString
    , idToString
    , toSearchableString
    , transportCoolingToString
    )

import Data.Food.EcosystemicServices as EcosystemicServices exposing (EcosystemicServices)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Ingredient.CropGroup as CropGroup exposing (CropGroup)
import Data.Food.Ingredient.Scenario as Scenario exposing (Scenario)
import Data.Food.Origin as Origin exposing (Origin)
import Data.Impact as Impact
import Data.Process as Process exposing (Process)
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
import Length exposing (Length)
import Quantity


type alias Ingredient =
    { alias : String
    , byplane : Bool
    , categories : List IngredientCategory.Category
    , cropGroup : CropGroup
    , defaultOrigin : Origin
    , density : Density
    , ecosystemicServices : EcosystemicServices
    , id : Id
    , inediblePart : Split
    , landOccupation : Float
    , name : String
    , process : Process
    , rawToCookedRatio : Unit.Ratio
    , scenario : Scenario
    , transportCooling : TransportCooling
    , visible : Bool
    }



-- All distance stages from transportfood.json for a given region.


type alias FoodOriginTransport =
    { materialtotransform : Length -- E1: ingredient source → transformation facility
    , transformtologistic : Length -- E2: transformation facility → logistics hub
    , logistictoport : Length -- E2: logistics hub → port/airport (if applicable)
    , camion : Length -- E3: truck from region to France
    , bateau : Length -- E3: sea from region to France
    , air : Length -- E3: air from region to France
    }



-- Dict keyed by region code (e.g. "FR", "REM", "OI") to all transport stages.


type alias FoodOriginDistances =
    Dict String FoodOriginTransport


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
    if ingredient.byplane then
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


idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


decodeIngredients : List Process -> Decoder (List Ingredient)
decodeIngredients processes =
    decodeIngredient processes
        |> Decode.list
        -- Don't use ingredients that aren't visible.
        |> Decode.map (List.filter .visible)


decodeIngredient : List Process -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "alias" Decode.string
        |> Pipe.optional "byplane" Decode.bool False
        |> Pipe.required "categories" (Decode.list IngredientCategory.decode)
        |> Pipe.optional "cropGroup" CropGroup.decode CropGroup.empty
        |> Pipe.required "defaultOrigin" Origin.decode
        |> Pipe.required "density" (Decode.float |> Decode.map gramsPerCubicCentimeter)
        |> Pipe.optional "ecosystemicServices" EcosystemicServices.decode EcosystemicServices.empty
        |> Pipe.required "id" decodeId
        |> Pipe.required "inediblePart" Split.decodeFloat
        |> Pipe.required "landOccupation" Decode.float
        |> Pipe.required "name" Decode.string
        |> Pipe.required "processId" (linkProcess processes)
        |> Pipe.required "rawToCookedRatio" Unit.decodeRatio
        |> Pipe.optional "scenario" Scenario.decode Scenario.empty
        |> Pipe.required "transportCooling" decodeTransportCooling
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


decodeFoodOriginDistances : Decoder FoodOriginDistances
decodeFoodOriginDistances =
    let
        km =
            Decode.float |> Decode.map Length.kilometers

        decodeToFrance =
            Decode.succeed
                (\camion bateau air -> { camion = camion, bateau = bateau, air = air })
                |> Pipe.required "camion" km
                |> Pipe.required "bateau" km
                |> Pipe.required "air" km

        decodeEntry =
            Decode.succeed
                (\code materialtotransform transformtologistic logistictoport toFrance ->
                    ( code
                    , { materialtotransform = materialtotransform
                      , transformtologistic = transformtologistic
                      , logistictoport = logistictoport
                      , camion = toFrance.camion
                      , bateau = toFrance.bateau
                      , air = toFrance.air
                      }
                    )
                )
                |> Pipe.required "code" Decode.string
                |> Pipe.required "materialtotransform" km
                |> Pipe.required "transformtologistic" km
                |> Pipe.required "logistictoport" km
                |> Pipe.required "toFrance" decodeToFrance
    in
    Decode.list decodeEntry
        |> Decode.map Dict.fromList


findById : Id -> List Ingredient -> Result String Ingredient
findById id ingredients =
    ingredients
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Ingrédient introuvable par id : " ++ idToString id)



-- Returns the complete transport for an ingredient based on its origin.
-- road = materialtotransform + transformtologistic + logistictoport + toFrance.camion
-- sea  = toFrance.bateau  (if not ByPlane)
-- air  = toFrance.air     (if ByPlane)


getDefaultOriginTransport : PlaneTransport -> Origin -> FoodOriginDistances -> Transport
getDefaultOriginTransport planeTransport origin distances =
    case Dict.get (Origin.toCode origin) distances of
        Nothing ->
            Transport.default Impact.empty

        Just t ->
            let
                totalRoad =
                    t.materialtotransform
                        |> Quantity.plus t.transformtologistic
                        |> Quantity.plus t.logistictoport
                        |> Quantity.plus t.camion

                empty =
                    Transport.default Impact.empty
            in
            if planeTransport == ByPlane then
                { empty | road = totalRoad, air = t.air }

            else
                { empty | road = totalRoad, sea = t.bateau }


linkProcess : List Process -> Decoder Process
linkProcess processes =
    Decode.string
        |> Decode.andThen
            (Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
                >> DE.fromResult
            )


transportCoolingToString : TransportCooling -> String
transportCoolingToString v =
    case v of
        AlwaysCool ->
            "Toujours frigorifique"

        CoolOnceTransformed ->
            "Frigorifique après transformation"

        NoCooling ->
            "Non frigorifique"


toSearchableString : Ingredient -> String
toSearchableString ingredient =
    String.join " "
        [ ingredient.alias
        , ingredient.categories |> List.map IngredientCategory.toLabel |> String.join " "
        , ingredient.cropGroup |> CropGroup.toLabel
        , ingredient.defaultOrigin |> Origin.toLabel
        , ingredient.name
        , ingredient.process |> Process.getDisplayName
        , ingredient.process |> Process.getTechnicalName
        , ingredient.scenario |> Scenario.toLabel
        , ingredient.transportCooling |> transportCoolingToString
        ]
