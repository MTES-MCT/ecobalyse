module Data.ComponentTest exposing (..)

import Data.Complement as Complement
import Data.Component as Component
    exposing
        ( Component
        , Item
        , LifeCycle
        , Requirements
        , defaultTransportOptions
        , emptyAssembly
        , emptyQuery
        )
import Data.Component.Amount as Amount
import Data.Component.ProductCategory as Product exposing (ProductCategory)
import Data.Country as Country
import Data.Country.Code as CountryCode
import Data.Db exposing (Db)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category
import Data.Scope as Scope
import Data.Split as Split
import Data.Transport as Transport
import Data.Unit as Unit
import Dict.Any as AnyDict
import Expect
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length
import List.Extra as LE
import Mass
import Quantity
import Result.Extra as RE
import Test exposing (..)
import TestUtils
    exposing
        ( expectFloatDifferent
        , expectFloatMostlyEqual
        , expectResultErrorContains
        , it
        , itFromResult
        , itFromResult2
        , suiteFromResult
        , suiteFromResult2
        , suiteFromResult3
        , suiteFromResult4
        , suiteWithDb
        )
import Volume


suite : Test
suite =
    suiteWithDb "Data.Component" <|
        \originalDb ->
            let
                -- these will be adapted and used as test transform processes
                ( fading, weaving ) =
                    ( originalDb.textile.wellKnown.fading
                    , originalDb.textile.wellKnown.weaving
                    )

                db =
                    setupTestDb originalDb
            in
            [ suiteFromResult "setupRequirements"
                (createTestRequirements db)
                (\requirements ->
                    [ suiteFromResult3 "addElement"
                        -- setup
                        chairBack
                        steel
                        injectionMoulding
                        -- tests
                        (\testComponent validMaterial invalidMaterial ->
                            [ itFromResult "should add a new element using a valid material"
                                (chair
                                    |> Result.andThen (Component.addElement ( testComponent, 1 ) validMaterial)
                                    |> Result.map
                                        (\items ->
                                            items
                                                -- get second component item
                                                |> LE.getAt 1
                                                -- access its custom property
                                                |> Maybe.andThen .custom
                                                -- access the second element
                                                |> Maybe.andThen (.elements >> LE.getAt 1)
                                                -- and its material process id
                                                |> Maybe.map (.material >> .id)
                                        )
                                )
                                -- it should be equal to the one we swapped in
                                (Expect.equal (Just validMaterial.id))
                            , it "should reject an invalid element material"
                                (chair
                                    |> Result.andThen (Component.addElement ( testComponent, 1 ) invalidMaterial)
                                    |> expectResultErrorContains "L'ajout d'un élément ne peut se faire qu'à partir d'un procédé matière"
                                )
                            ]
                        )
                    , suiteFromResult3 "addElementTransform"
                        -- setup
                        chairBack
                        injectionMoulding
                        wood
                        -- tests
                        (\testComponent validTransformProcess invalidTransformProcess ->
                            [ itFromResult "should add a valid transformation process to a component element"
                                (chair
                                    |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) Nothing validTransformProcess)
                                    |> Result.map
                                        (\items ->
                                            items
                                                -- get second component item
                                                |> LE.getAt 1
                                                -- access its custom property
                                                |> Maybe.andThen .custom
                                                -- access the first element
                                                |> Maybe.andThen (.elements >> LE.getAt 0)
                                                -- and its material process id
                                                |> Maybe.map .transforms
                                        )
                                )
                                (Expect.equal (Just [ Component.nonLocalizedProcess validTransformProcess.id ]))
                            , it "should reject an invalid transformation process"
                                (chair
                                    |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) Nothing invalidTransformProcess)
                                    |> expectResultErrorContains "Seuls les procédés de catégorie `transformation` sont mobilisables comme procédés de transformation"
                                )
                            ]
                        )
                    , suiteFromResult3 "addOrSetProcess transform default country"
                        chairBack
                        injectionMoulding
                        sawing
                        (\testComponent firstTransform secondTransform ->
                            let
                                targetItem =
                                    ( testComponent, 0 )

                                itemsWithMaterialCountry =
                                    decodeJson (Decode.list Component.decodeItem) <|
                                        """ [ { "quantity": 1, "custom": { "name": "Test", "elements": [
                                            { "amount": 1, "material": { "id": "6527710e-2434-5347-9bef-2205e0aa4f66", "country": "FR" }, "transforms": [] }
                                        ] } } ] """

                                itemsWithExistingTransform =
                                    decodeJson (Decode.list Component.decodeItem) <|
                                        """ [ { "quantity": 1, "custom": { "name": "Test", "elements": [
                                            { "amount": 1, "material": { "id": "6527710e-2434-5347-9bef-2205e0aa4f66", "country": "FR" }, "transforms": [
                                                { "id": "111539de-deea-588a-9581-6f6ceaa2dfa9", "country": "DE" }
                                            ] }
                                        ] } } ] """
                            in
                            [ itFromResult "should default a new transform country to the element material country"
                                (itemsWithMaterialCountry
                                    |> Result.andThen (Component.addOrSetProcess requirements.db Category.Transform targetItem (Just 0) firstTransform)
                                    |> Result.map (elementTransformCountryAt 0 0 0)
                                )
                                (Expect.equal (Just CountryCode.france))
                            , itFromResult "should default a new transform country to the last transform country"
                                (itemsWithExistingTransform
                                    |> Result.andThen (Component.addOrSetProcess requirements.db Category.Transform targetItem (Just 0) secondTransform)
                                    |> Result.map (elementTransformCountryAt 0 0 1)
                                )
                                (Expect.equal (Just (CountryCode.fromString "DE")))
                            ]
                        )
                    , suiteFromResult "addItem"
                        chairBack
                        (\testComponent ->
                            [ it "should allow adding the same component twice"
                                ([]
                                    |> Component.addItem testComponent.id
                                    |> Component.addItem testComponent.id
                                    |> List.length
                                    |> Expect.equal 2
                                )
                            ]
                        )
                    , describe "applyTransforms"
                        [ let
                            getTestMass transforms =
                                Component.Results
                                    { amount = Amount.fromFloat 1
                                    , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                    , impacts = Impact.empty
                                    , items = []
                                    , label = Nothing
                                    , mass = Mass.kilogram
                                    , materialType = Nothing
                                    , quantity = 1
                                    , stage = Nothing
                                    }
                                    |> Component.applyTransforms requirements
                                        defaultTransportOptions
                                        Nothing
                                        Process.Kilogram
                                        (List.map Component.nonLocalizedExpandedProcess transforms)
                                    |> Result.withDefault Component.emptyResults
                                    |> Component.extractMass
                                    |> Mass.inKilograms
                          in
                          describe "qtyVariationRatio"
                            [ it "should not apply any quantity variation ratio when no transforms are passed"
                                (getTestMass []
                                    |> Expect.within (Expect.Absolute 0.00001) 1
                                )
                            , it "should apply quantity variation ratio when one transform is passed"
                                (getTestMass [ { weaving | qtyVariationRatio = Unit.qtyVariationRatio 0.2 } ]
                                    |> Expect.within (Expect.Absolute 0.00001) 0.2
                                )
                            , it "should apply quantity variation superior to 1"
                                (getTestMass [ { weaving | qtyVariationRatio = Unit.qtyVariationRatio 2 } ]
                                    |> Expect.within (Expect.Absolute 0.00001) 2
                                )
                            , it "should apply quantity variation ratio sequentially when multiple transforms are passed"
                                (getTestMass
                                    [ { weaving | qtyVariationRatio = Unit.qtyVariationRatio 0.5 }
                                    , { weaving | qtyVariationRatio = Unit.qtyVariationRatio 0.5 }
                                    ]
                                    |> Expect.within (Expect.Absolute 0.00001) 0.25
                                )
                            ]
                        , let
                            getTestEcsImpact transforms =
                                Component.Results
                                    { amount = Amount.fromFloat 1
                                    , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                    , impacts = Impact.empty
                                    , items = []
                                    , label = Nothing
                                    , mass = Mass.kilogram
                                    , materialType = Nothing
                                    , quantity = 1
                                    , stage = Nothing
                                    }
                                    |> Component.applyTransforms requirements
                                        defaultTransportOptions
                                        Nothing
                                        Process.Kilogram
                                        (List.map Component.nonLocalizedExpandedProcess transforms)
                                    |> Result.withDefault Component.emptyResults
                                    |> extractEcsImpact
                          in
                          describe "impacts"
                            [ it "should not add impacts when no transforms are passed"
                                (getTestEcsImpact []
                                    |> Expect.within (Expect.Absolute 0.00001) 0
                                )
                            , it "should add impacts when one transform is passed (no elec, no heat)"
                                (getTestEcsImpact
                                    [ fading
                                        |> resetProcessElecAndHeat
                                        |> setProcessEcsImpact (Unit.impact 10)
                                    ]
                                    |> Expect.within (Expect.Absolute 1) 95
                                )
                            , it "should add impacts when one transform is passed (including elec and heat)"
                                (getTestEcsImpact
                                    [ { fading
                                        | impacts =
                                            fading.impacts
                                                |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                                      }
                                    ]
                                    |> Expect.within (Expect.Absolute 1) 505
                                )
                            , itFromResult "should compute apply custom mix impacts when a transform step country is set"
                                -- fetch first country with mixes different from defaults
                                (requirements.db.countries
                                    |> Scope.anyOf [ requirements.scope ]
                                    |> List.filter
                                        (\{ electricityProcess, heatProcess } ->
                                            (electricityProcess /= requirements.config.production.defaultElecProcess)
                                                || (heatProcess /= requirements.config.production.defaultHeatProcess)
                                        )
                                    |> List.head
                                    |> Result.fromMaybe "No country found with mixes different from defaults"
                                )
                                (\country ->
                                    let
                                        getImpact steps =
                                            Component.Results
                                                { amount = Amount.fromFloat 1
                                                , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                                , impacts = Impact.empty
                                                , items = []
                                                , label = Nothing
                                                , mass = Mass.kilogram
                                                , materialType = Nothing
                                                , quantity = 1
                                                , stage = Nothing
                                                }
                                                |> Component.applyTransforms requirements
                                                    defaultTransportOptions
                                                    Nothing
                                                    Process.Kilogram
                                                    steps
                                                |> Result.withDefault Component.emptyResults
                                                |> extractEcsImpact

                                        ( defaultImpact, localizedImpact ) =
                                            ( getImpact [ Component.nonLocalizedExpandedProcess fading ]
                                            , getImpact [ { country = Just country, process = fading } ]
                                            )
                                    in
                                    expectFloatDifferent defaultImpact localizedImpact
                                )
                            , it "should add impacts when multiple transforms are passed (no elec, no heat)"
                                (getTestEcsImpact
                                    [ fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 10)
                                    , fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 20)
                                    ]
                                    |> Expect.within (Expect.Absolute 1) 200
                                )
                            , it "should add impacts when multiple transforms are passed (including elec and heat)"
                                (getTestEcsImpact
                                    [ fading |> setProcessEcsImpact (Unit.impact 10)
                                    , fading |> setProcessEcsImpact (Unit.impact 20)
                                    ]
                                    |> Expect.within (Expect.Absolute 1) 1020
                                )
                            ]
                        , suiteFromResult "unit mismatch"
                            injectionMoulding
                            (\transformInKg ->
                                [ it "should reject when the unit of the material and the transforms do not match"
                                    (Component.Results
                                        { amount = Amount.fromFloat 1
                                        , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                        , impacts = Impact.empty
                                        , items = []
                                        , label = Nothing
                                        , mass = Mass.kilogram
                                        , materialType = Nothing
                                        , quantity = 1
                                        , stage = Nothing
                                        }
                                        |> Component.applyTransforms requirements
                                            defaultTransportOptions
                                            Nothing
                                            Process.CubicMeter
                                            [ Component.nonLocalizedExpandedProcess transformInKg ]
                                        |> Expect.equal (Err "Les procédés de transformation ne partagent pas la même unité que la matière source (m3)\u{00A0}: Moulage par injection (kg)")
                                    )
                                ]
                            )
                        , let
                            getTestResults transforms =
                                Component.Results
                                    { amount = Amount.fromFloat 1
                                    , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                    , impacts = Impact.empty |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 100)
                                    , items = []
                                    , label = Nothing
                                    , mass = Mass.kilogram
                                    , materialType = Nothing
                                    , quantity = 1
                                    , stage = Nothing
                                    }
                                    |> Component.applyTransforms requirements
                                        defaultTransportOptions
                                        Nothing
                                        Process.Kilogram
                                        (List.map Component.nonLocalizedExpandedProcess transforms)
                                    |> Result.withDefault Component.emptyResults
                          in
                          describe "impacts & qtyVariationRatio"
                            [ let
                                noElecAndNoHeat =
                                    getTestResults
                                        [ fading
                                            |> resetProcessElecAndHeat
                                            |> setProcessQtyVariationRatio (Unit.qtyVariationRatio 0.5)
                                            |> setProcessEcsImpact (Unit.impact 10)
                                        , fading
                                            |> resetProcessElecAndHeat
                                            |> setProcessQtyVariationRatio (Unit.qtyVariationRatio 0.5)
                                            |> setProcessEcsImpact (Unit.impact 20)
                                        ]
                              in
                              describe "excluding elec and heat"
                                [ -- Note: impacts are always computed from input mass
                                  -- 100 + (1kg * 10) + (0.5kg * 20) = 120
                                  it "should handle impacts+qtyVariationRatio when applying transforms: impacts"
                                    (noElecAndNoHeat
                                        |> extractEcsImpact
                                        |> Expect.within (Expect.Absolute 1) 247
                                    )

                                -- (1kg * 0.5) * 0.5 == 0.25
                                , it "should handle impacts+qtyVariationRatio when applying transforms: mass"
                                    (noElecAndNoHeat
                                        |> Component.extractMass
                                        |> Mass.inKilograms
                                        |> Expect.within (Expect.Absolute 0.01) 0.25
                                    )
                                ]
                            , let
                                withElecAndHeat =
                                    getTestResults
                                        [ fading
                                            |> setProcessQtyVariationRatio (Unit.qtyVariationRatio 0.5)
                                            |> setProcessEcsImpact (Unit.impact 10)
                                        , fading
                                            |> setProcessQtyVariationRatio (Unit.qtyVariationRatio 0.5)
                                            |> setProcessEcsImpact (Unit.impact 20)
                                        ]
                              in
                              describe "including elec and heat"
                                [ it "should handle impacts+qtyVariationRatio when applying transforms: impacts"
                                    (withElecAndHeat
                                        |> extractEcsImpact
                                        |> Expect.within (Expect.Absolute 1) 862
                                    )
                                , it "should handle impacts+qtyVariationRatio when applying transforms: mass"
                                    (withElecAndHeat
                                        |> Component.extractMass
                                        |> Mass.inKilograms
                                        |> Expect.within (Expect.Absolute 0.01) 0.25
                                    )
                                ]
                            ]
                        , describe "transports" <|
                            let
                                extractTransportStagesCount kind results =
                                    results
                                        |> Component.extractItems
                                        |> List.filter (Component.extractStage >> (==) (Just kind))
                                        |> List.length

                                extractStages results =
                                    results
                                        |> Component.extractItems
                                        |> List.filterMap Component.extractStage

                                getResults cooling localizedTransforms =
                                    Component.Results
                                        { amount = Amount.fromFloat 1
                                        , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                        , impacts = Impact.empty
                                        , items = []
                                        , label = Nothing
                                        , mass = Mass.kilogram
                                        , materialType = Nothing
                                        , quantity = 1
                                        , stage = Nothing
                                        }
                                        |> Component.applyTransforms requirements
                                            cooling
                                            Nothing
                                            Process.Kilogram
                                            localizedTransforms
                                        |> Result.withDefault Component.emptyResults
                            in
                            [ it "should add one transport stage per transform step"
                                (getResults defaultTransportOptions
                                    [ Component.nonLocalizedExpandedProcess fading
                                    , Component.nonLocalizedExpandedProcess fading
                                    ]
                                    |> extractTransportStagesCount Component.TransportStage
                                    |> Expect.equal 2
                                )
                            , it "should add no transport stage when no transform is applied"
                                (getResults defaultTransportOptions []
                                    |> extractTransportStagesCount Component.TransportStage
                                    |> Expect.equal 0
                                )
                            , it "should insert transport before each transform stage"
                                (getResults defaultTransportOptions
                                    [ Component.nonLocalizedExpandedProcess fading
                                    , Component.nonLocalizedExpandedProcess fading
                                    ]
                                    |> extractStages
                                    |> Expect.equal
                                        [ Component.TransportStage
                                        , Component.TransformStage
                                        , Component.TransportStage
                                        , Component.TransformStage
                                        ]
                                )
                            , itFromResult "should never feature air transport for intermediary transport, even when byAir is set"
                                (db.countries |> Country.findByCode CountryCode.france)
                                (\france ->
                                    let
                                        getEcsForByAir byAir =
                                            getResults { defaultTransportOptions | byAir = byAir }
                                                [ { country = Just france, process = fading }
                                                , { country = Just france, process = fading }
                                                ]
                                                |> extractEcsImpact
                                    in
                                    -- forcing air transport ratio to full must not change the result, as it's always
                                    -- reset to zero at the transform step level
                                    getEcsForByAir Split.full
                                        |> Expect.within (Expect.Absolute 0.00001) (getEcsForByAir Split.zero)
                                )
                            ]
                        ]
                    , describe "compute"
                        [ it "should compute results from decoded component items"
                            (chair
                                |> Result.andThen (computeItemsWithRequirements requirements)
                                |> Result.map (.production >> extractEcsImpact)
                                |> TestUtils.expectResultWithin (Expect.Absolute 1) 276
                            )
                        , it "should compute results from decoded component items with custom component elements"
                            ("""[
                                    {
                                        "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                                        "quantity": 4,
                                        "custom": {
                                            "elements": [
                                                {
                                                    "amount": 0.00044,
                                                    "material": "17431e06-2973-516e-b043-be9ad405e4fb",
                                                    "transforms": []
                                                }
                                            ]
                                        }
                                    }
                                    , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                                    , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                ]"""
                                |> decodeJsonThen (Decode.list Component.decodeItem) (computeItemsWithRequirements requirements)
                                |> Result.map (.production >> extractEcsImpact)
                                |> TestUtils.expectResultWithin (Expect.Absolute 1) 282
                            )
                        , suiteFromResult "distribution impacts"
                            -- setup
                            chair
                            -- tests
                            (\chairItems ->
                                let
                                    requirementsDb =
                                        requirements.db
                                in
                                [ suiteFromResult "when no default distribution process is available"
                                    -- setup
                                    (chairItems
                                        |> computeItemsWithRequirements
                                            { requirements
                                                | db =
                                                    { requirementsDb
                                                        | processes =
                                                            requirementsDb.processes
                                                                -- Filter out all distribution processes so we can test a fallback
                                                                |> LE.removeWhen (.categories >> List.member Category.Distribution)
                                                    }
                                            }
                                    )
                                    -- tests
                                    (\lifeCycle ->
                                        [ it "should compute volume"
                                            (lifeCycle.distribution.volume
                                                |> Volume.inCubicMeters
                                                |> Expect.greaterThan 0
                                            )
                                        , it "should expose no process"
                                            (lifeCycle.distribution.process
                                                |> Expect.equal Nothing
                                            )
                                        , it "should compute empty impacts"
                                            (lifeCycle.distribution.impacts
                                                |> Expect.equal Impact.empty
                                            )
                                        ]
                                    )
                                , suiteFromResult "when an explicit distribution process is specified"
                                    -- setup
                                    (requirementsDb.processes
                                        |> List.head
                                        |> Result.fromMaybe "no processes available"
                                        |> Result.map
                                            (\randomProcess ->
                                                let
                                                    -- update a random process to be our test distribution one
                                                    testDistributionProcess =
                                                        { randomProcess
                                                            | categories = [ Category.Distribution ]
                                                            , scopes = [ requirements.scope ]
                                                            , unit = Process.CubicMeter
                                                        }
                                                in
                                                ( testDistributionProcess
                                                , { requirements
                                                    | db =
                                                        { requirementsDb
                                                            | processes = testDistributionProcess :: requirementsDb.processes
                                                        }
                                                  }
                                                )
                                            )
                                    )
                                    -- tests
                                    (\( testDistributionProcess, testRequirements ) ->
                                        [ suiteFromResult "distribution result tests"
                                            (emptyQuery
                                                |> Component.setQueryItems chairItems
                                                |> Component.updateDistribution (Just testDistributionProcess.id)
                                                |> Component.compute testRequirements
                                                |> Result.map .distribution
                                            )
                                            (\distribution ->
                                                [ it "should compute volume"
                                                    (distribution.volume
                                                        |> Volume.inCubicMeters
                                                        |> Expect.greaterThan 0
                                                    )
                                                , it "should expose the process"
                                                    (distribution.process
                                                        |> Expect.equal (Just testDistributionProcess)
                                                    )
                                                , it "should compute non-empty impacts"
                                                    (distribution.impacts
                                                        |> Impact.getImpact Definition.Ecs
                                                        |> Unit.impactToFloat
                                                        |> Expect.greaterThan 0
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                , it "should propagate the error for an unknown explicit distribution process"
                                    -- Non-existing distribution process id
                                    (Process.idFromString nonExistentUuid
                                        |> Result.map
                                            (\missingDistributionId ->
                                                emptyQuery
                                                    |> Component.setQueryItems chairItems
                                                    |> Component.updateDistribution (Just missingDistributionId)
                                                    |> Component.compute requirements
                                            )
                                        |> Result.withDefault (Err "Invalid process id fixture")
                                        |> expectResultErrorContains "Procédé introuvable par id"
                                    )
                                ]
                            )
                        ]
                    , describe "computeElementResults"
                        [ suiteFromResult "basic tests"
                            -- setup
                            (findProcessByLabel requirements "Production de fibres de coton"
                                |> Result.andThen
                                    (\cotton ->
                                        Component.computeElementResults requirements
                                            defaultTransportOptions
                                            { amount = Amount.fromFloat 1
                                            , material = { country = Nothing, id = cotton.id }

                                            -- Note: weaving waste: 0.06253, fading: 0
                                            , transforms =
                                                [ Component.nonLocalizedProcess weaving.id
                                                , Component.nonLocalizedProcess fading.id
                                                ]
                                            }
                                    )
                            )
                            -- tests
                            (\elementResults ->
                                [ it "should compute element impacts"
                                    (elementResults
                                        |> extractEcsImpact
                                        |> Expect.within (Expect.Absolute 1) 2389
                                    )
                                , it "should compute element mass"
                                    (elementResults
                                        |> Component.extractMass
                                        |> Mass.inKilograms
                                        |> Expect.within (Expect.Absolute 0.000001) 1
                                    )
                                ]
                            )
                        , suiteFromResult2 "unit preservation"
                            wood
                            sawing
                            (\materialInCubicMeters transformInCubicMeters ->
                                let
                                    results =
                                        { amount = Amount.fromFloat 1
                                        , material = { country = Nothing, id = materialInCubicMeters.id }
                                        , transforms = [ Component.nonLocalizedProcess transformInCubicMeters.id ]
                                        }
                                            |> Component.computeElementResults requirements defaultTransportOptions
                                in
                                [ it "should compute impacts according on material unit"
                                    (results
                                        |> Result.map extractEcsImpact
                                        |> Result.withDefault 0
                                        |> Expect.within (Expect.Absolute 1) 150882
                                    )
                                , it "should compute mass according on material unit"
                                    (results
                                        |> Result.map (Component.extractMass >> Mass.inKilograms)
                                        |> Result.withDefault 0
                                        |> Expect.within (Expect.Absolute 1) 660
                                    )
                                ]
                            )
                        , suiteFromResult2 "compute metadata complements"
                            wood
                            sawing
                            (\materialInCubicMeters transformInCubicMeters ->
                                let
                                    results =
                                        { amount = Amount.fromFloat 1
                                        , material = { country = Nothing, id = materialInCubicMeters.id }
                                        , transforms = [ Component.nonLocalizedProcess transformInCubicMeters.id ]
                                        }
                                            |> Component.computeElementResults requirements defaultTransportOptions
                                in
                                [ it "should compute complements impacts according on material unit"
                                    (results
                                        |> Result.map extractComplementEcsImpact
                                        |> Result.withDefault 0
                                        |> Expect.within (Expect.Absolute 0.00001) 1.41462
                                    )
                                ]
                            )
                        ]
                    , describe "computeInitialAmount"
                        [ it "should sequentially apply splits"
                            (Amount.fromFloat 100
                                |> Component.computeInitialAmount [ Unit.qtyVariationRatio 0.8, Unit.qtyVariationRatio 0.5 ]
                                -- 100 / 0.8 / 0.5 = 250
                                |> Expect.equal (Ok <| Amount.fromFloat 250)
                            )
                        , it "should succeed with initial amount when no transforms is applied"
                            (Amount.fromFloat 100
                                |> Component.computeInitialAmount []
                                |> Expect.equal (Ok <| Amount.fromFloat 100)
                            )
                        , it "should error when a quantity variation ratio is 0"
                            (Amount.fromFloat 100
                                |> Component.computeInitialAmount [ Unit.qtyVariationRatio 0 ]
                                |> expectResultErrorContains "Un ratio de variation de quantité ne peut pas être de 0"
                            )
                        ]
                    , describe "computeItemResults"
                        (let
                            toComputedResults =
                                decodeJsonThen Component.decodeItem
                                    (Component.computeItemResults requirements defaultTransportOptions)

                            combineMapBoth_ fn =
                                -- RE.combineMapBoth with fn applied to the two tuple members
                                RE.combineMapBoth fn fn
                         in
                         [ it "should compute item results from a valid input"
                            ("""{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1}"""
                                |> toComputedResults
                                |> Expect.ok
                            )
                         , it "should reject an invalid component id"
                            ("""{"id": "invalid", "quantity": 1}"""
                                |> toComputedResults
                                |> expectResultErrorContains "Not a valid UUID"
                            )
                         , it "should reject an invalid quantity"
                            ("""{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": -1}"""
                                |> toComputedResults
                                |> expectResultErrorContains "La quantité doit être un nombre entier positif"
                            )
                         , it "should reject an non-existent component id"
                            ("""{"id": "b28ff7a0-017c-44b1-b84a-3c7dc1f4fe66", "quantity": 1}"""
                                -- Note: b28ff7a0-017c-44b1-b84a-3c7dc1f4fe66 doesn't exist
                                |> toComputedResults
                                |> expectResultErrorContains "Aucun composant avec id=b28ff7a0-017c-44b1-b84a-3c7dc1f4fe66"
                            )
                         , it "should compute expected custom result impacts"
                            (( -- Original amount (0.00022)
                               """{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1}"""
                               -- Doubling amount (0.00044)
                             , """{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                                    "quantity": 1,
                                    "custom": {
                                      "elements": [
                                        {
                                          "amount": 0.00044,
                                          "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                                        }
                                      ]
                                    }
                                  }"""
                             )
                                |> combineMapBoth_ (toComputedResults >> Result.map extractEcsImpact)
                                |> (\result ->
                                        case result of
                                            Ok ( a, b ) ->
                                                Expect.within (Expect.Absolute 0.00001) b (a * 2)

                                            Err err ->
                                                Expect.fail err
                                   )
                            )
                         , itFromResult "should equal extractMass when quantity is 1"
                            ("""{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1}"""
                                |> toComputedResults
                            )
                            (\results ->
                                Expect.within (Expect.Absolute 0.00001)
                                    (Component.extractUnitMass results |> Mass.inKilograms)
                                    (Component.extractMass results |> Mass.inKilograms)
                            )
                         , itFromResult2 "should keep unit mass unchanged when quantity is scaled"
                            ("""{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1}"""
                                |> toComputedResults
                            )
                            ("""{"id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 2}"""
                                |> toComputedResults
                            )
                            (\unitResults doubledResults ->
                                [ ( Component.extractUnitMass doubledResults |> Mass.inKilograms
                                  , Component.extractUnitMass unitResults |> Mass.inKilograms
                                  )
                                , ( Component.extractMass doubledResults |> Mass.inKilograms
                                  , (Component.extractMass unitResults |> Mass.inKilograms) * 2
                                  )
                                , ( Component.getTotalImpacts doubledResults |> getEcsImpact
                                  , (Component.getTotalImpacts unitResults |> getEcsImpact) * 2
                                  )
                                ]
                                    |> List.map (\( a, b ) -> always <| Expect.within (Expect.Absolute 0.00001) a b)
                                    |> (\expects -> Expect.all expects ())
                            )
                         ]
                        )
                    , describe "computePackagingImpacts"
                        (let
                            computePackagingEcsImpacts packagings =
                                Component.emptyLifeCycle
                                    |> Component.computePackagingImpacts requirements
                                        (emptyQuery |> (\query -> { query | packagings = packagings }))
                                    |> Result.map (.packaging >> List.map getEcsImpact)
                         in
                         [ itFromResult "should compute no packaging impacts for a query without packagings"
                            (computePackagingEcsImpacts [])
                            (Expect.equal [])
                         , itFromResult2 "should compute packaging impacts from their amount"
                            (chipsBag
                                |> Result.map (.impacts >> Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
                            )
                            (chipsBag
                                |> Result.andThen
                                    (\chipsBagProcess ->
                                        computePackagingEcsImpacts
                                            [ Component.packaging (Amount.fromFloat 2) chipsBagProcess.id ]
                                    )
                                |> Result.map (List.head >> Maybe.withDefault -99)
                            )
                            (\chipsBagEcsImpactFloat packagingImpacts ->
                                -- As we added 2 bags, check that the packaging impacts is strictly twice one bag ecs impact
                                Expect.within (Expect.Absolute 0.0001) (2 * chipsBagEcsImpactFloat) packagingImpacts
                            )
                         , it "should propagate the error for an unknown packaging process"
                            -- unknown process id
                            (Process.idFromString nonExistentUuid
                                |> Result.andThen
                                    (\missingPackagingId ->
                                        computePackagingEcsImpacts [ Component.packaging (Amount.fromFloat 1) missingPackagingId ]
                                    )
                                |> expectResultErrorContains "Procédé introuvable par id"
                            )
                         ]
                        )
                    , describe "computeAssemblyImpacts"
                        [ suiteFromResult "should keep product mass unchanged when no assembly operations are defined"
                            ("""{ "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }] }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                |> Result.map
                                    (\lifeCycle ->
                                        ( Component.extractMass lifeCycle.production
                                            |> Mass.inKilograms
                                        , Mass.inKilograms lifeCycle.productMass
                                        , lifeCycle.assembly |> Component.extractImpacts |> getEcsImpact
                                        )
                                    )
                            )
                            (\( productionMass, productMass, assemblyImpact ) ->
                                [ it "should keep product mass unchanged" <|
                                    Expect.within (Expect.Absolute 0.00001) productionMass productMass
                                , it "should keep assembly impacts unchanged" <|
                                    Expect.within (Expect.Absolute 0.00001) assemblyImpact 0
                                ]
                            )
                        , itFromResult "should apply category default assembly operations when computing results"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg"
                                |> Result.andThen
                                    (\categoryProduct ->
                                        """{ "components": [{ "id": "9178fe2e-6944-41d5-ad1b-7abbe8905c48", "quantity": 1 }] }"""
                                            |> decodeJsonThen Component.decodeQuery
                                                (\query ->
                                                    query
                                                        |> Component.updateProduct (Just categoryProduct)
                                                        |> Component.compute requirements
                                                )
                                    )
                            )
                            (Expect.all
                                [ .assembly >> Component.extractItems >> List.length >> Expect.equal 1
                                , .assembly >> Component.extractImpacts >> getEcsImpact >> Expect.greaterThan 0
                                ]
                            )
                        , suiteFromResult "should apply 50% waste ratios sequentially"
                            ("""{
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                  "assembly": {
                                    "operations": [
                                      "b8d0dc25-170d-4c6a-93e5-ee31347316cc",
                                      "b8d0dc25-170d-4c6a-93e5-ee31347316cc"
                                    ]
                                  }
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            (\lifeCycle ->
                                let
                                    -- fake assembly process qty variation ratio
                                    qtyVariationRatioFloat =
                                        0.5

                                    productionMass =
                                        lifeCycle.production
                                            |> Component.extractMass
                                            |> Mass.inKilograms

                                    operationMasses =
                                        lifeCycle.assembly
                                            |> Component.extractItems
                                            |> List.map (Component.extractMass >> Mass.inKilograms)

                                    firstMass =
                                        operationMasses
                                            |> LE.getAt 0
                                            |> Result.fromMaybe "No first operation mass"

                                    secondMass =
                                        operationMasses
                                            |> LE.getAt 1
                                            |> Result.fromMaybe "No second operation mass"
                                in
                                [ itFromResult "should halve mass after the first 50% waste operation"
                                    firstMass
                                    (Expect.within (Expect.Absolute 0.00001)
                                        (productionMass * qtyVariationRatioFloat)
                                    )
                                , it "should reduce end product mass to a quarter after two 50% waste operations" <|
                                    Expect.within (Expect.Absolute 0.00001)
                                        (productionMass * qtyVariationRatioFloat * qtyVariationRatioFloat)
                                        (Mass.inKilograms lifeCycle.productMass)
                                , itFromResult "should apply the second 50% waste ratio on the remaining mass"
                                    secondMass
                                    (Expect.within (Expect.Absolute 0.00001)
                                        (productionMass * qtyVariationRatioFloat * qtyVariationRatioFloat)
                                    )
                                ]
                            )
                        , itFromResult2 "should localize energy mixes to the assembly country when it is set"
                            (computeAssemblyEcsImpact requirements
                                """{
                                      "assembly": {
                                        "country": "FR",
                                        "operations": [
                                          "b8d0dc25-170d-4c6a-93e5-ee31347316cc"
                                        ]
                                      },
                                      "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]
                                    }"""
                            )
                            (computeAssemblyEcsImpact requirements
                                """{
                                      "assembly": {
                                        "operations": [
                                          "b8d0dc25-170d-4c6a-93e5-ee31347316cc"
                                        ]
                                      },
                                      "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]
                                    }"""
                            )
                            (\frAssemblyImpact defaultEnergyMixImpact ->
                                expectFloatDifferent frAssemblyImpact defaultEnergyMixImpact
                            )
                        , itFromResult "should decode a legacy assemblyCountry field"
                            ("""{
                                  "assemblyCountry": "FR",
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]
                                }"""
                                |> decodeJsonThen Component.decodeQuery Ok
                                |> Result.map .assembly
                            )
                            (.country >> Expect.equal (Just CountryCode.france))
                        , suiteFromResult2 "should propagate assembly waste down to distribution and EoL stages"
                            -- no assembly operations, hence no assembly waste
                            ("""{
                                  "components": [
                                    { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 },
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                  ],
                                  "recyclable": true
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            --  assembly operations featuring waste
                            ("""{
                                  "components": [
                                    { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 },
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                  ],
                                  "recyclable": true,
                                  "assembly": {
                                    "operations": [
                                      "b8d0dc25-170d-4c6a-93e5-ee31347316cc",
                                      "b8d0dc25-170d-4c6a-93e5-ee31347316cc"
                                    ]
                                  }
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            (\lifeCycle withAssemblyWaste ->
                                let
                                    -- 50% * 50% = 25% expected assembly waste from accumulated operations
                                    massScaleRatio =
                                        0.25

                                    baseDistributionVolume =
                                        Volume.inCubicMeters lifeCycle.distribution.volume

                                    baseEndOfLifeMass =
                                        Component.getEndOfLifeTotalMass requirements lifeCycle

                                    baseEndOfLifeImpact =
                                        getEcsImpact lifeCycle.endOfLife

                                    baseToAssemblyImpact =
                                        getEcsImpact lifeCycle.transports.toAssembly.impacts

                                    baseToDistributionImpact =
                                        getEcsImpact lifeCycle.transports.toDistribution.impacts
                                in
                                [ it "should scale EoL stage material masses with assembly waste"
                                    (withAssemblyWaste
                                        |> Component.getEndOfLifeTotalMass requirements
                                        |> expectFloatMostlyEqual (baseEndOfLifeMass * massScaleRatio)
                                    )
                                , it "should scale EoL stage impacts with assembly waste"
                                    (withAssemblyWaste.endOfLife
                                        |> getEcsImpact
                                        |> expectFloatMostlyEqual (baseEndOfLifeImpact * massScaleRatio)
                                    )
                                , it "should scale distribution stage volume with assembly waste"
                                    (withAssemblyWaste.distribution.volume
                                        |> Volume.inCubicMeters
                                        |> expectFloatMostlyEqual (baseDistributionVolume * massScaleRatio)
                                    )
                                , it "should scale transport to distribution stage impacts with assembly waste"
                                    (withAssemblyWaste.transports.toDistribution.impacts
                                        |> getEcsImpact
                                        |> expectFloatMostlyEqual (baseToDistributionImpact * massScaleRatio)
                                    )
                                , it "should keep transport to assembly stage impacts unchanged with assembly waste"
                                    (withAssemblyWaste.transports.toAssembly.impacts
                                        |> getEcsImpact
                                        |> expectFloatMostlyEqual baseToAssemblyImpact
                                    )
                                , it "should keep EoL stage masses consistent with product mass"
                                    (withAssemblyWaste
                                        |> Component.getEndOfLifeTotalMass requirements
                                        |> expectFloatMostlyEqual (Mass.inKilograms withAssemblyWaste.productMass)
                                    )
                                ]
                            )
                        ]
                    , describe "computeTransports"
                        [ suiteFromResult2 "unknown locations"
                            -- setup
                            ("""[{ "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }]"""
                                |> decodeJsonThen (Decode.list Component.decodeItem) (computeItemsWithRequirements requirements)
                            )
                            ("""[ { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                                , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                ]"""
                                |> decodeJsonThen (Decode.list Component.decodeItem) (computeItemsWithRequirements requirements)
                            )
                            -- tests
                            (\singleItem multipleItems ->
                                [ it "should add transports to assembly when a single item is shipped"
                                    (singleItem
                                        |> .transports
                                        |> .toAssembly
                                        |> .impacts
                                        |> Impact.getImpact Definition.Ecs
                                        |> Unit.impactToFloat
                                        |> Expect.greaterThan 0
                                    )
                                , it "should add transports to assembly when multiple items are shipped"
                                    (multipleItems
                                        |> .transports
                                        |> .toAssembly
                                        |> .impacts
                                        |> Impact.getImpact Definition.Ecs
                                        |> Unit.impactToFloat
                                        |> Expect.greaterThan 0
                                    )
                                ]
                            )
                        , suiteFromResult "assembly country handling"
                            -- setup
                            ("""{
                                  "assembly": { "country": "FR" },
                                  "components": [
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                  ]
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            -- tests
                            (\productAssembledInFrance ->
                                [ it "should add both assembly and distribution transport impacts when assembly country is specified"
                                    (let
                                        ( assemblyImpact, distributionImpact ) =
                                            ( productAssembledInFrance
                                                |> .transports
                                                |> .toAssembly
                                                |> .impacts
                                                |> getEcsImpact
                                            , productAssembledInFrance
                                                |> .transports
                                                |> .toDistribution
                                                |> .impacts
                                                |> getEcsImpact
                                            )
                                     in
                                     ( assemblyImpact, distributionImpact )
                                        |> Expect.all
                                            [ Tuple.first >> Expect.greaterThan 0
                                            , Tuple.second >> Expect.greaterThan 0
                                            ]
                                    )
                                ]
                            )
                        , suiteFromResult "single item distribution transport"
                            -- setup
                            ("""{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]}"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            -- tests
                            (\singleItemProduct ->
                                [ it "should add transport to assembly when shipping a single item"
                                    (singleItemProduct
                                        |> .transports
                                        |> .toAssembly
                                        |> .impacts
                                        |> getEcsImpact
                                        |> Expect.greaterThan 0
                                    )
                                , it "should add transport impacts to distribution when shipping a single item"
                                    (singleItemProduct
                                        |> .transports
                                        |> .toDistribution
                                        |> .impacts
                                        |> getEcsImpact
                                        |> Expect.greaterThan 0
                                    )
                                ]
                            )
                        , suiteFromResult2 "single item quantity scaling"
                            -- setup
                            ("""{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]}"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            ("""{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 2 }]}"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            doubledQuantitiesExpectations
                        , suiteFromResult2 "single item quantity scaling with assembly country"
                            -- setup
                            ("""{
                                  "assembly": { "country": "FR" },
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            ("""{
                                  "assembly": { "country": "FR" },
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 2 }]
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            doubledQuantitiesExpectations
                        , suiteFromResult2 "multi-element item quantity scaling"
                            -- setup
                            ("""{"components": [{ "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }]}"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            ("""{"components": [{ "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 2 }]}"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            doubledQuantitiesExpectations
                        , it "should reject an empty component list with an assembly country"
                            ("""{
                                  "assembly": { "country": "FR" },
                                  "components": []
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                |> expectResultErrorContains "Une liste de composants vide ne peut être assemblée"
                            )
                        , suiteFromResult "empty component list without assembly country"
                            ("""{ "components": [] }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            (\emptyProduct ->
                                [ it "should not add transport to assembly"
                                    (emptyProduct
                                        |> .transports
                                        |> .toAssembly
                                        |> .impacts
                                        |> getEcsImpact
                                        |> Expect.equal 0
                                    )
                                , it "should not add transport to distribution"
                                    (emptyProduct
                                        |> .transports
                                        |> .toDistribution
                                        |> .impacts
                                        |> getEcsImpact
                                        |> Expect.equal 0
                                    )
                                ]
                            )
                        , suiteFromResult "single item air transport to distribution"
                            -- setup
                            ("""{
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                  "transportOptions": { "byAir": 100 }
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            -- tests
                            (\singleItemProduct ->
                                [ it "should never add air transport to assembly"
                                    (singleItemProduct
                                        |> .transports
                                        |> .toAssembly
                                        |> .air
                                        |> Length.inKilometers
                                        |> Expect.equal 0
                                    )
                                , it "should add air transport to distribution"
                                    (singleItemProduct
                                        |> .transports
                                        |> .toDistribution
                                        |> .air
                                        |> Length.inKilometers
                                        |> Expect.greaterThan 0
                                    )
                                ]
                            )
                        , suiteFromResult "multiple items air transport to assembly"
                            -- setup
                            ("""{
                                  "components": [
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                  ],
                                  "assembly": { "country": "PT" },
                                  "transportOptions": { "byAir": 100 }
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            -- tests
                            (\multipleItemsProducs ->
                                [ it "should never add air transport to assembly"
                                    (multipleItemsProducs
                                        |> .transports
                                        |> .toAssembly
                                        |> .air
                                        |> Length.inKilometers
                                        |> Expect.equal 0
                                    )
                                , it "should add air transport to distribution"
                                    (multipleItemsProducs
                                        |> .transports
                                        |> .toDistribution
                                        |> .air
                                        |> Length.inKilometers
                                        |> Expect.greaterThan 0
                                    )
                                ]
                            )
                        , suiteFromResult2 "multiple items without assembly country"
                            -- setup
                            ("""{
                                  "components": [
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                                  ]
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            ("""{
                                  "components": [
                                    { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 },
                                    { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 2 }
                                  ]
                                }"""
                                |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            )
                            -- tests
                            (\productAssembledInUnknownCountry heavierProductAssembledInUnknownCountry ->
                                [ it "should add both assembly and distribution transports when multiple items have no assembly country"
                                    (let
                                        ( assemblyImpact, distributionImpact ) =
                                            ( productAssembledInUnknownCountry
                                                |> .transports
                                                |> .toAssembly
                                                |> .impacts
                                                |> getEcsImpact
                                            , productAssembledInUnknownCountry
                                                |> .transports
                                                |> .toDistribution
                                                |> .impacts
                                                |> getEcsImpact
                                            )
                                     in
                                     ( assemblyImpact, distributionImpact )
                                        |> Expect.all
                                            [ Tuple.first >> Expect.greaterThan 0
                                            , Tuple.second >> Expect.greaterThan 0
                                            ]
                                    )
                                , it "should increase distribution transport impacts when total transported mass increases"
                                    (let
                                        productAssembledInUnknownCountryImpacts =
                                            productAssembledInUnknownCountry
                                                |> .transports
                                                |> .toDistribution
                                                |> .impacts
                                                |> getEcsImpact

                                        heavierProductAssembledInUnknownCountryImpacts =
                                            heavierProductAssembledInUnknownCountry
                                                |> .transports
                                                |> .toDistribution
                                                |> .impacts
                                                |> getEcsImpact
                                     in
                                     heavierProductAssembledInUnknownCountryImpacts
                                        |> Expect.greaterThan productAssembledInUnknownCountryImpacts
                                    )
                                , it "should increase assembly transport impacts when total transported mass increases"
                                    (let
                                        productAssembledInUnknownCountryImpacts =
                                            productAssembledInUnknownCountry
                                                |> .transports
                                                |> .toAssembly
                                                |> .impacts
                                                |> getEcsImpact

                                        heavierProductAssembledInUnknownCountryImpacts =
                                            heavierProductAssembledInUnknownCountry
                                                |> .transports
                                                |> .toAssembly
                                                |> .impacts
                                                |> getEcsImpact
                                     in
                                     heavierProductAssembledInUnknownCountryImpacts
                                        |> Expect.greaterThan productAssembledInUnknownCountryImpacts
                                    )
                                ]
                            )
                        , itFromResult2 "should include transport stage impacts when applying transforms"
                            -- setup
                            -- test country
                            (requirements.db.countries
                                |> Scope.anyOf [ requirements.scope ]
                                |> List.head
                                |> Result.fromMaybe ("No test country available scoped " ++ Scope.toString requirements.scope)
                            )
                            -- cotton
                            (findProcessByLabel requirements "Production de fibres de coton")
                            -- tests
                            (\country cotton ->
                                { amount = Amount.fromFloat 1
                                , material = { country = Just country.code, id = cotton.id }
                                , transforms =
                                    [ { id = fading.id
                                      , country = Just country.code
                                      }
                                    ]
                                }
                                    |> Component.computeElementResults requirements defaultTransportOptions
                                    |> Result.map Component.extractItems
                                    |> Result.map (List.any (Component.extractStage >> (==) (Just Component.TransportStage)))
                                    |> Expect.equal (Ok True)
                            )
                        , let
                            getTransportStageEcs =
                                Component.stagesImpacts >> .transports >> Maybe.map getEcsImpact >> Maybe.withDefault 0
                          in
                          describe "transport options"
                            [ itFromResult2 "should handle transport cooling"
                                ("""{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]}"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                    |> Result.map getTransportStageEcs
                                )
                                ("""{
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                  "transportOptions": { "cooling": true }
                                }"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                    |> Result.map getTransportStageEcs
                                )
                                (\noTransportCooling withTransportCooling ->
                                    withTransportCooling
                                        |> Expect.greaterThan noTransportCooling
                                )
                            , itFromResult2 "should handle air transport"
                                ("""{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]}"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                    |> Result.map getTransportStageEcs
                                )
                                ("""{
                                  "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                  "transportOptions": { "byAir": 100 }
                                }"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                    |> Result.map getTransportStageEcs
                                )
                                (\noAirTransport withAirTransport ->
                                    withAirTransport
                                        |> Expect.greaterThan noAirTransport
                                )
                            , itFromResult "should cool pre-assembly transports for a `transported_cooled` material, even when cooling is disabled"
                                -- note: using wood as an example, which is not tagged as transported_cooled
                                wood
                                (\woodProcess ->
                                    let
                                        testSpecificReqs =
                                            requirements
                                                |> updateRequirementsProcess woodProcess
                                                    -- tag the process as transported_cooled
                                                    (\process -> { process | categories = Category.TransportedCooled :: process.categories })
                                    in
                                    """{"components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }]}"""
                                        |> decodeJsonThen Component.decodeQuery (Component.compute testSpecificReqs)
                                        |> Result.map (.transports >> .toAssembly >> .roadCooled >> Length.inKilometers)
                                        |> Result.withDefault 0
                                        |> Expect.greaterThan 0
                                )
                            , itFromResult "should not cool pre-assembly transport through the cooling option for a non-tagged material"
                                ("""{
                                      "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                      "transportOptions": { "cooling": true }
                                    }"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                )
                                (\product ->
                                    product.transports.toAssembly.roadCooled
                                        |> Length.inKilometers
                                        |> Expect.equal 0
                                )
                            , itFromResult "should cool assembly to distribution transpoerts when the cooling option is enabled"
                                ("""{
                                      "components": [{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }],
                                      "transportOptions": { "cooling": true }
                                    }"""
                                    |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                                )
                                (\product ->
                                    product.transports.toDistribution.roadCooled
                                        |> Length.inKilometers
                                        |> Expect.greaterThan 0
                                )
                            ]
                        ]
                    , suiteFromResult2 "computeTransportDistance"
                        (db.countries |> Country.findByCode (CountryCode.fromString "PT"))
                        (db.countries |> Country.findByCode CountryCode.france)
                        (\france portugal ->
                            [ it "should compute distance between two countries"
                                (Component.computeTransportDistance requirements Split.zero (Just portugal) (Just france)
                                    |> Result.map (Maybe.withDefault Transport.noTransport)
                                    |> Result.map
                                        (\{ air, road, sea } ->
                                            ( Length.inKilometers air > 0
                                            , Length.inKilometers road > 0
                                            , Length.inKilometers sea > 0
                                            )
                                        )
                                    |> Expect.equal (Ok ( False, True, False ))
                                )
                            , it "should compute distance between two countries accounting transport to hubs"
                                (Component.computeTransportDistance requirements
                                    Split.zero
                                    -- Note: exagerating distances to hub, to make this test resilient to future data updates
                                    (Just { portugal | distanceToHub = Length.kilometers 20000 })
                                    (Just { france | distanceToHub = Length.kilometers 10000 })
                                    |> Result.map (Maybe.withDefault Transport.noTransport)
                                    |> Result.map (.road >> Length.inKilometers)
                                    |> Result.withDefault 0
                                    |> Expect.greaterThan 30000
                                )
                            , it "should handle both countries unknown"
                                (Component.computeTransportDistance requirements Split.zero Nothing Nothing
                                    |> Expect.equal (Ok Nothing)
                                )
                            , let
                                getRoad from to =
                                    Component.computeTransportDistance requirements Split.zero from to
                                        |> Result.map (Maybe.map (.road >> Length.inKilometers) >> Maybe.withDefault -99)
                                        |> Result.withDefault -99
                              in
                              describe "single unknown country"
                                [ it "should handle unknown country of departure"
                                    (getRoad Nothing (Just france)
                                        |> Expect.within (Expect.Absolute 1)
                                            ([ france.distanceToHub, requirements.config.transports.defaultDistance.road ]
                                                |> Quantity.sum
                                                |> Length.inKilometers
                                            )
                                    )
                                , it "should handle unknown country of destination"
                                    (getRoad (Just portugal) Nothing
                                        |> Expect.within (Expect.Absolute 1)
                                            ([ portugal.distanceToHub, requirements.config.transports.defaultDistance.road ]
                                                |> Quantity.sum
                                                |> Length.inKilometers
                                            )
                                    )
                                ]
                            ]
                        )
                    , suiteFromResult2 "computeTransportedMassImpacts"
                        (db.countries |> Country.findByCode (CountryCode.fromString "PT"))
                        (db.countries |> Country.findByCode CountryCode.france)
                        (\portugal france ->
                            [ it "should compute transported mass impacts"
                                (Mass.kilogram
                                    |> Component.computeTransportedMassImpacts requirements
                                        defaultTransportOptions
                                        (Just portugal)
                                        (Just france)
                                    |> Result.map (.impacts >> getEcsImpact)
                                    |> Result.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should never include air transport with default transport options"
                                (Mass.kilogram
                                    |> Component.computeTransportedMassImpacts requirements
                                        defaultTransportOptions
                                        (Just portugal)
                                        (Just france)
                                    |> Result.map (.air >> Length.inKilometers)
                                    |> Result.withDefault 1
                                    |> Expect.equal 0
                                )
                            , it "should include air transport when the option is set"
                                (Mass.kilogram
                                    |> Component.computeTransportedMassImpacts requirements
                                        { defaultTransportOptions | byAir = Split.full }
                                        (Just portugal)
                                        (Just france)
                                    |> Result.map (.air >> Length.inKilometers)
                                    |> Result.withDefault -99
                                    |> Expect.greaterThan 0
                                )
                            , it "should include cooled transport when the option is set"
                                (Mass.kilogram
                                    |> Component.computeTransportedMassImpacts requirements
                                        { defaultTransportOptions | cooling = Just True }
                                        (Just portugal)
                                        (Just france)
                                    |> Result.map (.roadCooled >> Length.inKilometers)
                                    |> Result.withDefault -99
                                    |> Expect.greaterThan 0
                                )
                            ]
                        )
                    , describe "computeVolumeFromMass"
                        [ it "should compute a volume from a mass"
                            -- Remember, this is a temporary situation until we obtain volume per unit data in processes db
                            (Component.computeVolumeFromMass (Mass.kilograms 1000)
                                |> Expect.equal (Volume.cubicMeters 1)
                            )
                        ]
                    , describe "decodeItem"
                        [ it "should decode an item"
                            ("""{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 1 }"""
                                |> decodeJson Component.decodeItem
                                |> Expect.ok
                            )
                        , itFromResult "should decode an item with a custom material country override"
                            ("""{
                                  "quantity": 1,
                                  "custom": {
                                    "elements": [
                                      {
                                        "amount": 1,
                                        "material": {
                                          "id": "17431e06-2973-516e-b043-be9ad405e4fb",
                                          "country": "CN"
                                        }
                                      }
                                    ]
                                  }
                                }"""
                                |> decodeJsonThen Component.decodeItem
                                    (.custom
                                        >> Maybe.andThen (.elements >> LE.getAt 0)
                                        >> Maybe.map (.material >> .country)
                                        >> Result.fromMaybe "Missing custom element material country"
                                    )
                            )
                            (Expect.equal (Just CountryCode.china))
                        , itFromResult "should decode an item with a custom transform country override"
                            ("""{
                                  "quantity": 1,
                                  "custom": {
                                    "elements": [
                                      {
                                        "amount": 1,
                                        "material": "17431e06-2973-516e-b043-be9ad405e4fb",
                                        "transforms": [
                                          {
                                            "id": "931c9bb0-619a-5f75-b41b-ab8061e2ad92",
                                            "country": "CN"
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                }"""
                                |> decodeJsonThen Component.decodeItem
                                    (.custom
                                        >> Maybe.andThen (.elements >> LE.getAt 0)
                                        >> Maybe.andThen (.transforms >> LE.getAt 0)
                                        >> Maybe.map .country
                                        >> Result.fromMaybe "Missing custom element transform country"
                                    )
                            )
                            (Expect.equal (Just CountryCode.china))
                        ]
                    , describe "getDocLink"
                        [ it "should retrieve a scoped documentation link"
                            ("assembly"
                                |> Component.getDocLink requirements.config (Scope.Generic Scope.Veli)
                                |> Expect.equal (Just "https://fabrique-numerique.gitbook.io/ecobalyse/vehicules/cycle-de-vie/assemblage")
                            )
                        , it "should fallback to a default documentation link when no scoped link exists"
                            ("assembly"
                                |> Component.getDocLink requirements.config (Scope.Generic Scope.Object)
                                |> Expect.equal (Just "https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses/assemblage")
                            )
                        , it "should retrieve Nothing when no doc link exists"
                            ("invalid"
                                |> Component.getDocLink requirements.config (Scope.Generic Scope.Object)
                                |> Expect.equal Nothing
                            )
                        ]
                    , suiteFromResult "itemToComponent"
                        ("""{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                              "quantity": 1,
                              "custom": {
                                "name": "custom name",
                                "elements": [
                                  {
                                    "amount": 0.00044,
                                    "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                                  }
                                ]
                              }
                            }"""
                            |> decodeJson Component.decodeItem
                            |> Result.andThen
                                (\item ->
                                    item
                                        |> Component.itemToComponent db
                                        |> Result.map (\component -> ( item.custom, component ))
                                )
                        )
                        (\( maybeCustom, component ) ->
                            [ it "should merge custom item elements into a final component"
                                (Expect.equal component.elements
                                    (maybeCustom
                                        |> Maybe.map .elements
                                        |> Maybe.withDefault []
                                    )
                                )
                            , it "should merge custom item name into a final component"
                                (Expect.equal component.name "custom name")
                            ]
                        )
                    , itFromResult "itemToString with an existing component"
                        (""" { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                               "quantity": 1,
                               "custom": {
                                 "elements": [
                                   {
                                     "amount": 0.00044,
                                     "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                                   },
                                   {
                                     "amount": 0.00088,
                                     "material": "59b42284-3e45-5343-8a20-1d7d66137461"
                                   }
                                 ]
                               }
                            }"""
                            |> decodeJsonThen Component.decodeItem (Component.itemToString db)
                        )
                        (Expect.equal "1 Pied 70 cm (plein bois) [ 4,40e-4m3 Bois d'oeuvre (Feuillus / Hêtre) | 8,80e-4kg Plastique granulé (PP) ]")
                    , itFromResult "itemToString with an existing component and a custom name"
                        -- setup
                        (""" { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                               "quantity": 1,
                               "custom": {
                                 "name": "Customized existing component",
                                 "elements": [
                                   {
                                     "amount": 0.00044,
                                     "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                                   },
                                   {
                                     "amount": 0.00088,
                                     "material": "59b42284-3e45-5343-8a20-1d7d66137461"
                                   }
                                 ]
                               }
                            }"""
                            |> decodeJsonThen Component.decodeItem (Component.itemToString db)
                        )
                        (Expect.equal "1 Customized existing component [ 4,40e-4m3 Bois d'oeuvre (Feuillus / Hêtre) | 8,80e-4kg Plastique granulé (PP) ]")
                    , itFromResult "itemToString with a new component"
                        (""" { "quantity": 1,
                               "custom": {
                                 "name": "Custom new component",
                                 "elements": [
                                   {
                                     "amount": 0.00044,
                                     "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                                   },
                                   {
                                     "amount": 0.00088,
                                     "material": "59b42284-3e45-5343-8a20-1d7d66137461"
                                   }
                                 ]
                               }
                            }"""
                            |> decodeJsonThen Component.decodeItem (Component.itemToString db)
                        )
                        (Expect.equal "1 Custom new component [ 4,40e-4m3 Bois d'oeuvre (Feuillus / Hêtre) | 8,80e-4kg Plastique granulé (PP) ]")
                    , suiteFromResult "getEndOfLifeDetailedImpacts"
                        -- setup
                        (chair
                            |> Result.andThen (computeItemsWithRequirements requirements)
                            |> Result.map
                                (\lifeCycle ->
                                    lifeCycle
                                        |> Component.getEndOfLifeDetailedImpacts requirements True
                                )
                        )
                        -- tests
                        (\chairMaterialGroups ->
                            [ it "should group materials"
                                (chairMaterialGroups
                                    |> AnyDict.keys
                                    |> Expect.equal [ Category.RigidPlastics, Category.Wood ]
                                )
                            , it "should group materials collected masses"
                                (chairMaterialGroups
                                    |> AnyDict.values
                                    |> List.map (.collected >> Tuple.first >> Mass.inKilograms)
                                    |> List.all (\x -> x > 0)
                                    |> Expect.equal True
                                )
                            , it "should group materials non-collected masses"
                                (chairMaterialGroups
                                    |> AnyDict.values
                                    |> List.map (.nonCollected >> Tuple.first >> Mass.inKilograms)
                                    |> List.all (\x -> x > 0)
                                    |> Expect.equal True
                                )
                            , it "should group materials collected impacts"
                                (chairMaterialGroups
                                    |> AnyDict.values
                                    |> List.map
                                        (.collected
                                            >> Tuple.second
                                            >> .incinerating
                                            >> .impacts
                                            >> Impact.getImpact Definition.Ecs
                                            >> Unit.impactToFloat
                                        )
                                    |> List.all (\x -> x > 0)
                                    |> Expect.equal True
                                )
                            , it "should group materials non-collected impacts"
                                (chairMaterialGroups
                                    |> AnyDict.values
                                    |> List.map
                                        (.nonCollected
                                            >> Tuple.second
                                            >> .incinerating
                                            >> .impacts
                                            >> Impact.getImpact Definition.Ecs
                                            >> Unit.impactToFloat
                                        )
                                    |> List.all (\x -> x > 0)
                                    |> Expect.equal True
                                )
                            ]
                        )
                    , let
                        query =
                            { emptyQuery
                                | assembly =
                                    { country = Just CountryCode.france
                                    , operations = Nothing
                                    }
                            }
                      in
                      describe "mapItems"
                        [ it "should reset the assembly country when mapItems empties the list"
                            (query
                                |> Component.mapItems (always [])
                                |> .assembly
                                |> .country
                                |> Expect.equal Nothing
                            )
                        , it "should preserve the assembly country when mapItems keeps the list"
                            (query
                                |> Component.mapItems (always [ Component.createItem Nothing ])
                                |> .assembly
                                |> .country
                                |> Expect.equal (Just CountryCode.france)
                            )
                        ]
                    , suiteFromResult2 "removeElement"
                        -- setup
                        sofaFabric
                        steel
                        -- tests
                        (\testComponent material ->
                            [ itFromResult "should remove an item element"
                                ("""[ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 } ]"""
                                    |> decodeJsonThen (Decode.list Component.decodeItem)
                                        (Component.addElement ( testComponent, 0 ) material
                                            >> Result.map (Component.removeElement ( ( testComponent, 0 ), 1 ))
                                        )
                                    |> Result.map
                                        (\items ->
                                            items
                                                -- get the first component item
                                                |> LE.getAt 0
                                                -- access its custom property
                                                |> Maybe.andThen .custom
                                                -- get custom elements length
                                                |> Maybe.map (.elements >> List.length)
                                        )
                                )
                                (Expect.equal (Just 2))
                            ]
                        )
                    , suiteFromResult2 "removeElementTransform"
                        chairBack
                        injectionMoulding
                        -- tests
                        (\testComponent testProcess ->
                            [ itFromResult "should remove an element transform"
                                (chair
                                    |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) Nothing testProcess)
                                    |> Result.map (Component.removeElementTransform ( ( testComponent, 1 ), 0 ) 0)
                                    |> Result.map (LE.getAt 1)
                                )
                                (Expect.equal
                                    (Just
                                        { custom = Nothing
                                        , id = testComponent.id
                                        , quantity = Component.quantityFromInt 1
                                        }
                                    )
                                )
                            ]
                        )
                    , suiteFromResult3 "setElementMaterial"
                        -- setup
                        chairBack
                        steel
                        injectionMoulding
                        -- tests
                        (\testComponent validTestProcess invalidTestProcess ->
                            [ itFromResult "should set a valid element material"
                                (chair
                                    |> Result.andThen (Component.setElementMaterial requirements.db ( ( testComponent, 1 ), 0 ) validTestProcess)
                                    |> Result.map
                                        (\items ->
                                            items
                                                -- get second component item
                                                |> LE.getAt 1
                                                -- access its custom property
                                                |> Maybe.andThen .custom
                                                -- access the first element
                                                |> Maybe.andThen (.elements >> LE.getAt 0)
                                                -- and its material process id
                                                |> Maybe.map (.material >> .id)
                                        )
                                )
                                -- it should be equal to the one we swapped in
                                (Expect.equal (Just validTestProcess.id))
                            , it "should reject an invalid element material"
                                (chair
                                    |> Result.andThen (Component.setElementMaterial requirements.db ( ( testComponent, 1 ), 0 ) invalidTestProcess)
                                    |> expectResultErrorContains "Seuls les procédés de catégorie `material` sont mobilisables comme matière"
                                )
                            ]
                        )
                    , let
                        query =
                            { emptyQuery
                                | assembly =
                                    { country = Just CountryCode.france
                                    , operations = Nothing
                                    }
                            }
                      in
                      describe "setQueryItems"
                        [ it "should preserve the assembly country for a single item"
                            (query
                                |> Component.setQueryItems [ Component.createItem Nothing ]
                                |> .assembly
                                |> .country
                                |> Expect.equal (Just CountryCode.france)
                            )
                        , it "should preserve the assembly country for multiple items"
                            (query
                                |> Component.setQueryItems [ Component.createItem Nothing, Component.createItem Nothing ]
                                |> .assembly
                                |> .country
                                |> Expect.equal (Just CountryCode.france)
                            )
                        , it "should reset the assembly country when the list becomes empty"
                            (query
                                |> Component.setQueryItems []
                                |> .assembly
                                |> .country
                                |> Expect.equal Nothing
                            )
                        ]
                    , suiteFromResult "stagesImpacts"
                        ("""{
                              "components": [
                                { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1}
                              ],
                              "consumptions": [
                                { "amount": 1, "processId": "931c9bb0-619a-5f75-b41b-ab8061e2ad92" }
                              ],
                              "packagings": [
                                { "amount": 1, "processId": "4a80c078-9f86-4a7d-b402-73db3381e33b" }
                              ],
                              "recyclable": true
                            }"""
                            |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            |> Result.map (\results -> ( results, Component.stagesImpacts results ))
                        )
                        (\( lifeCycle, stagesImpacts ) ->
                            [ it "should compute material stage impacts"
                                (stagesImpacts.materials
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should compute transformation stage impacts"
                                (stagesImpacts.transform
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should compute packaging impacts"
                                (stagesImpacts.endOfLife
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should compute end of life stage impacts"
                                (stagesImpacts.endOfLife
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should compute use stage consumption impacts"
                                (stagesImpacts.usage
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            , it "should have total stages impacts equal total impacts"
                                ([ stagesImpacts.materials, stagesImpacts.transform, stagesImpacts.transports ]
                                    |> List.filterMap identity
                                    |> Impact.sumImpacts
                                    |> getEcsImpact
                                    |> Expect.within (Expect.Absolute 0.00001)
                                        ([ Component.extractImpacts lifeCycle.production
                                         , lifeCycle.transports.toAssembly.impacts
                                         , lifeCycle.transports.toDistribution.impacts
                                         ]
                                            |> Impact.sumImpacts
                                            |> getEcsImpact
                                        )
                                )
                            ]
                        )
                    , suiteFromResult "nonRecyclableImpacts"
                        ("""{
                              "components": [
                                { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }
                              ],
                              "recyclable": false
                            }"""
                            |> decodeJsonThen Component.decodeQuery (Component.compute requirements)
                            |> Result.map Component.stagesImpacts
                        )
                        (\stagesImpacts ->
                            [ it "should also compute end of life stage impacts when not recyclable"
                                (stagesImpacts.endOfLife
                                    |> Maybe.map getEcsImpact
                                    |> Maybe.withDefault 0
                                    |> Expect.greaterThan 0
                                )
                            ]
                        )
                    , suiteFromResult "setCustomScope"
                        -- setup
                        ("""{ "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }"""
                            |> decodeJson Component.decodeItem
                            |> Result.andThen
                                (\item ->
                                    item
                                        |> Component.itemToComponent db
                                        |> Result.map (\component -> ( component, item ))
                                )
                        )
                        (\( sofaFabricComponent, sofaFabricItem ) ->
                            [ it "should have the expected initial component scope"
                                (sofaFabricComponent.scope
                                    |> Expect.equal (Scope.Generic Scope.Object)
                                )
                            , it "should have no custom scopes by default"
                                (sofaFabricItem.custom
                                    |> Expect.equal Nothing
                                )
                            , it "should set a custom scope"
                                (sofaFabricItem
                                    |> Component.setCustomScope sofaFabricComponent Scope.Textile
                                    |> .custom
                                    |> Maybe.andThen .scope
                                    |> Expect.equal (Just Scope.Textile)
                                )
                            , it "should reset custom scopes when they match initial component ones"
                                (sofaFabricItem
                                    |> Component.setCustomScope sofaFabricComponent (Scope.Generic Scope.Object)
                                    |> .custom
                                    |> Maybe.andThen .scope
                                    |> Expect.equal Nothing
                                )
                            , it "should export custom scopes to component"
                                (sofaFabricItem
                                    |> Component.setCustomScope sofaFabricComponent Scope.Textile
                                    |> Component.itemToComponent db
                                    |> Result.map .scope
                                    |> Expect.equal (Ok Scope.Textile)
                                )
                            ]
                        )
                    , suiteFromResult "updateItemCustomName"
                        -- setup
                        sofaFabric
                        -- tests
                        (\testComponent ->
                            [ itFromResult "should set a custom name to a component item"
                                (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 } ]"""
                                    |> decodeJsonThen (Decode.list Component.decodeItem)
                                        (Component.updateItemCustomName ( testComponent, 0 ) "My custom component" >> Ok)
                                    |> Result.map
                                        (\items ->
                                            items
                                                |> LE.getAt 0
                                                |> Maybe.andThen .custom
                                                |> Maybe.andThen .name
                                        )
                                )
                                (Expect.equal (Just "My custom component"))
                            , itFromResult "should trim a custom item name when serializing it"
                                (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 } ]"""
                                    |> decodeJsonThen (Decode.list Component.decodeItem)
                                        (Component.updateItemCustomName ( testComponent, 0 ) " My custom component " >> Ok)
                                    |> Result.map (Encode.list Component.encodeItem >> Encode.encode 0)
                                    |> Result.andThen (decodeJson (Decode.list Component.decodeItem))
                                    |> Result.map
                                        (\items ->
                                            items
                                                |> LE.getAt 0
                                                |> Maybe.andThen .custom
                                                |> Maybe.andThen .name
                                        )
                                )
                                (Expect.equal (Just "My custom component"))
                            ]
                        )
                    , suiteFromResult2 "useProcessAmount"
                        (chair |> Result.andThen (computeItemsWithRequirements requirements))
                        lowVoltageElec
                        (\lifeCycle lowVoltageElecProcess ->
                            let
                                productMassInKg =
                                    Mass.inKilograms lifeCycle.productMass

                                massDependentProcess =
                                    { lowVoltageElecProcess
                                        | categories = Category.ProductMassDependent :: lowVoltageElecProcess.categories
                                        , unit = Process.Kilogram
                                    }
                            in
                            [ it "should ignore provided amount and use product mass when using a mass-dependent process"
                                (Component.useProcessAmount lifeCycle massDependentProcess (Amount.fromFloat 999)
                                    |> Amount.toFloat
                                    |> Expect.within (Expect.Absolute 0.00001) productMassInKg
                                )
                            , it "should return the given amount for a regular, non-mass-dependent process"
                                (Component.useProcessAmount lifeCycle lowVoltageElecProcess (Amount.fromFloat 3)
                                    |> Amount.toFloat
                                    |> Expect.within (Expect.Absolute 0.00001) 3
                                )
                            ]
                        )
                    , describe "validateItem"
                        [ it "should reject a non-positive quantity" <|
                            (Component.createItem Nothing
                                |> (\item -> { item | quantity = Component.quantityFromInt 0 })
                                |> Component.validateItem db.components
                                |> expectResultErrorContains "La quantité doit être un nombre entier positif"
                            )
                        , it "should reject an item referencing a missing component" <|
                            (Component.idFromString "64fa65b3-c2df-4fd0-958b-83965bd6aa09"
                                |> Result.map (\badId -> Component.createItem (Just badId))
                                |> Result.andThen (Component.validateItem db.components)
                                |> expectResultErrorContains "Aucun composant avec id="
                            )
                        ]
                    , suiteFromResult4 "validateQuery"
                        -- Non-existing process
                        (Process.idFromString nonExistentUuid)
                        -- Steel process
                        steel
                        -- Sawing process
                        sawing
                        -- Dry distribution process
                        dryDistribution
                        -- Tests
                        (\nonExistingProcessId steelProcess sawingProcess dryDistributionProcess ->
                            [ describe "amount validation"
                                [ it "should reject a non-positive amount" <|
                                    ({ emptyQuery
                                        | consumptions =
                                            Just [ Component.consumption (Amount.fromFloat -1) steelProcess.id ]
                                     }
                                        |> Component.validateQuery { requirements | scope = Scope.Generic Scope.Food2 }
                                        |> expectResultErrorContains "Une quantité doit être supérieure ou égale à zéro"
                                    )
                                ]
                            , describe "distribution validation"
                                [ it "should accept a distribution process" <|
                                    (emptyQuery
                                        |> Component.updateDistribution (Just dryDistributionProcess.id)
                                        |> Component.validateQuery requirements
                                        |> Expect.ok
                                    )
                                , it "should reject a distribution referencing a missing process" <|
                                    (emptyQuery
                                        |> Component.updateDistribution (Just nonExistingProcessId)
                                        |> Component.validateQuery requirements
                                        |> expectResultErrorContains "Procédé introuvable par id"
                                    )
                                , it "should reject a distribution referencing a process that is not a distribution" <|
                                    (emptyQuery
                                        |> Component.updateDistribution (Just sawingProcess.id)
                                        |> Component.validateQuery requirements
                                        |> expectResultErrorContains "Le procédé n'est pas une distribution"
                                    )
                                , it "should reject a distribution referencing a process that does not accept a volume" <|
                                    (emptyQuery
                                        |> Component.updateDistribution (Just dryDistributionProcess.id)
                                        |> Component.validateQuery
                                            (requirements
                                                |> updateRequirementsProcess dryDistributionProcess
                                                    (\p -> { p | unit = Process.SquareMeter })
                                            )
                                        |> expectResultErrorContains "Le procédé de distribution doit accepter un volume"
                                    )
                                , it "should reject a distribution referencing a process with the wrong scope" <|
                                    (emptyQuery
                                        |> Component.updateDistribution (Just dryDistributionProcess.id)
                                        |> Component.validateQuery
                                            (requirements
                                                |> updateRequirementsProcess dryDistributionProcess
                                                    (\p -> { p | scopes = [] })
                                            )
                                        |> expectResultErrorContains
                                            ("Le procédé "
                                                ++ Process.idToString dryDistributionProcess.id
                                                ++ " n'est pas disponible pour le périmètre "
                                                ++ Scope.toLabel (Scope.Generic Scope.Object)
                                            )
                                    )
                                ]
                            , describe "durability validation"
                                [ it "should accept a durability param when it's enabled by config" <|
                                    (emptyQuery
                                        |> Component.updateDurability (Unit.ratio 1.42)
                                        |> Component.validateQuery { requirements | scope = Scope.Generic Scope.Object }
                                        |> Expect.ok
                                    )
                                , it "should reject a durability param when it's disabled by config" <|
                                    (emptyQuery
                                        |> Component.updateDurability (Unit.ratio 1.42)
                                        |> Component.validateQuery { requirements | scope = Scope.Generic Scope.Food2 }
                                        |> expectResultErrorContains ("La durabilité n'est pas activée pour le périmètre " ++ Scope.toLabel (Scope.Generic Scope.Food2))
                                    )
                                ]
                            , describe "process validation"
                                [ it "should reject a consumption referencing a missing process" <|
                                    ({ emptyQuery
                                        | consumptions =
                                            Just [ Component.consumption (Amount.fromFloat 1) nonExistingProcessId ]
                                     }
                                        |> Component.validateQuery requirements
                                        |> expectResultErrorContains ("Aucun procédé scopé Objets avec cet id: " ++ Process.idToString nonExistingProcessId)
                                    )
                                , it "should reject a consumption referencing a process with the wrong scope" <|
                                    ({ emptyQuery
                                        | consumptions =
                                            -- Note: the sawing process isn't scoped for Food2
                                            Just [ Component.consumption (Amount.fromFloat 1) sawingProcess.id ]
                                     }
                                        |> Component.validateQuery { requirements | scope = Scope.Generic Scope.Food2 }
                                        |> expectResultErrorContains ("Aucun procédé scopé Alimentaire BÉTA avec cet id: " ++ Process.idToString sawingProcess.id)
                                    )
                                , it "should reject a packaging referencing a missing process" <|
                                    ({ emptyQuery
                                        | packagings =
                                            [ Component.packaging (Amount.fromFloat 1) nonExistingProcessId
                                            ]
                                     }
                                        |> Component.validateQuery requirements
                                        |> expectResultErrorContains ("Aucun procédé scopé Objets avec cet id: " ++ Process.idToString nonExistingProcessId)
                                    )
                                , it "should reject a packaging referencing a process with the wrong scope" <|
                                    ({ emptyQuery
                                        | packagings =
                                            -- Note: the sawing process isn't scoped for Food2
                                            [ Component.packaging (Amount.fromFloat 1) sawingProcess.id
                                            ]
                                     }
                                        |> Component.validateQuery { requirements | scope = Scope.Generic Scope.Food2 }
                                        |> expectResultErrorContains ("Aucun procédé scopé Alimentaire BÉTA avec cet id: " ++ Process.idToString sawingProcess.id)
                                    )
                                ]
                            ]
                        )
                    , describe "optional product category"
                        [ describe "decoding"
                            [ it "should decode a query with no product field defined" <|
                                ("""{"components":[]}"""
                                    |> decodeJson Component.decodeQuery
                                    |> Result.map .product
                                    |> Expect.equal (Ok Nothing)
                                )
                            , it "should decode omitted consumptions, cooling, and assembly operations as unspecified" <|
                                ("""{"components":[]}"""
                                    |> decodeJson Component.decodeQuery
                                    |> Result.map
                                        (\query ->
                                            ( query.consumptions
                                            , query.transportOptions.cooling
                                            , query.assembly.operations
                                            )
                                        )
                                    |> Expect.equal (Ok ( Nothing, Nothing, Nothing ))
                                )
                            , it "should decode an explicit empty consumptions list" <|
                                ("""{"components":[],"consumptions":[]}"""
                                    |> decodeJson Component.decodeQuery
                                    |> Result.map .consumptions
                                    |> Expect.equal (Ok (Just []))
                                )
                            , it "should decode an explicit empty assembly operations list" <|
                                ("""{"components":[],"assembly":{"operations":[]}}"""
                                    |> decodeJson Component.decodeQuery
                                    |> Result.map (.assembly >> .operations)
                                    |> Expect.equal (Ok (Just []))
                                )
                            , it "should decode explicitly disabled cooling" <|
                                ("""{"components":[],"transportOptions":{"cooling":false}}"""
                                    |> decodeJson Component.decodeQuery
                                    |> Result.map (.transportOptions >> .cooling)
                                    |> Expect.equal (Ok (Just False))
                                )
                            ]
                        , describe "encoding"
                            [ it "should omit unspecified consumptions, cooling, and assembly operations when encoding" <|
                                (emptyQuery
                                    |> Component.encodeQuery
                                    |> Encode.encode 0
                                    |> Expect.all
                                        [ String.contains "\"consumptions\"" >> Expect.equal False
                                        , String.contains "\"cooling\"" >> Expect.equal False
                                        , String.contains "\"operations\"" >> Expect.equal False
                                        ]
                                )
                            , it "should encode an explicit empty consumptions list" <|
                                ({ emptyQuery | consumptions = Just [] }
                                    |> Component.encodeQuery
                                    |> Encode.encode 0
                                    |> String.contains "\"consumptions\":[]"
                                    |> Expect.equal True
                                )
                            , it "should encode an explicit empty assembly operations list" <|
                                ({ emptyQuery | assembly = { emptyAssembly | operations = Just [] } }
                                    |> Component.encodeQuery
                                    |> Encode.encode 0
                                    |> String.contains "\"operations\":[]"
                                    |> Expect.equal True
                                )
                            , it "should encode explicit cooling false" <|
                                ({ emptyQuery | transportOptions = { defaultTransportOptions | cooling = Just False } }
                                    |> Component.encodeQuery
                                    |> Encode.encode 0
                                    |> String.contains "\"cooling\":false"
                                    |> Expect.equal True
                                )
                            ]
                        , it "should default product category assembly to an empty list when omitted" <|
                            ("""[{
                                  "cooling": false,
                                  "id": "5fad4e70-5736-552d-a686-97e4fb627c37",
                                  "label": "Test",
                                  "scope": "food2"
                                }]"""
                                |> Product.decodeListFromJsonString
                                |> Result.map (List.head >> Maybe.map .assembly)
                                |> Expect.equal (Ok (Just []))
                            )
                        , it "should default product category consumptions to an empty list when omitted" <|
                            ("""[{
                                  "cooling": false,
                                  "id": "5fad4e70-5736-552d-a686-97e4fb627c37",
                                  "label": "Test",
                                  "scope": "food2"
                                }]"""
                                |> Product.decodeListFromJsonString
                                |> Result.map (List.head >> Maybe.map .consumptions)
                                |> Expect.equal (Ok (Just []))
                            )
                        , itFromResult2 "should decode product category consumptions with optional amounts"
                            (findProcessByLabel requirements "Réfrigération")
                            (findProcessByLabel requirements "Cuisson à la poêle")
                            (\refrigeration panCooking ->
                                ("""[{
                                      "cooling": false,
                                      "consumptions": [
                                        { "processId": "{{refrigerationId}}" },
                                        { "amount": 5.5, "processId": "{{panCookingId}}" }
                                      ],
                                      "id": "5fad4e70-5736-552d-a686-97e4fb627c37",
                                      "label": "Test",
                                      "scope": "food2"
                                    }]"""
                                    |> String.replace "{{refrigerationId}}" (Process.idToString refrigeration.id)
                                    |> String.replace "{{panCookingId}}" (Process.idToString panCooking.id)
                                )
                                    |> Product.decodeListFromJsonString
                                    |> Result.map (List.head >> Maybe.map .consumptions)
                                    |> Expect.equal
                                        (Ok
                                            (Just
                                                [ { amount = Nothing
                                                  , processId = refrigeration.id
                                                  }
                                                , { amount = Just (Amount.fromFloat 5.5)
                                                  , processId = panCooking.id
                                                  }
                                                ]
                                            )
                                        )
                            )
                        , itFromResult2 "should decode product category consumptions from process ids"
                            (findProcessByLabel requirements "Réfrigération")
                            (findProcessByLabel requirements "Cuisson au four")
                            (\refrigeration ovenCooking ->
                                ("""[{
                                      "cooling": false,
                                      "consumptions": ["{{refrigerationId}}", "{{ovenCookingId}}"],
                                      "id": "5fad4e70-5736-552d-a686-97e4fb627c37",
                                      "label": "Test category",
                                      "scope": "food2"
                                    }]"""
                                    |> String.replace "{{refrigerationId}}" (Process.idToString refrigeration.id)
                                    |> String.replace "{{ovenCookingId}}" (Process.idToString ovenCooking.id)
                                )
                                    |> Product.decodeListFromJsonString
                                    |> Result.map (List.head >> Maybe.map .consumptions)
                                    |> Expect.equal
                                        (Ok
                                            (Just
                                                [ { amount = Nothing
                                                  , processId = refrigeration.id
                                                  }
                                                , { amount = Nothing
                                                  , processId = ovenCooking.id
                                                  }
                                                ]
                                            )
                                        )
                            )
                        , itFromResult "should decode product category assembly from process ids"
                            (findProcessByLabel requirements "Assemblage")
                            (\assemblage ->
                                ("""[{
                                      "assembly": ["{{assemblageId}}"],
                                      "cooling": false,
                                      "id": "5fad4e70-5736-552d-a686-97e4fb627c37",
                                      "label": "Test category",
                                      "scope": "veli"
                                    }]"""
                                    |> String.replace "{{assemblageId}}" (Process.idToString assemblage.id)
                                )
                                    |> Product.decodeListFromJsonString
                                    |> Result.map (List.head >> Maybe.map .assembly)
                                    |> Expect.equal (Ok (Just [ assemblage.id ]))
                            )
                        , itFromResult "should clear product, distribution, consumptions, assembly operations, and category cooling when unset"
                            (requirements.db.products |> List.head |> Result.fromMaybe "no product categories in test db")
                            (\categoryProduct ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> Component.updateProduct Nothing
                                    |> Expect.all
                                        [ .product >> Expect.equal Nothing
                                        , .assembly >> .operations >> Expect.equal Nothing
                                        , .distribution >> Expect.equal Nothing
                                        , .consumptions >> Expect.equal Nothing
                                        , .transportOptions >> .cooling >> Expect.equal Nothing
                                        ]
                            )
                        , itFromResult "should reset product category-dependent fields to Nothing when selecting a product"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\categoryProduct ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> Expect.all
                                        [ .product >> Expect.equal (Just categoryProduct.id)
                                        , .assembly >> .operations >> Expect.equal Nothing
                                        , .consumptions >> Expect.equal Nothing
                                        , .distribution >> Expect.equal Nothing
                                        , .transportOptions >> .cooling >> Expect.equal Nothing
                                        ]
                            )
                        , itFromResult2 "should apply category default consumptions when selecting a product"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProcessByLabel requirements "Réfrigération")
                            (\categoryProduct refrigeration ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> Component.getConsumptions requirements
                                    |> List.map Component.getConsumptionProcessId
                                    |> Expect.equal [ refrigeration.id ]
                            )
                        , itFromResult2 "should replace resolved consumptions when selecting another product category"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProductCategoryByLabel requirements "Produits congelés")
                            (\charcuterie frozen ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.updateProduct (Just frozen)
                                    |> Component.getConsumptions requirements
                                    |> List.map Component.getConsumptionProcessId
                                    |> Expect.equal (List.map .processId frozen.consumptions)
                            )
                        , itFromResult "should not reset explicit consumptions when re-selecting the same product"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\categoryProduct ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> (\query -> { query | consumptions = Just [] })
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> .consumptions
                                    |> Expect.equal (Just [])
                            )
                        , itFromResult2 "should let an explicit consumptions list take precedence over the category"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProcessByLabel requirements "Cuisson au four")
                            (\charcuterie ovenCooking ->
                                { emptyQuery
                                    | consumptions = Just [ Component.consumption (Amount.fromFloat 1) ovenCooking.id ]
                                    , product = Just charcuterie.id
                                }
                                    |> Component.getConsumptions requirements
                                    |> List.map Component.getConsumptionProcessId
                                    |> Expect.equal [ ovenCooking.id ]
                            )
                        , itFromResult "should let an explicit empty consumptions list take precedence over the category"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\charcuterie ->
                                { emptyQuery
                                    | consumptions = Just []
                                    , product = Just charcuterie.id
                                }
                                    |> Component.getConsumptions requirements
                                    |> Expect.equal []
                            )
                        , it "should resolve no consumptions when product and query are unspecified" <|
                            (emptyQuery
                                |> Component.getConsumptions requirements
                                |> Expect.equal []
                            )
                        , itFromResult "should preserve explicit consumptions so deleting them all does not leverage category defaults"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\charcuterie ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.removeConsumption requirements 0
                                    |> Expect.all
                                        [ .consumptions >> Expect.equal (Just [])
                                        , Component.getConsumptions requirements >> Expect.equal []
                                        ]
                            )
                        , itFromResult2 "should preserve category consumptions when adding one"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProcessByLabel requirements "Cuisson au four")
                            (\charcuterie ovenCooking ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.addConsumption requirements ovenCooking.id
                                    |> Component.getConsumptions requirements
                                    |> List.map Component.getConsumptionProcessId
                                    |> Expect.equal (List.map .processId charcuterie.consumptions ++ [ ovenCooking.id ])
                            )
                        , itFromResult2 "should update category consumption when explicitely updating its amount"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProcessByLabel requirements "Réfrigération")
                            (\charcuterie refrigeration ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.updateConsumptionAmount requirements 0 (Amount.fromFloat 3)
                                    |> .consumptions
                                    |> Expect.equal (Just [ Component.consumption (Amount.fromFloat 3) refrigeration.id ])
                            )
                        , itFromResult2 "should apply category default assembly operations when selecting a product"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (findProcessByLabel requirements "Assemblage")
                            (\categoryProduct assemblage ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> Component.getAssemblyOperations requirements
                                    |> Expect.equal [ assemblage.id ]
                            )
                        , itFromResult2 "should replace resolved assembly operations when selecting another product category"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\bikes charcuterie ->
                                emptyQuery
                                    |> Component.updateProduct (Just bikes)
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Expect.all
                                        [ .assembly >> .operations >> Expect.equal Nothing
                                        , Component.getAssemblyOperations requirements >> Expect.equal []
                                        ]
                            )
                        , itFromResult "should not reset explicit assembly operations when re-selecting the same product"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (\categoryProduct ->
                                emptyQuery
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> (\({ assembly } as query) ->
                                            { query | assembly = { assembly | operations = Just [] } }
                                       )
                                    |> Component.updateProduct (Just categoryProduct)
                                    |> .assembly
                                    |> .operations
                                    |> Expect.equal (Just [])
                            )
                        , itFromResult2 "should let an explicit assembly operations list take precedence over the category"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (findProcessByLabel requirements "Assemblage - calcul réglementaire Score Environnemental VE")
                            (\bikes regulatoryAssemblage ->
                                { emptyQuery
                                    | assembly = { emptyAssembly | operations = Just [ regulatoryAssemblage.id ] }
                                    , product = Just bikes.id
                                }
                                    |> Component.getAssemblyOperations requirements
                                    |> Expect.equal [ regulatoryAssemblage.id ]
                            )
                        , itFromResult "should let an explicit empty assembly operations list take precedence over the category"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (\bikes ->
                                { emptyQuery
                                    | assembly = { emptyAssembly | operations = Just [] }
                                    , product = Just bikes.id
                                }
                                    |> Component.getAssemblyOperations requirements
                                    |> Expect.equal []
                            )
                        , it "should resolve no assembly operations when product and query are unspecified" <|
                            (emptyQuery
                                |> Component.getAssemblyOperations requirements
                                |> Expect.equal []
                            )
                        , itFromResult "should preserve explicit assembly operations so deleting them all does not leverage category defaults"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (\bikes ->
                                emptyQuery
                                    |> Component.updateProduct (Just bikes)
                                    |> Component.removeAssemblyOperation requirements 0
                                    |> Expect.all
                                        [ .assembly >> .operations >> Expect.equal (Just [])
                                        , Component.getAssemblyOperations requirements >> Expect.equal []
                                        ]
                            )
                        , itFromResult2 "should preserve category assembly operations when adding one"
                            (findProductCategoryByLabel requirements "Vélos et VAEs de moins de 100kg")
                            (findProcessByLabel requirements "Assemblage - calcul réglementaire Score Environnemental VE")
                            (\bikes regulatoryAssemblage ->
                                emptyQuery
                                    |> Component.updateProduct (Just bikes)
                                    |> Component.addAssemblyOperation requirements regulatoryAssemblage
                                    |> Component.getAssemblyOperations requirements
                                    |> Expect.equal (bikes.assembly ++ [ regulatoryAssemblage.id ])
                            )
                        , itFromResult "should use product category cooling when the query doesn't set it"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\charcuterie ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.getTransportCooling requirements
                                    |> Expect.equal True
                            )
                        , itFromResult "should let an explicit cooling value have precedence over product category defaults"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\charcuterie ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.setTransportCooling False
                                    |> Component.getTransportCooling requirements
                                    |> Expect.equal False
                            )
                        , itFromResult "should disable product category cooling when the query doesn't set it"
                            (findProductCategoryByLabel requirements "Céréales brutes")
                            (\cereals ->
                                emptyQuery
                                    |> Component.updateProduct (Just cereals)
                                    |> Component.getTransportCooling requirements
                                    |> Expect.equal False
                            )
                        , itFromResult "should resolve product category distribution when the query doesn't set it"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (\charcuterie ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.getDistributionProcessId { requirements | scope = Scope.Generic Scope.Food2 }
                                    |> Expect.equal charcuterie.distribution
                            )
                        , itFromResult2 "should let explicit distribution taking precedence over product category value"
                            (findProductCategoryByLabel requirements "Charcuterie")
                            (findProductCategoryByLabel requirements "Produits congelés")
                            (\charcuterie frozen ->
                                emptyQuery
                                    |> Component.updateProduct (Just charcuterie)
                                    |> Component.updateDistribution frozen.distribution
                                    |> Component.getDistributionProcessId { requirements | scope = Scope.Generic Scope.Food2 }
                                    |> Expect.equal frozen.distribution
                            )
                        , it "should reject a query carrying an unknown product id" <|
                            (Product.idFromString nonExistentUuid
                                |> Result.andThen
                                    (\id ->
                                        { emptyQuery | product = Just id }
                                            |> Component.validateQuery requirements
                                    )
                                |> expectResultErrorContains "Catégorie de produit introuvable"
                            )
                        , it "should reject a query with an invalid product uuid" <|
                            ("""{"components":[],"product":"not-a-uuid"}"""
                                |> decodeJson Component.decodeQuery
                                |> Expect.err
                            )
                        , it "should fall back to the scoped default distribution process when product is unset" <|
                            (emptyQuery
                                |> Component.getDistributionProcessId { requirements | scope = Scope.Generic Scope.Food2 }
                                |> Expect.equal
                                    (requirements.config.distribution.defaultProcess
                                        |> Scope.dictGetMaybe (Scope.Generic Scope.Food2)
                                        |> Maybe.map .id
                                    )
                            )
                        , it "should not fall back to a scoped default distribution process from another scope" <|
                            (emptyQuery
                                |> Component.getDistributionProcessId requirements
                                |> Expect.equal Nothing
                            )
                        ]
                    ]
                )
            ]


doubledQuantitiesExpectations : LifeCycle -> LifeCycle -> List Test
doubledQuantitiesExpectations base doubled =
    let
        expectDoubledImpacts a b =
            getEcsImpact b
                |> expectFloatMostlyEqual (getEcsImpact a * 2)

        expectDistancesUntouched expected =
            Expect.all
                [ .air >> Expect.equal expected.air
                , .road >> Expect.equal expected.road
                , .roadCooled >> Expect.equal expected.roadCooled
                , .sea >> Expect.equal expected.sea
                , .seaCooled >> Expect.equal expected.seaCooled
                ]
    in
    [ it "should double transport to assembly impacts when quantity doubles"
        (doubled.transports.toAssembly.impacts
            |> expectDoubledImpacts base.transports.toAssembly.impacts
        )
    , it "should keep distances to assembly unchanged when quantity doubles"
        (doubled.transports.toAssembly
            |> expectDistancesUntouched base.transports.toAssembly
        )
    , it "should double transport to distribution impacts when quantity doubles"
        (doubled.transports.toDistribution.impacts
            |> expectDoubledImpacts base.transports.toDistribution.impacts
        )
    , it "should keep distances to distribution unchanged when quantity doubles"
        (doubled.transports.toDistribution
            |> expectDistancesUntouched base.transports.toDistribution
        )
    ]


{-| A test uuid we're pretty sure that doesn't exist in our datasets
-}
nonExistentUuid : String
nonExistentUuid =
    "5fad4e70-5736-552d-a686-97e4fb627c37"


computeAssemblyEcsImpact : Requirements db -> String -> Result String Float
computeAssemblyEcsImpact requirements =
    decodeJsonThen Component.decodeQuery (Component.compute requirements)
        >> Result.map (.assembly >> Component.extractImpacts >> getEcsImpact)


computeItemsWithRequirements : Requirements db -> List Item -> Result String LifeCycle
computeItemsWithRequirements requirements items =
    emptyQuery
        |> Component.setQueryItems items
        |> Component.compute requirements


createTestRequirements : Db -> Result String (Requirements Db)
createTestRequirements db =
    TestUtils.componentConfig db
        |> Result.map
            (\config ->
                { config = config
                , db = db
                , scope = Scope.Generic Scope.Object
                }
            )


extractEcsImpact : Component.Results -> Float
extractEcsImpact =
    Component.extractImpacts >> getEcsImpact


extractComplementEcsImpact : Component.Results -> Float
extractComplementEcsImpact =
    Component.extractComplementsImpacts >> Complement.mergeComplementsResultsImpacts >> getEcsImpact


findProcessByLabel : Requirements db -> String -> Result String Process
findProcessByLabel { db } label =
    db.processes
        |> List.filter (Process.getDisplayName >> (==) label)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable label=" ++ label)


findProductCategoryByLabel : Requirements db -> String -> Result String ProductCategory
findProductCategoryByLabel { db } label =
    db.products
        |> List.filter (.label >> (==) label)
        |> List.head
        |> Result.fromMaybe ("Catégorie de produit introuvable label=" ++ label)


getEcsImpact : Impacts -> Float
getEcsImpact =
    Impact.getImpact Definition.Ecs >> Unit.impactToFloat


decodeJson : Decoder a -> String -> Result String a
decodeJson decoder =
    Decode.decodeString decoder
        >> Result.mapError Decode.errorToString


decodeJsonThen : Decoder a -> (a -> Result String b) -> String -> Result String b
decodeJsonThen decoder fn =
    decodeJson decoder
        >> Result.andThen fn


elementTransformCountryAt : Int -> Int -> Int -> List Item -> Maybe CountryCode.Code
elementTransformCountryAt itemIndex elementIndex transformIndex items =
    items
        |> LE.getAt itemIndex
        |> Maybe.andThen .custom
        |> Maybe.andThen (.elements >> LE.getAt elementIndex)
        |> Maybe.andThen (.transforms >> LE.getAt transformIndex)
        |> Maybe.andThen .country


resetProcessElecAndHeat : Process -> Process
resetProcessElecAndHeat process =
    { process
        | elec = Quantity.zero
        , heat = Quantity.zero
    }


setProcessEcsImpact : Unit.Impact -> Process -> Process
setProcessEcsImpact ecs process =
    { process
        | impacts =
            process.impacts
                |> Impact.insertWithoutAggregateComputation Definition.Ecs ecs
    }


setProcessQtyVariationRatio : Unit.QuantityVariationRatio -> Process -> Process
setProcessQtyVariationRatio qtyVariationRatio process =
    { process | qtyVariationRatio = qtyVariationRatio }


setupTestDb : Db -> Db
setupTestDb db =
    -- update db with controled test components and processes; the idea is to decouple
    -- test data from the production data lifecycle as much as possible
    let
        componentFixtures =
            RE.combine
                [ chairSeat
                , chairBack
                , chairLeg
                , sofaFabric
                ]

        processFixtures =
            RE.combine
                [ steel
                , injectionMoulding
                , dryDistribution
                , fakeAssemblyProcess
                , lowVoltageElec
                , wood
                , plastic
                , sawing
                , chipsBag
                ]

        replace : List { a | id : id } -> List { a | id : id } -> List { a | id : id }
        replace replacements =
            List.filter (\{ id } -> replacements |> List.map .id |> List.member id |> not)
                >> (++) replacements
    in
    Ok
        (\testComponents testProcesses ->
            { db
                | components = db.components |> replace testComponents
                , processes = db.processes |> replace testProcesses
            }
        )
        |> RE.andMap componentFixtures
        |> RE.andMap processFixtures
        |> Result.withDefault db


updateRequirementsProcess : Process -> (Process -> Process) -> Requirements db -> Requirements db
updateRequirementsProcess { id } fn ({ db } as requirements) =
    { requirements
        | db = { db | processes = db.processes |> LE.updateIf (.id >> (==) id) fn }
    }



-- JSON test data
-- 1. Components


chairBack : Result String Component
chairBack =
    decodeJson Component.decode <|
        """ {
                "elements": [
                {
                    "amount": 0.734063,
                    "material": "59b42284-3e45-5343-8a20-1d7d66137461"
                }
                ],
                "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973",
                "name": "Dossier plastique (PP)",
                "scopes": ["object"]
            }
        """


chairLeg : Result String Component
chairLeg =
    decodeJson Component.decode <|
        """ {
                "elements": [
                {
                    "amount": 0.00022,
                    "material": "17431e06-2973-516e-b043-be9ad405e4fb"
                }
                ],
                "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                "name": "Pied 70 cm (plein bois)",
                "scopes": ["object"]
            }
        """


chairSeat : Result String Component
chairSeat =
    decodeJson Component.decode <|
        """ {
                "elements": [
                {
                    "amount": 0.91125,
                    "material": "59b42284-3e45-5343-8a20-1d7d66137461"
                }
                ],
                "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6",
                "name": "Assise plastique (PP)",
                "scopes": ["object"]
            }
        """


sofaFabric : Result String Component
sofaFabric =
    decodeJson Component.decode <|
        """ {
                "elements": [
                    {
                        "amount": 1,
                        "material": "f0dbe27b-1e74-55d0-88a2-bda812441744",
                        "transforms": [
                            "29dc6c73-8d82-5056-8ac0-faf212bc0367",
                            "c49a5379-95c4-599a-84da-b5faaa345b97"
                        ]
                    },
                    {
                        "amount": 1,
                        "material": "61bab541-9097-5680-9884-254c98f25d80",
                        "transforms": [
                            "29dc6c73-8d82-5056-8ac0-faf212bc0367",
                            "e5e43c57-bd12-5ab7-8a22-7d12cdcece58"
                        ]
                    }
                ],
                "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
                "name": "Tissu pour canapé",
                "scopes": ["object"]
            }
        """



-- 2. Processes


chipsBag : Result String Process
chipsBag =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
              "activityName": "Chips, 150g | Packaging System, Proxy Pack, Plastic film {FR} U",
              "alias": null,
              "categories": [
                "material",
                "packaging",
                "packaging_type:bag"
              ],
              "comment": "blah",
              "displayName": "Sachet en plastique (PP) pour chips - 150g - Proxy",
              "elecKwh": 0,
              "heatMJ": 0,
              "id": "4a80c078-9f86-4a7d-b402-73db3381e33b",
              "impacts": {
                "ecs": 1.358
              },
              "landOccupation": null,
              "location": "FR",
              "massPerUnit": 0.00538,
              "metadata": null,
              "qtyVariationRatio": 1.0,
              "scopes": [
                "food2"
              ],
              "source": "Agribalyse 3.2",
              "unit": "item"
            }
            """


dryDistribution : Result String Process
dryDistribution =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
            "activityName": "This process is not linked to a Brightway activity",
            "categories": [
                "distribution"
            ],
            "comment": "Blah",
            "displayName": "Vente au détail\u{202F}: produit sec",
            "elecKwh": 123.0805556,
            "heatMJ": 0,
            "id": "29118025-efa0-47bb-94e2-f5ccba31a903",
            "impacts": {
                "acd": 0,
                "cch": 0,
                "ecs": 0,
                "etf": 0,
                "etf-c": 0,
                "fru": 0,
                "fwe": 0,
                "htc": 0,
                "htc-c": 0,
                "htn": 0,
                "htn-c": 0,
                "ior": 0,
                "ldu": 0,
                "mru": 0,
                "ozd": 0,
                "pco": 0,
                "pma": 0,
                "swe": 0,
                "tre": 0,
                "wtu": 0
            },
            "landOccupation": null,
            "location": null,
            "massPerUnit": null,
            "metadata": null,
            "qtyVariationRatio": 1,
            "scopes": [
                "food2",
                "object"
            ],
            "source": "Ecobalyse_manual_lcia",
            "unit": "m3"
        }
        """


fakeAssemblyProcess : Result String Process
fakeAssemblyProcess =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "fake assembly process",
                "categories": ["assembly"],
                "comment": "Test fixture",
                "displayName": "Fake assembly process",
                "elecKwh": 1.5,
                "heatMJ": 3,
                "id": "b8d0dc25-170d-4c6a-93e5-ee31347316cc",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 42,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "RER",
                "massPerUnit": null,
                "qtyVariationRatio": 0.5,
                "scopes": ["object", "veli"],
                "source": "Ecobalyse",
                "unit": "kg"
            }
        """


injectionMoulding : Result String Process
injectionMoulding =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "injection moulding//[RER] injection moulding",
                "categories": ["transformation", "material_type:rigid_plastics"],
                "comment": "",
                "displayName": "Moulage par injection",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "111539de-deea-588a-9581-6f6ceaa2dfa9",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 67.739,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "RER",
                "massPerUnit": null,
                "qtyVariationRatio": 0.994,
                "scopes": ["object", "veli"],
                "source": "Ecoinvent 3.9.1",
                "unit": "kg"
            }
        """


lowVoltageElec : Result String Process
lowVoltageElec =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "electricity, low voltage//[FR] market for electricity, low voltage",
                "categories": ["energy", "use"],
                "comment": "",
                "displayName": "Electricité basse tension, France",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "931c9bb0-619a-5f75-b41b-ab8061e2ad92",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 19.331,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "FR",
                "massPerUnit": null,
                "qtyVariationRatio": 1,
                "scopes": [
                    "food",
                    "textile",
                    "veli"
                ],
                "source": "Ecoinvent 3.9.1",
                "unit": "kWh"
            }
        """


plastic : Result String Process
plastic =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "polypropylene, granulate//[RER] polypropylene production, granulate",
                "categories": ["material", "material_type:rigid_plastics"],
                "comment": "",
                "displayName": "Plastique granulé (PP)",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "59b42284-3e45-5343-8a20-1d7d66137461",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 164.69,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "RER",
                "massPerUnit": null,
                "qtyVariationRatio": 1,
                "scopes": ["object"],
                "source": "Ecoinvent 3.9.1",
                "unit": "kg"
            }
        """


sawing : Result String Process
sawing =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "Sawing + kiln drying in Europe (wood)",
                "categories": ["transformation", "material_type:wood"],
                "comment": "",
                "displayName": "Sciage + séchage au four en Europe (bois)",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "c172d131-b5d1-5d9b-822b-5762afb91c66",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 12732.0,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "GLO",
                "massPerUnit": null,
                "qtyVariationRatio": 0.5,
                "scopes": ["object"],
                "source": "Ecobalyse_custom_lci",
                "unit": "m3"
            }
        """


steel : Result String Process
steel =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "steel, low-alloyed//[GLO] market for steel, low-alloyed",
                "categories": ["material", "material_type:ferrous_metals"],
                "comment": "",
                "displayName": "Acier (faiblement allié)",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "6527710e-2434-5347-9bef-2205e0aa4f66",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 160.04,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "GLO",
                "massPerUnit": null,
                "qtyVariationRatio": 1,
                "scopes": ["food2", "textile"],
                "source": "Ecoinvent 3.9.1",
                "unit": "kg"
            }
        """


wood : Result String Process
wood =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "activityName": "sawlog and veneer log, hardwood, measured as solid wood under bark//[DE] hardwood forestry, beech, sustainable forest management",
                "categories": ["material", "material_type:wood"],
                "comment": "",
                "displayName": "Bois d'oeuvre (Feuillus / Hêtre)",
                "elecKwh": 0,
                "heatMJ": 0,
                "id": "17431e06-2973-516e-b043-be9ad405e4fb",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 6439.2,
                    "etf": 0,
                    "etf-c": 0,
                    "fru": 0,
                    "fwe": 0,
                    "htc": 0,
                    "htc-c": 0,
                    "htn": 0,
                    "htn-c": 0,
                    "ior": 0,
                    "ldu": 0,
                    "mru": 0,
                    "ozd": 0,
                    "pco": 0,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "location": "DE",
                "massPerUnit": 660.0,
                "metadata": {
                  "complements": {
                    "forest": 0.70731
                  },
                  "forestManagement": "intensivePlantation"
                },
                "qtyVariationRatio": 1,
                "scopes": ["object", "veli"],
                "source": "Ecoinvent 3.9.1",
                "unit": "m3"
            }
        """



-- 3. Items (example)


chair : Result String (List Item)
chair =
    decodeJson (Decode.list Component.decodeItem) <|
        """ [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
            , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
            , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
            ]
        """
