module Data.Country exposing
    ( AquaticPollutionScenario(..)
    , Code(..)
    , Country
    , codeFromString
    , codeToString
    , decodeCode
    , decodeList
    , encode
    , encodeCode
    , findByCode
    , getAquaticPollutionRatio
    )

import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Textile.Process as Process exposing (Process)
import Data.Zone as Zone exposing (Zone)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Code
    = Code String


type AquaticPollutionScenario
    = Best
    | Average
    | Worst


type alias Country =
    { code : Code
    , name : String
    , zone : Zone
    , electricityProcess : Process
    , heatProcess : Process
    , airTransportRatio : Split
    , scopes : List Scope
    , aquaticPollutionScenario : AquaticPollutionScenario
    }


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


findByCode : Code -> List Country -> Result String Country
findByCode code =
    List.filter (.code >> (==) code)
        >> List.head
        >> Result.fromMaybe ("Code pays invalide: " ++ codeToString code ++ ".")


decode : List Process -> Decoder Country
decode processes =
    Decode.succeed Country
        |> Pipe.required "code" decodeCode
        |> Pipe.required "name" Decode.string
        |> Pipe.required "zone" Zone.decode
        |> Pipe.required "electricityProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "heatProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "airTransportRatio" Split.decodeFloat
        |> Pipe.optional "scopes" (Decode.list Scope.decode) [ Scope.Food, Scope.Textile ]
        |> Pipe.required "aquaticPollutionScenario" decodeAquaticPollutionScenario


decodeCode : Decoder Code
decodeCode =
    Decode.map Code Decode.string


decodeList : List Process -> Decoder (List Country)
decodeList processes =
    Decode.list (decode processes)


encode : Country -> Encode.Value
encode v =
    Encode.object
        [ ( "code", encodeCode v.code )
        , ( "name", Encode.string v.name )
        , ( "electricityProcessUuid", v.electricityProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "heatProcessUuid", v.heatProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "airTransportRatio", Split.encodeFloat v.airTransportRatio )
        , ( "scopes", v.scopes |> Encode.list Scope.encode )
        , ( "aquaticPollutionScenario", v.aquaticPollutionScenario |> aquaticPollutionScenarioToString |> Encode.string )
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
        "Best" ->
            Ok Best

        "Average" ->
            Ok Average

        "Worst" ->
            Ok Worst

        _ ->
            Err <| "Le scenario '" ++ string ++ "' n'est pas un scénario de pollution aquatique valide (choix entre ['Best', 'Average', 'Worst']"


aquaticPollutionScenarioToString : AquaticPollutionScenario -> String
aquaticPollutionScenarioToString scenario =
    case scenario of
        Best ->
            "Best"

        Average ->
            "Average"

        Worst ->
            "Worst"


getAquaticPollutionRatio : AquaticPollutionScenario -> Split
getAquaticPollutionRatio scenario =
    case scenario of
        Best ->
            Split.tenth

        Average ->
            Split.fromPercent 36 |> Result.withDefault Split.full

        Worst ->
            Split.fromPercent 65 |> Result.withDefault Split.full
