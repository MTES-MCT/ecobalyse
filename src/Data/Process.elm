module Data.Process exposing
    ( Id
    , Process
    , Unit(..)
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
    , getMaterialTypes
    , getTechnicalName
    , idFromString
    , idToString
    , listAvailableMaterialTransforms
    , listByCategory
    , toSearchableString
    , unitLabel
    , unitToString
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
    { activityName : ActivityName
    , categories : List Category
    , comment : String
    , density : Float
    , displayName : Maybe String
    , elec : Energy
    , heat : Energy
    , id : Id
    , impacts : Impacts
    , location : Maybe String
    , scopes : List Scope
    , source : String
    , unit : Unit
    , waste : Split
    }


type ActivityName
    = ActivityName String


type Unit
    = CubicMeter
    | Items
    | Kilogram
    | KilowattHour
    | Liter
    | Megajoule
    | SquareMeter
    | TonKilometer


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


activityNameFromString : String -> ActivityName
activityNameFromString =
    ActivityName


activityNameToString : ActivityName -> String
activityNameToString (ActivityName string) =
    string


decode : Decoder Impact.Impacts -> Decoder Process
decode impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "activityName" (DU.decodeNonEmptyString |> Decode.map activityNameFromString)
        |> Pipe.required "categories" Category.decodeList
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "density" Decode.float
        |> DU.strictOptional "displayName" DU.decodeNonEmptyString
        |> Pipe.required "elecMJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "heatMJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "location" (Decode.maybe Decode.string)
        |> Pipe.required "scopes" (Decode.list Scope.decode)
        |> Pipe.required "source" Decode.string
        |> Pipe.required "unit" (Decode.string |> Decode.andThen (DE.fromResult << unitFromString))
        |> Pipe.required "waste" Split.decodeFloat


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "activityName", encodeActivityName process.activityName )
        , ( "categories", Encode.list Category.encode process.categories )
        , ( "comment", Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", EncodeExtra.maybe Encode.string process.displayName )
        , ( "elecMJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "heatMJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "id", encodeId process.id )
        , ( "impacts", Impact.encode process.impacts )
        , ( "location", EncodeExtra.maybe Encode.string process.location )
        , ( "scopes", process.scopes |> Encode.list Scope.encode )
        , ( "source", Encode.string process.source )
        , ( "unit", process.unit |> unitToString |> Encode.string )
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


encodeActivityName : ActivityName -> Encode.Value
encodeActivityName =
    activityNameToString >> Encode.string


idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id


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


getMaterialTypes : Process -> List Category.Material
getMaterialTypes =
    .categories
        >> List.filterMap
            (\category ->
                case category of
                    Category.MaterialType materialType ->
                        Just materialType

                    _ ->
                        Nothing
            )


getTechnicalName : Process -> String
getTechnicalName { activityName } =
    activityNameToString activityName


listAvailableMaterialTransforms : Process -> List Process -> List Process
listAvailableMaterialTransforms material =
    let
        -- no, this isn't available in List.Extra :(
        intersect a b =
            List.filter (\x -> List.member x b) a

        materialTypes =
            getMaterialTypes material
    in
    listByCategory Category.Transform
        >> List.filterMap
            (\process ->
                case getMaterialTypes process of
                    [] ->
                        Nothing

                    transformMaterialTypes ->
                        if List.length (intersect materialTypes transformMaterialTypes) > 0 then
                            Just process

                        else
                            Nothing
            )
        >> listByUnit material.unit


listByCategory : Category -> List Process -> List Process
listByCategory category =
    List.filter (.categories >> List.member category)


listByUnit : Unit -> List Process -> List Process
listByUnit unit =
    List.filter (.unit >> (==) unit)


toSearchableString : Process -> String
toSearchableString process =
    String.join " "
        [ idToString process.id
        , getDisplayName process
        , getTechnicalName process
        , process.categories |> List.map Category.toLabel |> String.join " "
        , process.scopes |> List.map Scope.toString |> String.join " "
        , process.comment
        , process.source
        ]


unitLabel : Unit -> String
unitLabel unit =
    case unit of
        CubicMeter ->
            "Volume"

        Items ->
            "Quantité"

        Kilogram ->
            "Masse"

        KilowattHour ->
            "Électricité"

        Liter ->
            "Volume"

        Megajoule ->
            "Chaleur"

        SquareMeter ->
            "Surface"

        TonKilometer ->
            "Transport"


unitToString : Unit -> String
unitToString unit =
    case unit of
        CubicMeter ->
            "m3"

        Items ->
            "Item(s)"

        Kilogram ->
            "kg"

        KilowattHour ->
            "kWh"

        Liter ->
            "L"

        Megajoule ->
            "MJ"

        SquareMeter ->
            "m2"

        TonKilometer ->
            "t⋅km"


unitFromString : String -> Result String Unit
unitFromString string =
    case string of
        "item" ->
            Ok Items

        "kg" ->
            Ok Kilogram

        "kWh" ->
            Ok KilowattHour

        "L" ->
            Ok Liter

        "m2" ->
            Ok SquareMeter

        "m3" ->
            Ok CubicMeter

        "MJ" ->
            Ok Megajoule

        "t⋅km" ->
            Ok TonKilometer

        _ ->
            Err ("Invalid or non-supported process unit: " ++ string)
