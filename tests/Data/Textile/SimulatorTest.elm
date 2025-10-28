module Data.Textile.SimulatorTest exposing (..)

import Data.Component as Component
import Data.Country as Country
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Textile.Economics as Economics
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Expect exposing (Expectation)
import Json.Decode as Decode
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (asTest, suiteFromResult, suiteWithDb, tShirtCotonFrance)


getImpact : Db -> Definition.Trigram -> Query -> Result String Float
getImpact db trigram query =
    -- Note: Tesxtile trims use the default component config which only provide production stage impacts.
    Component.defaultConfig db.processes
        |> Result.andThen
            (\config ->
                query
                    |> Simulator.compute db config
                    |> Result.map
                        (.impacts
                            >> Impact.getImpact trigram
                            >> Unit.impactToFloat
                        )
            )


expectImpact : Db -> Definition.Trigram -> Float -> Query -> Expectation
expectImpact db trigram value query =
    case getImpact db trigram query of
        Ok result ->
            result
                |> Expect.within (Expect.Absolute 0.01) value

        Err error ->
            Expect.fail error


ecs : Definition.Trigram
ecs =
    Definition.Ecs


computeWithDefaultComponentConfig : Db -> Query -> Result String Simulator
computeWithDefaultComponentConfig db query =
    -- Note: Tesxtile trims use the default component config which only provide production stage impacts.
    Component.defaultConfig db.processes
        |> Result.andThen (\config -> query |> Simulator.compute db config)


suite : Test
suite =
    suiteWithDb "Data.Textile.Simulator"
        (\db ->
            [ describe "Simulator.compute"
                [ suiteFromResult "should compute a simulation ecs impact"
                    tShirtCotonFrance
                    (\query ->
                        [ { query
                            | countrySpinning = Nothing
                          }
                            |> expectImpact db ecs 1290.7
                            |> asTest "compute a simulation ecs impact"
                        ]
                    )
                , describe "disabled steps"
                    [ suiteFromResult "should be handled from passed query"
                        tShirtCotonFrance
                        (\query ->
                            [ { query | disabledSteps = [ Label.Ennobling ] }
                                |> computeWithDefaultComponentConfig db
                                |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Ennobling .enabled True)
                                |> Expect.equal (Ok False)
                                |> asTest "be handled from passed query"
                            ]
                        )
                    , suiteFromResult "should handle disabled steps"
                        tShirtCotonFrance
                        (\query ->
                            [ asTest "handle disabled steps"
                                (case
                                    ( getImpact db ecs query
                                    , getImpact db ecs { query | disabledSteps = [ Label.Ennobling ] }
                                    )
                                 of
                                    ( Ok full, Ok partial ) ->
                                        full |> Expect.greaterThan partial

                                    _ ->
                                        Expect.fail "bogus simulator results"
                                )
                            ]
                        )
                    , suiteFromResult "should allow disabling steps"
                        tShirtCotonFrance
                        (\query ->
                            [ asTest "allow disabling steps"
                                (case
                                    ( getImpact db ecs query
                                    , getImpact db ecs { query | disabledSteps = [ Label.Ennobling ] }
                                    )
                                 of
                                    ( Ok full, Ok partial ) ->
                                        full |> Expect.greaterThan partial

                                    _ ->
                                        Expect.fail "bogus simulator results"
                                )
                            ]
                        )
                    ]
                ]
            , describe "compute holistic durability"
                [ suiteFromResult "should have default durability"
                    tShirtCotonFrance
                    (\query ->
                        [ query
                            |> computeWithDefaultComponentConfig db
                            |> Result.map .durability
                            |> Expect.equal (Ok { physical = Unit.physicalDurability 1.45, nonPhysical = Unit.nonPhysicalDurability 0.67 })
                            |> asTest "have default durability"
                        ]
                    )
                , asTest "take the min of the two durabilities"
                    ({ physical = Unit.physicalDurability 1.45, nonPhysical = Unit.nonPhysicalDurability 0.67 }
                        |> Unit.floatDurabilityFromHolistic
                        |> Expect.within (Expect.Absolute 0.001) 0.67
                    )
                , suiteFromResult "should take into account when non physical durability changes"
                    tShirtCotonFrance
                    (\query ->
                        let
                            tShirtCotonWithSmallerPhysicalDurability =
                                { query
                                    | numberOfReferences = Just 10
                                    , price = Just <| Economics.priceFromFloat 100
                                    , physicalDurability = Just <| Unit.physicalDurability 1
                                }
                        in
                        [ tShirtCotonWithSmallerPhysicalDurability
                            |> computeWithDefaultComponentConfig db
                            |> Result.map .durability
                            |> Expect.equal (Ok { physical = Unit.physicalDurability 1, nonPhysical = Unit.nonPhysicalDurability 1.32 })
                            |> asTest "take into account when non physical durability changes"
                        , tShirtCotonWithSmallerPhysicalDurability
                            |> computeWithDefaultComponentConfig db
                            |> Result.map (.durability >> Unit.floatDurabilityFromHolistic)
                            |> Expect.equal (Ok 1)
                            |> asTest "return non physical durability if it is the smallest"
                        ]
                    )
                ]
            , describe "compute airTransportRatio"
                [ suiteFromResult "should be zero for products from Europe or Turkey"
                    tShirtCotonFrance
                    (\query ->
                        [ query
                            |> computeWithDefaultComponentConfig db
                            |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Making .airTransportRatio Split.half)
                            |> Expect.equal (Ok Split.zero)
                            |> asTest "be zero for products from Europe or Turkey"
                        ]
                    )
                , suiteFromResult "should be full for products not coming from Europe or Turkey"
                    tShirtCotonFrance
                    (\query ->
                        [ { query | countryMaking = Just (Country.Code "CN") }
                            |> computeWithDefaultComponentConfig db
                            |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Making .airTransportRatio Split.half)
                            |> Expect.equal (Ok Split.full)
                            |> asTest "be full for products not coming from Europe or Turkey"
                        ]
                    )
                , suiteFromResult "should be 0.33 for products not coming from Europe or Turkey but with a durability >= 1"
                    tShirtCotonFrance
                    (\query ->
                        let
                            tShirtCotonWithSmallerPhysicalDurabilityCn =
                                { query
                                    | numberOfReferences = Just 10
                                    , price = Just <| Economics.priceFromFloat 100
                                    , physicalDurability = Just <| Unit.physicalDurability 1.1
                                    , countryMaking = Just (Country.Code "CN")
                                }
                        in
                        [ tShirtCotonWithSmallerPhysicalDurabilityCn
                            |> computeWithDefaultComponentConfig db
                            |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Making .airTransportRatio Split.half)
                            |> Expect.equal (Ok Split.third)
                            |> asTest "be 0.33 for products not coming from Europe or Turkey but with a durability >= 1"
                        ]
                    )
                , suiteFromResult "should keep the user provided value"
                    tShirtCotonFrance
                    (\query ->
                        [ { query
                            | countryMaking = Just (Country.Code "CN")
                            , airTransportRatio = Just Split.two
                          }
                            |> computeWithDefaultComponentConfig db
                            |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Making .airTransportRatio Split.half)
                            |> Expect.equal (Ok Split.two)
                            |> asTest "keep the user provided value"
                        ]
                    )
                ]
            , describe "getTotalImpactsWithoutComplements"
                [ suiteFromResult "should compute total impacts without complements"
                    tShirtCotonFrance
                    (\query ->
                        [ -- Note: Tesxtile trims use the default component config which only provide production stage impacts.
                          Component.defaultConfig db.processes
                            |> Result.andThen
                                (\config ->
                                    query |> Simulator.compute db config
                                )
                            |> Result.map
                                (Simulator.getTotalImpactsWithoutComplements
                                    >> Impact.getImpact Definition.Ecs
                                    >> Unit.impactToFloat
                                )
                            |> Result.withDefault 0
                            |> Expect.greaterThan 0
                            |> asTest "compute total impacts without complements"
                        ]
                    )
                ]
            , describe "Simulator.getTotalImpactsWithoutDurability" <|
                let
                    testCalc expectation jsonQuery =
                        case
                            jsonQuery
                                |> Decode.decodeString Query.decode
                                |> Result.mapError Decode.errorToString
                                |> Result.andThen (computeWithDefaultComponentConfig db)
                                |> Result.map
                                    (\simulator ->
                                        ( simulator.impacts |> Impact.getImpact Definition.Ecs |> Unit.impactToFloat
                                        , Simulator.getTotalImpactsWithoutDurability simulator |> Impact.getImpact Definition.Ecs |> Unit.impactToFloat
                                        )
                                    )
                        of
                            Err err ->
                                Expect.fail err

                            Ok ( withDurability, withoutDurability ) ->
                                expectation (Expect.Absolute 0.001) withDurability withoutDurability
                in
                [ -- This example gives a durability index different from 1, ecoscores should differ
                  """ {
                          "business": "small-business",
                          "countrySpinning": "MA",
                          "mass": 0.3,
                          "materials": [
                              {
                                  "id": "1fc3e17d-5661-429d-a150-7986eae16d9d",
                                  "share": 1
                              }
                          ],
                          "numberOfReferences": 10000000,
                          "physicalDurability": 1,
                          "price": 2,
                          "product": "pull",
                          "trims": [],
                          "upcycled": false
                      }
                    """
                    |> testCalc Expect.notWithin
                    |> asTest "compute impacts without durability when durability isn't 1"
                , -- This example gives a durability index of 1, so ecoscores with and without
                  -- durability should be strictly equivalent
                  """ {
                          "business": "small-business",
                          "countrySpinning": "MA",
                          "mass": 0.3,
                          "materials": [
                              {
                                  "id": "1fc3e17d-5661-429d-a150-7986eae16d9d",
                                  "share": 1
                              }
                          ],
                          "numberOfReferences": 10054,
                          "physicalDurability": 1,
                          "price": 37,
                          "product": "pull",
                          "trims": [
                              {
                                  "id": "0c903fc7-279b-4375-8cfa-ca8133b8e973",
                                  "quantity": 10
                              }
                          ],
                          "upcycled": false
                      }
                    """
                    |> testCalc Expect.within
                    |> asTest "compute impacts without durability when durability is 1"
                ]
            ]
        )
