module Data.ComponentTest exposing (..)

import Data.Component as Component exposing (Component, Item)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Expect
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import List.Extra as LE
import Mass
import Quantity
import Result.Extra as RE
import Static.Db exposing (Db)
import Test exposing (..)
import TestUtils exposing (expectResultErrorContains, it, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Component"
        (\originalDb ->
            let
                -- these will be adapted and used as test transform processes
                ( fading, weaving ) =
                    ( originalDb.textile.wellKnown.fading
                    , originalDb.textile.wellKnown.weaving
                    )

                db =
                    setupTestDb originalDb
            in
            [ TestUtils.suiteFromResult3 "addElement"
                -- setup
                chairBack
                steel
                injectionMoulding
                -- tests
                (\testComponent validMaterial invalidMaterial ->
                    [ it "should add a new element using a valid material"
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
                                        |> Maybe.map .material
                                )
                            -- it should be equal to the one we swapped in
                            |> Expect.equal (Ok (Just validMaterial.id))
                        )
                    , it "should reject an invalid element material"
                        (chair
                            |> Result.andThen (Component.addElement ( testComponent, 1 ) invalidMaterial)
                            |> expectResultErrorContains "L'ajout d'un élément ne peut se faire qu'à partir d'un procédé matière"
                        )
                    ]
                )
            , TestUtils.suiteFromResult3 "addElementTransform"
                -- setup
                chairBack
                injectionMoulding
                woodenBoard
                -- tests
                (\testComponent validTransformProcess invalidTransformProcess ->
                    [ it "should add a valid transformation process to a component element"
                        (chair
                            |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) validTransformProcess)
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
                            |> Expect.equal (Ok (Just [ validTransformProcess.id ]))
                        )
                    , it "should reject an invalid transformation process"
                        (chair
                            |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) invalidTransformProcess)
                            |> expectResultErrorContains "Seuls les procédés de catégorie `transformation` sont mobilisables comme procédés de transformation"
                        )
                    ]
                )
            , TestUtils.suiteFromResult "addItem"
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

            -- , describe "applyTransforms"
            --     [ let
            --         getTestMass transforms =
            --             Component.Results
            --                 { impacts = Impact.empty
            --                 , items = []
            --                 , mass = Mass.kilogram
            --                 , stage = Nothing
            --                 }
            --                 |> Component.applyTransforms db.processes Process.Kilogram transforms
            --                 |> Result.withDefault Component.emptyResults
            --                 |> Component.extractMass
            --                 |> Mass.inKilograms
            --       in
            --       describe "waste"
            --         [ it "should not apply any waste when no transforms are passed"
            --             (getTestMass []
            --                 |> Expect.within (Expect.Absolute 0.00001) 1
            --             )
            --         , it "should apply waste when one transform is passed"
            --             (getTestMass [ { weaving | waste = Split.half } ]
            --                 |> Expect.within (Expect.Absolute 0.00001) 0.5
            --             )
            --         , it "should apply waste sequentially when multiple transforms are passed"
            --             (getTestMass [ { weaving | waste = Split.half }, { weaving | waste = Split.half } ]
            --                 |> Expect.within (Expect.Absolute 0.00001) 0.25
            --             )
            --         ]
            --     , let
            --         getTestEcsImpact transforms =
            --             Component.Results
            --                 { impacts = Impact.empty
            --                 , items = []
            --                 , mass = Mass.kilogram
            --                 , stage = Nothing
            --                 }
            --                 |> Component.applyTransforms db.processes Process.Kilogram transforms
            --                 |> Result.withDefault Component.emptyResults
            --                 |> extractEcsImpact
            --       in
            --       describe "impacts"
            --         [ it "should not add impacts when no transforms are passed"
            --             (getTestEcsImpact []
            --                 |> Expect.within (Expect.Absolute 0.00001) 0
            --             )
            --         , it "should add impacts when one transform is passed (no elec, no heat)"
            --             (getTestEcsImpact
            --                 [ fading
            --                     |> resetProcessElecAndHeat
            --                     |> setProcessEcsImpact (Unit.impact 10)
            --                 ]
            --                 |> Expect.within (Expect.Absolute 1) 10
            --             )
            --         , it "should add impacts when one transform is passed (including elec and heat)"
            --             (getTestEcsImpact
            --                 [ { fading
            --                     | impacts =
            --                         fading.impacts
            --                             |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
            --                   }
            --                 ]
            --                 |> Expect.within (Expect.Absolute 1) 383
            --             )
            --         , it "should add impacts when multiple transforms are passed (no elec, no heat)"
            --             (getTestEcsImpact
            --                 [ fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 10)
            --                 , fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 20)
            --                 ]
            --                 |> Expect.within (Expect.Absolute 1) 30
            --             )
            --         , it "should add impacts when multiple transforms are passed (including elec and heat)"
            --             (getTestEcsImpact
            --                 [ fading |> setProcessEcsImpact (Unit.impact 10)
            --                 , fading |> setProcessEcsImpact (Unit.impact 20)
            --                 ]
            --                 |> Expect.within (Expect.Absolute 1) 776
            --             )
            --         ]
            --     , TestUtils.suiteFromResult "unit mismatch"
            --         injectionMoulding
            --         (\transformInKg ->
            --             [ it "should reject when the unit of the material and the transforms do not match"
            --                 (Component.Results
            --                     { impacts = Impact.empty
            --                     , items = []
            --                     , mass = Mass.kilogram
            --                     , stage = Nothing
            --                     }
            --                     |> Component.applyTransforms db.processes Process.CubicMeter [ transformInKg ]
            --                     |> Expect.equal (Err "Les procédés de transformation ne partagent pas la même unité que la matière source (m3)\u{00A0}: Moulage par injection (kg)")
            --                 )
            --             ]
            --         )
            --     , let
            --         getTestResults transforms =
            --             Component.Results
            --                 { impacts = Impact.empty |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 100)
            --                 , items = []
            --                 , mass = Mass.kilogram
            --                 , stage = Nothing
            --                 }
            --                 |> Component.applyTransforms db.processes Process.Kilogram transforms
            --                 |> Result.withDefault Component.emptyResults
            --       in
            --       describe "impacts & waste"
            --         [ let
            --             noElecAndNoHeat =
            --                 getTestResults
            --                     [ fading
            --                         |> resetProcessElecAndHeat
            --                         |> setProcessWaste Split.half
            --                         |> setProcessEcsImpact (Unit.impact 10)
            --                     , fading
            --                         |> resetProcessElecAndHeat
            --                         |> setProcessWaste Split.half
            --                         |> setProcessEcsImpact (Unit.impact 20)
            --                     ]
            --           in
            --           describe "excluding elec and heat"
            --             [ -- Note: impacts are always computed from input mass
            --               -- 100 + (1kg * 10) + (0.5kg * 20) = 120
            --               it "should handle impacts+waste when applying transforms: impacts"
            --                 (noElecAndNoHeat
            --                     |> extractEcsImpact
            --                     |> Expect.within (Expect.Absolute 1) 120
            --                 )
            --             -- (1kg * 0.5) * 0.5 == 0.25
            --             , it "should handle impacts+waste when applying transforms: mass"
            --                 (noElecAndNoHeat
            --                     |> Component.extractMass
            --                     |> Mass.inKilograms
            --                     |> Expect.within (Expect.Absolute 0.01) 0.25
            --                 )
            --             ]
            --         , let
            --             withElecAndHeat =
            --                 getTestResults
            --                     [ fading
            --                         |> setProcessWaste Split.half
            --                         |> setProcessEcsImpact (Unit.impact 10)
            --                     , fading
            --                         |> setProcessWaste Split.half
            --                         |> setProcessEcsImpact (Unit.impact 20)
            --                     ]
            --           in
            --           describe "including elec and heat"
            --             [ it "should handle impacts+waste when applying transforms: impacts"
            --                 (withElecAndHeat
            --                     |> extractEcsImpact
            --                     |> Expect.within (Expect.Absolute 1) 680
            --                 )
            --             , it "should handle impacts+waste when applying transforms: mass"
            --                 (withElecAndHeat
            --                     |> Component.extractMass
            --                     |> Mass.inKilograms
            --                     |> Expect.within (Expect.Absolute 0.01) 0.25
            --                 )
            --             ]
            --         ]
            --     ]
            , describe "compute"
                [ it "should compute results from decoded component items"
                    (chair
                        |> Result.andThen (Component.compute db)
                        |> Result.map extractEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 293
                    )
                , it "should compute results from decoded component items with custom component elements"
                    (""" [ {
                             "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                             "quantity": 4,
                             "custom": {
                               "elements": [
                                 {
                                   "amount": 0.00044,
                                   "material": "fe8a97ba-405a-5542-b1be-bd6983537d58",
                                   "transforms": []
                                 }
                               ]
                             }
                           }
                         , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                         , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                         ]"""
                        |> decodeJsonThen (Decode.list Component.decodeItem) (Component.compute db)
                        |> Result.map extractEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 314
                    )
                ]
            , TestUtils.suiteFromResult "computeElementResults"
                -- setup
                (Process.idFromString "f0dbe27b-1e74-55d0-88a2-bda812441744"
                    |> Result.andThen
                        (\cottonId ->
                            Component.computeElementResults db.processes
                                { amount = Component.Amount 1
                                , material = cottonId

                                -- Note: weaving: 0.06253, fading: 0
                                , transforms = [ weaving.id, fading.id ]
                                }
                        )
                )
                -- tests
                (\elementResults ->
                    [ it "should compute element impacts"
                        (elementResults
                            |> extractEcsImpact
                            |> Expect.within (Expect.Absolute 1) 2176
                        )
                    , it "should compute element mass"
                        (elementResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                            |> Expect.within (Expect.Absolute 0.000001) 1
                        )
                    ]
                )
            , describe "computeInitialAmount"
                [ it "should sequentially apply splits"
                    (Component.Amount 100
                        |> Component.computeInitialAmount [ Split.twenty, Split.half ]
                        -- 100 / (1 - 0.2) / (1 - 0.5) = 250
                        |> Expect.equal (Ok <| Component.Amount 250)
                    )
                , it "should succeed with initial amount when no transforms is applied"
                    (Component.Amount 100
                        |> Component.computeInitialAmount []
                        |> Expect.equal (Ok <| Component.Amount 100)
                    )
                , it "should error when a passed waste ratio is 100%"
                    (Component.Amount 100
                        |> Component.computeInitialAmount [ Split.full ]
                        |> expectResultErrorContains "Un taux de perte ne peut pas être de 100%"
                    )
                ]
            , describe "computeItemResults"
                (let
                    toComputedResults =
                        decodeJsonThen Component.decodeItem (Component.computeItemResults db)

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
                                  "material": "fe8a97ba-405a-5542-b1be-bd6983537d58"
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
                 ]
                )
            , TestUtils.suiteFromResult "itemToComponent"
                -- setup
                ("""{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                      "quantity": 1,
                      "custom": {
                        "name": "custom name",
                        "elements": [
                          {
                            "amount": 0.00044,
                            "material": "fe8a97ba-405a-5542-b1be-bd6983537d58"
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
                -- tests
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
            , TestUtils.suiteFromResult "itemToString"
                -- setup
                ("""{ "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                      "quantity": 1,
                      "custom": {
                        "name": "Custom piece",
                        "elements": [
                          {
                            "amount": 0.00044,
                            "material": "fe8a97ba-405a-5542-b1be-bd6983537d58"
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
                -- tests
                (\string ->
                    [ it "should serialise an item as a human readable string representation"
                        (Expect.equal string
                            "1 Custom piece [ 0.00044m3 Planche (bois de feuillus) | 0.00088kg Plastique granulé (PP) ]"
                        )
                    ]
                )
            , TestUtils.suiteFromResult2 "removeElement"
                -- setup
                sofaFabric
                steel
                -- tests
                (\testComponent material ->
                    [ it "should remove an item element"
                        (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }
                             ]"""
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
                            |> Expect.equal (Ok (Just 2))
                        )
                    ]
                )
            , TestUtils.suiteFromResult2 "removeElementTransform"
                chairBack
                injectionMoulding
                -- tests
                (\testComponent testProcess ->
                    [ it "should remove an element transform"
                        (chair
                            |> Result.andThen (Component.addElementTransform ( ( testComponent, 1 ), 0 ) testProcess)
                            |> Result.map (Component.removeElementTransform ( ( testComponent, 1 ), 0 ) 0)
                            |> Result.map (LE.getAt 1)
                            |> Expect.equal
                                (Ok <|
                                    Just
                                        { custom = Nothing
                                        , id = testComponent.id
                                        , quantity = Component.quantityFromInt 1
                                        }
                                )
                        )
                    ]
                )
            , TestUtils.suiteFromResult3 "setElementMaterial"
                -- setup
                chairBack
                steel
                injectionMoulding
                -- tests
                (\testComponent validTestProcess invalidTestProcess ->
                    [ it "should set a valid element material"
                        (chair
                            |> Result.andThen (Component.setElementMaterial ( ( testComponent, 1 ), 0 ) validTestProcess)
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
                                        |> Maybe.map .material
                                )
                            -- it should be equal to the one we swapped in
                            |> Expect.equal (Ok (Just validTestProcess.id))
                        )
                    , it "should reject an invalid element material"
                        (chair
                            |> Result.andThen (Component.setElementMaterial ( ( testComponent, 1 ), 0 ) invalidTestProcess)
                            |> expectResultErrorContains "Seuls les procédés de catégorie `material` sont mobilisables comme matière"
                        )
                    ]
                )
            , TestUtils.suiteFromResult "stagesImpacts"
                (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }
                     ]"""
                    |> decodeJsonThen (Decode.list Component.decodeItem) (Component.compute db)
                    |> Result.map (\results -> ( results, Component.stagesImpacts results ))
                )
                (\( results, stagesImpacts ) ->
                    [ it "should compute material stage impacts"
                        (stagesImpacts.material
                            |> getEcsImpact
                            |> Expect.greaterThan 0
                        )
                    , it "should compute transformation stage impacts"
                        (stagesImpacts.transformation
                            |> getEcsImpact
                            |> Expect.greaterThan 0
                        )
                    , it "should have total stages impacts equal total impacts"
                        ([ stagesImpacts.material, stagesImpacts.transformation ]
                            |> Impact.sumImpacts
                            |> getEcsImpact
                            |> Expect.within (Expect.Absolute 1) (extractEcsImpact results)
                        )
                    ]
                )
            , TestUtils.suiteFromResult "toggleCustomScope"
                -- See why we disabled multi-scopes decoding in Data.Component.decode
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
                (\( component, item ) ->
                    [ it "should have no custom scopes by default"
                        (item.custom
                            |> Expect.equal Nothing
                        )
                    , it "should toggle a custom scope"
                        (item
                            |> Component.toggleCustomScope component Scope.Textile False
                            |> .custom
                            |> Maybe.map .scopes
                            |> Expect.equal (Just [ Scope.Food ])
                        )
                    , it "should sequentially toggle custom scopes"
                        (item
                            |> Component.toggleCustomScope component Scope.Food False
                            |> Component.toggleCustomScope component Scope.Object False
                            |> Component.toggleCustomScope component Scope.Textile False
                            |> Component.toggleCustomScope component Scope.Object True
                            |> .custom
                            |> Maybe.map .scopes
                            |> Expect.equal (Just [ Scope.Object ])
                        )
                    , it "should reset custom scopes when they match initial component ones"
                        (item
                            |> Component.toggleCustomScope component Scope.Food False
                            |> Component.toggleCustomScope component Scope.Food True
                            |> .custom
                            |> Maybe.map .scopes
                            |> Expect.equal Nothing
                        )
                    , it "should export custom scopes to component"
                        (item
                            |> Component.toggleCustomScope component Scope.Textile False
                            |> Component.itemToComponent db
                            |> Result.map .scopes
                            |> Expect.equal (Ok [ Scope.Food ])
                        )
                    ]
                )
            , TestUtils.suiteFromResult "updateItemCustomName"
                -- setup
                sofaFabric
                -- tests
                (\testComponent ->
                    [ it "should set a custom name to a component item"
                        (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.updateItemCustomName ( testComponent, 0 ) "My custom component" >> Ok)
                            |> Result.map
                                (\items ->
                                    items
                                        |> LE.getAt 0
                                        |> Maybe.andThen .custom
                                        |> Maybe.andThen .name
                                )
                            |> Expect.equal (Ok (Just "My custom component"))
                        )
                    , it "should trim a custom item name when serializing it"
                        (""" [ { "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9", "quantity": 1 }
                             ]"""
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
                            |> Expect.equal (Ok (Just "My custom component"))
                        )
                    ]
                )
            ]
        )


extractEcsImpact : Component.Results -> Float
extractEcsImpact =
    Component.extractImpacts >> getEcsImpact


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


setProcessWaste : Split -> Process -> Process
setProcessWaste waste process =
    { process | waste = waste }


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
                , woodenBoard
                , plastic
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
                "scopes": ["food", "object", "textile", "veli"]
            }
        """


chairLeg : Result String Component
chairLeg =
    decodeJson Component.decode <|
        """ {
                "elements": [
                {
                    "amount": 0.00022,
                    "material": "fe8a97ba-405a-5542-b1be-bd6983537d58"
                }
                ],
                "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                "name": "Pied 70 cm (plein bois)",
                "scopes": ["food", "object", "textile", "veli"]
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
                "scopes": ["food", "object", "textile", "veli"]
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
                "scopes": ["food", "object", "textile"]
            }
        """



-- 2. Processes


injectionMoulding : Result String Process
injectionMoulding =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "categories": ["transformation"],
                "comment": "",
                "density": 0,
                "displayName": "Moulage par injection",
                "elecMJ": 0,
                "heatMJ": 0,
                "id": "111539de-deea-588a-9581-6f6ceaa2dfa9",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 75.9018,
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
                    "pef": 81.8084,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "scopes": ["object"],
                "source": "Ecoinvent 3.9.1",
                "sourceId": "injection moulding//[RER] injection moulding",
                "unit": "kg",
                "waste": 0.006
            }
        """


plastic : Result String Process
plastic =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "categories": ["material"],
                "comment": "",
                "density": 0,
                "displayName": "Plastique granulé (PP)",
                "elecMJ": 0,
                "heatMJ": 0,
                "id": "59b42284-3e45-5343-8a20-1d7d66137461",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 165.71,
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
                    "pef": 192.164,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "scopes": ["object"],
                "source": "Ecoinvent 3.9.1",
                "sourceId": "polypropylene, granulate//[RER] polypropylene production, granulate",
                "unit": "kg",
                "waste": 0
            }
        """


steel : Result String Process
steel =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "categories": ["material"],
                "comment": "",
                "density": 0,
                "displayName": "Acier",
                "elecMJ": 0,
                "heatMJ": 0,
                "id": "6527710e-2434-5347-9bef-2205e0aa4f66",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 172.483,
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
                    "pef": 201.311,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "scopes": ["object"],
                "source": "Ecoinvent 3.9.1",
                "sourceId": "steel, low-alloyed//[GLO] market for steel, low-alloyed",
                "unit": "kg",
                "waste": 0
            }
        """


woodenBoard : Result String Process
woodenBoard =
    decodeJson (Process.decode Impact.decodeImpacts) <|
        """ {
                "categories": ["material"],
                "comment": "",
                "density": 600.0,
                "displayName": "Planche (bois de feuillus)",
                "elecMJ": 0,
                "heatMJ": 0,
                "id": "fe8a97ba-405a-5542-b1be-bd6983537d58",
                "impacts": {
                    "acd": 0,
                    "cch": 0,
                    "ecs": 23623.4,
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
                    "pef": 27337.4,
                    "pma": 0,
                    "swe": 0,
                    "tre": 0,
                    "wtu": 0
                },
                "scopes": ["object"],
                "source": "Ecoinvent 3.9.1",
                "sourceId": "sawnwood, board, hardwood, dried (u=10%), planed//[Europe without Switzerland] market for sawnwood, board, hardwood, dried (u=10%), planed",
                "unit": "m3",
                "waste": 0
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
