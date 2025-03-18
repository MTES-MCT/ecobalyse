module TestUtils exposing
    ( asTest
    , createServerRequest
    , expectImpactsEqual
    , expectResultErrorContains
    , expectResultWithin
    , it
    , suiteWithDb
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Trigrams)
import Data.Process as Process
import Data.Unit as Unit
import Expect exposing (Expectation, FloatingPointTolerance)
import Json.Encode as Encode
import Server.Request exposing (Request)
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest =
    it


it : String -> Expectation -> Test
it label =
    always >> test label


suiteWithDb : String -> (Db -> List Test) -> Test
suiteWithDb name suite =
    case StaticDb.db StaticJson.rawJsonProcesses of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load static database" <|
                    \_ -> Expect.fail <| "Couldn't parse static database: " ++ error
                ]


expectImpactsEqual : Trigrams (Float -> Expectation) -> Impacts -> Expectation
expectImpactsEqual impacts subject =
    Definition.trigrams
        |> List.map
            (\trigram ->
                Impact.getImpact trigram >> Unit.impactToFloat >> Definition.get trigram impacts
            )
        |> (\expectations ->
                Expect.all expectations subject
           )


expectResultErrorContains : String -> Result String a -> Expectation
expectResultErrorContains str result =
    case result of
        Ok _ ->
            Expect.fail "result is not an error"

        Err err ->
            if String.contains str err then
                Expect.pass

            else
                Expect.fail <| "result string error\n\n" ++ err ++ "\n\ndoes not contain `" ++ str ++ "`"


expectResultWithin : FloatingPointTolerance -> Float -> Result String Float -> Expectation
expectResultWithin precision target result =
    case result of
        Ok float ->
            float |> Expect.within precision target

        Err err ->
            Expect.fail err


createServerRequest : StaticDb.Db -> String -> Encode.Value -> String -> Request
createServerRequest dbs method body url =
    let
        encode encoder =
            Encode.list encoder >> Encode.encode 0
    in
    { body = body
    , jsResponseHandler = Encode.null
    , method = method
    , processes =
        { foodProcesses = dbs.processes |> encode Process.encode
        , objectProcesses = dbs.processes |> encode Process.encode
        , textileProcesses = dbs.processes |> encode Process.encode
        }
    , url = url
    }
