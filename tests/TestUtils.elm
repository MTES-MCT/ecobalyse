module TestUtils exposing
    ( asTest
    , createServerRequest
    , expectImpactsEqual
    , suiteWithDb
    )

import Data.Food.Process as FoodProcess
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Trigrams)
import Data.Object.Process as ObjectProcess
import Data.Textile.Process as TextileProcess
import Data.Unit as Unit
import Expect exposing (Expectation)
import Json.Encode as Encode
import Server.Request exposing (Request)
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
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
        { foodProcesses = dbs.food.processes |> encode FoodProcess.encode
        , objectProcesses = dbs.object.processes |> encode ObjectProcess.encode
        , textileProcesses = dbs.textile.processes |> encode TextileProcess.encode
        }
    , url = url
    }
