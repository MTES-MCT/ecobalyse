module Data.Geozone exposing
    ( AquaticPollutionScenario(..)
    , Code(..)
    , Geozone
    , codeFromString
    , codeToString
    , decodeCode
    , decodeList
    , encode
    , encodeCode
    , findByCode
    , getAquaticPollutionRatio
    , isEuropeOrTurkey
    , unknownGeozoneCode
    , validateForScope
    )

import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.WorldRegion as WorldRegion exposing (WorldRegion)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Code
    = Code String


type AquaticPollutionScenario
    = Average
    | Best
    | Worst


type alias Geozone =
    { aquaticPollutionScenario : AquaticPollutionScenario
    , code : Code
    , electricityProcess : Process
    , heatProcess : Process
    , name : String
    , scopes : List Scope
    , worldRegion : WorldRegion
    }


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


findByCode : Code -> List Geozone -> Result String Geozone
findByCode code =
    List.filter (.code >> (==) code)
        >> List.head
        >> Result.fromMaybe ("Code de zone géographique invalide: " ++ codeToString code ++ ".")


decode : List Process -> Decoder Geozone
decode processes =
    Decode.succeed Geozone
        |> Pipe.required "aquaticPollutionScenario" decodeAquaticPollutionScenario
        |> Pipe.required "code" decodeCode
        |> Pipe.required "electricityProcessId" (Process.decodeFromId processes)
        |> Pipe.required "heatProcessId" (Process.decodeFromId processes)
        |> Pipe.required "name" Decode.string
        |> Pipe.optional "scopes" (Decode.list Scope.decode) [ Scope.Food, Scope.Textile ]
        |> Pipe.required "worldRegion" WorldRegion.decode


decodeCode : Decoder Code
decodeCode =
    Decode.map Code Decode.string


decodeList : List Process -> Decoder (List Geozone)
decodeList processes =
    Decode.list (decode processes)


encode : Geozone -> Encode.Value
encode v =
    Encode.object
        [ ( "aquaticPollutionScenario", v.aquaticPollutionScenario |> aquaticPollutionScenarioToString |> Encode.string )
        , ( "code", encodeCode v.code )
        , ( "electricityProcessId", v.electricityProcess.id |> Process.idToString |> Encode.string )
        , ( "heatProcessId", v.heatProcess.id |> Process.idToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "scopes", v.scopes |> Encode.list Scope.encode )
        ]


encodeCode : Code -> Encode.Value
encodeCode =
    codeToString >> Encode.string


decodeAquaticPollutionScenario : Decoder AquaticPollutionScenario
decodeAquaticPollutionScenario =
    Decode.string
        |> Decode.map aquaticPollutionScenarioFromString
        |> Decode.andThen DE.fromResult


aquaticPollutionScenarioFromString : String -> Result String AquaticPollutionScenario
aquaticPollutionScenarioFromString string =
    case string of
        "Average" ->
            Ok Average

        "Best" ->
            Ok Best

        "Worst" ->
            Ok Worst

        _ ->
            Err <| "Le scenario '" ++ string ++ "' n'est pas un scénario de pollution aquatique valide (choix entre ['Best', 'Average', 'Worst']"


aquaticPollutionScenarioToString : AquaticPollutionScenario -> String
aquaticPollutionScenarioToString scenario =
    case scenario of
        Average ->
            "Average"

        Best ->
            "Best"

        Worst ->
            "Worst"


getAquaticPollutionRatio : AquaticPollutionScenario -> Split
getAquaticPollutionRatio scenario =
    Result.withDefault Split.full <|
        case scenario of
            Average ->
                Split.fromPercent 19

            Best ->
                Split.fromPercent 5

            Worst ->
                Split.fromPercent 37


isEuropeOrTurkey : Geozone -> Bool
isEuropeOrTurkey geozone =
    geozone.worldRegion == WorldRegion.Europe || geozone.code == codeFromString "TR"


unknownGeozoneCode : Code
unknownGeozoneCode =
    Code "---"


validateForScope : Scope -> List Geozone -> Code -> Result String Code
validateForScope scope geozones geozoneCode =
    geozones
        |> findByCode geozoneCode
        |> Result.andThen
            (\{ code, scopes } ->
                if List.member scope scopes then
                    Ok code

                else
                    "Le code de zone géographique "
                        ++ codeToString geozoneCode
                        ++ " n'est pas utilisable dans un contexte "
                        ++ Scope.toLabel scope
                        ++ "."
                        |> Err
            )
