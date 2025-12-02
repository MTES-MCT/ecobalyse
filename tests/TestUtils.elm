module TestUtils exposing
    ( asTest
    , createServerRequest
    , expectImpactsEqual
    , expectResultErrorContains
    , expectResultWithin
    , it
    , jupeCotonAsie
    , suiteFromResult
    , suiteFromResult2
    , suiteFromResult3
    , suiteWithDb
    , tShirtCotonFrance
    )

import Data.Geozone as Geozone
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Trigrams)
import Data.Process as Process
import Data.Split as Split
import Data.Textile.Fabric as Fabric
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query as TextileQuery
import Data.Unit as Unit
import Expect exposing (Expectation, FloatingPointTolerance)
import Json.Encode as Encode
import Mass
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


suiteFromResult : String -> Result String a -> (a -> List Test) -> Test
suiteFromResult testName res fn =
    describe testName <|
        case res of
            Ok val ->
                fn val

            Err err ->
                Expect.fail err
                    |> it (testName ++ " setup result failure")
                    |> List.singleton


suiteFromResult2 : String -> Result String a -> Result String b -> (a -> b -> List Test) -> Test
suiteFromResult2 testName res1 res2 fn =
    suiteFromResult testName (Result.map2 fn res1 res2) identity


suiteFromResult3 : String -> Result String a -> Result String b -> Result String c -> (a -> b -> c -> List Test) -> Test
suiteFromResult3 testName res1 res2 res3 fn =
    suiteFromResult testName (Result.map3 fn res1 res2 res3) identity


suiteWithDb : String -> (Db -> List Test) -> Test
suiteWithDb name suite =
    case StaticDb.db StaticJson.processesJson of
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


createServerRequest :
    StaticDb.Db
    -> { method : String, protocol : String, host : String, url : String, version : Maybe String }
    -> Encode.Value
    -> Request
createServerRequest dbs { method, protocol, host, url, version } body =
    let
        encode encoder =
            Encode.list encoder >> Encode.encode 0
    in
    { body = body
    , host = host
    , jsResponseHandler = Encode.null
    , method = method
    , processes = dbs.processes |> encode Process.encode
    , protocol = protocol
    , url = url
    , version = version
    }


textileQueryFromMaterialId : String -> Result String TextileQuery.Query
textileQueryFromMaterialId id =
    let
        default =
            TextileQuery.default
    in
    Material.idFromString id
        |> Result.map
            (\id_ ->
                { default
                    | materials =
                        [ { id = id_
                          , share = Split.full
                          , spinning = Nothing
                          , geozone = Nothing
                          }
                        ]
                }
            )


jupeCotonAsie : Result String TextileQuery.Query
jupeCotonAsie =
    textileQueryFromMaterialId "457e9b0d-9eda-4dca-b199-deeb0a154fa9"
        |> Result.map
            (\query ->
                { query
                    | fabricProcess = Just Fabric.Weaving
                    , mass = Mass.kilograms 0.3
                    , product = Product.Id "jupe"
                }
            )


tShirtCotonFrance : Result String TextileQuery.Query
tShirtCotonFrance =
    textileQueryFromMaterialId "62a4d6fb-3276-4ba5-93a3-889ecd3bff84"
        |> Result.map
            (\query ->
                { query
                    | geozoneDyeing = Just (Geozone.Code "FR")
                    , geozoneFabric = Just (Geozone.Code "FR")
                    , geozoneMaking = Just (Geozone.Code "FR")
                    , geozoneSpinning = Just (Geozone.Code "FR")
                }
            )
