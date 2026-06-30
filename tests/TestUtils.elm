module TestUtils exposing
    ( asTest
    , createServerRequest
    , expectImpactsEqual
    , expectResultErrorContains
    , expectResultWithin
    , it
    , itFromResult
    , itFromResult2
    , jupeCotonAsie
    , suiteFromResult
    , suiteFromResult2
    , suiteFromResult3
    , suiteFromResult4
    , suiteWithDb
    , tShirtCotonFrance
    )

import Data.Country as Country
import Data.Db exposing (Db)
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
import Static.Db as StaticDb
import Static.Json as StaticJson
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest =
    it


it : String -> Expectation -> Test
it label =
    always >> test label


itFromResult : String -> Result String a -> (a -> Expectation) -> Test
itFromResult label result fn =
    case result of
        Ok value ->
            it label (fn value)

        Err error ->
            it (label ++ " setup result failure") (Expect.fail error)


itFromResult2 : String -> Result String a -> Result String b -> (a -> b -> Expectation) -> Test
itFromResult2 label result1 result2 fn =
    case Result.map2 fn result1 result2 of
        Ok expectation ->
            it label expectation

        Err error ->
            it (label ++ " setup result failure") (Expect.fail error)


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


suiteFromResult4 : String -> Result String a -> Result String b -> Result String c -> Result String d -> (a -> b -> c -> d -> List Test) -> Test
suiteFromResult4 testName res1 res2 res3 res4 fn =
    suiteFromResult testName (Result.map4 fn res1 res2 res3 res4) identity


suiteWithDb : String -> (Db -> List Test) -> Test
suiteWithDb name suite =
    case StaticDb.dbFromStaticFiles StaticJson.processesJson of
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
    Db
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
                          , country = Nothing
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
                    | countryDyeing = Just (Country.Code "FR")
                    , countryFabric = Just (Country.Code "FR")
                    , countryMaking = Just (Country.Code "FR")
                    , countrySpinning = Just (Country.Code "FR")
                }
            )
