module Views.ComparatorTest exposing (suite)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Complement as Complement
import Data.Component as Component
import Data.Db exposing (Db)
import Data.Process as Process
import Data.Scope as Scope
import Data.Unit as Unit
import Expect exposing (Expectation)
import Json.Decode as Decode
import Test exposing (..)
import TestUtils
    exposing
        ( componentConfig
        , expectFloatDifferent
        , expectFloatMostlyEqual
        , expectResultMostlyEqual
        , itFromResult
        , suiteFromResult2
        , suiteWithDb
        )
import Time
import Views.Comparator as Comparator


suite : Test
suite =
    suiteWithDb "Views.Comparator" <|
        \db ->
            [ suiteFromResult2 "complements"
                (componentConfig db)
                (cookedHamBookmark db)
                (\config bookmark ->
                    let
                        reqs =
                            { componentConfig = config, db = db }

                        charts =
                            Result.map4
                                (\individual subscores stages total ->
                                    { individual = individual
                                    , stages = stages
                                    , subscores = subscores
                                    , total = total
                                    }
                                )
                                (bookmark |> Comparator.chartSeries reqs Comparator.IndividualImpacts)
                                (bookmark |> Comparator.chartSeries reqs Comparator.Subscores)
                                (bookmark |> Comparator.chartSeries reqs Comparator.Stages)
                                (bookmark |> Comparator.chartSeries reqs Comparator.Total)
                    in
                    [ itFromResult "should show food2 complements on the comparator charts"
                        (charts
                            |> Result.map2 Tuple.pair (cookedHamComplements db)
                        )
                        (\( expected, series ) ->
                            Expect.all
                                [ \_ ->
                                    expected
                                        |> expectFloatDifferent 0
                                , \_ ->
                                    series.individual
                                        |> chartEntryValue "Services écosystémiques"
                                        |> expectResultMostlyEqual expected
                                , \_ ->
                                    series.subscores
                                        |> chartEntryValue "Compléments"
                                        |> expectResultMostlyEqual expected
                                , \_ ->
                                    expectComplementsCountedOnce series
                                ]
                                ()
                        )
                    ]
                )
            ]


chartEntryValue : String -> List { name : String, value : Float } -> Result String Float
chartEntryValue name entries =
    case List.filter (\entry -> entry.name == name) entries of
        [ entry ] ->
            Ok entry.value

        _ ->
            Err <| "Missing chart entry: " ++ name


cookedHamBookmark : Db -> Result String Bookmark
cookedHamBookmark db =
    -- 1 kg, so chart complements stay equal to the per kg metadata
    """
    {
      "components": [
        {
          "elements": [
            {
              "amount": 1,
              "material": { "country": "FR", "id": "{cookedHamProcessId}" }
            }
          ],
          "quantity": 1
        }
      ]
    }
    """
        |> String.replace "{cookedHamProcessId}" cookedHamProcessId
        |> Decode.decodeString (Component.decodeQuery db.processes)
        |> Result.mapError Decode.errorToString
        |> Result.map
            (\query ->
                { created = Time.millisToPosix 0
                , genericScope = Just Scope.Food2
                , name = "Test bookmark"
                , query = Bookmark.Generic Scope.Food2 query
                }
            )


cookedHamProcessId : String
cookedHamProcessId =
    "755225f1-f0c5-497f-b8a9-263828a84a22"


cookedHamComplements : Db -> Result String Float
cookedHamComplements db =
    Process.idFromString cookedHamProcessId
        |> Result.andThen (\id -> Process.findById id db.processes)
        |> Result.andThen
            (\process ->
                process.metadata
                    |> Maybe.andThen .complements
                    |> Result.fromMaybe "Missing expected complements"
                    |> Result.map (Complement.getTotalComplementsImpacts >> Unit.impactToFloat)
            )


expectComplementsCountedOnce :
    { a
        | stages : List { name : String, value : Float }
        , subscores : List { name : String, value : Float }
        , total : List { name : String, value : Float }
    }
    -> Expectation
expectComplementsCountedOnce { stages, subscores, total } =
    case
        ( chartEntryValue "Compléments" subscores
        , chartEntryValue "Impact total" total
        )
    of
        ( Ok complements, Ok totalValue ) ->
            totalValue
                |> expectFloatMostlyEqual (List.sum (List.map .value stages) + complements)

        ( Err error, _ ) ->
            Expect.fail error

        ( Ok _, Err error ) ->
            Expect.fail error
