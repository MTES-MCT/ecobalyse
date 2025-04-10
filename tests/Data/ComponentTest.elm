module Data.ComponentTest exposing (..)

import Data.Component as Component exposing (Component)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
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
        (\db ->
            let
                -- these will be adapted and used as test transform processes
                ( fading, weaving ) =
                    ( db.textile.wellKnown.fading
                    , db.textile.wellKnown.weaving
                    )
            in
            [ TestUtils.suiteFromResult3 "addElement"
                -- Dossier plastique (PP)
                (getComponentByStringId db "ad9d7f23-076b-49c5-93a4-ee1cd7b53973")
                -- Steel (valid as a material)
                (getProcessByStringId db "8b91651b-9651-46fc-8bc2-37a141494086")
                -- Injection moulding (invalid as a material)
                (getProcessByStringId db "b1177e7f-e14e-415c-9077-c7063e1ab8cd")
                -- tests
                (\testComponent validMaterial invalidMaterial ->
                    [ it "should add a new element using a valid material"
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.addElement ( testComponent, 1 ) validMaterial)
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
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.addElement ( testComponent, 1 ) invalidMaterial)
                            |> expectResultErrorContains "L'ajout d'un élément ne peut se faire qu'à partir d'un procédé matière"
                        )
                    ]
                )
            , TestUtils.suiteFromResult3 "addElementTransform"
                -- Dossier plastique (PP)
                (getComponentByStringId db "ad9d7f23-076b-49c5-93a4-ee1cd7b53973")
                -- Injection moulding (valid tansformation process)
                (getProcessByStringId db "b1177e7f-e14e-415c-9077-c7063e1ab8cd")
                -- Planche de bois (invalid as not a transformation process)
                (getProcessByStringId db "07e9e916-e02b-45e2-a298-2b5084de6242")
                -- tests
                (\testComponent validTransformProcess invalidTransformProcess ->
                    [ it "should add a valid transformation process to a component element"
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.addElementTransform ( ( testComponent, 1 ), 0 ) validTransformProcess)
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
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.addElementTransform ( ( testComponent, 1 ), 0 ) invalidTransformProcess)
                            |> expectResultErrorContains "Seuls les procédés de catégorie `transformation` sont mobilisables comme procédés de transformation"
                        )
                    ]
                )
            , TestUtils.suiteFromResult "addItem"
                -- Dossier plastique (PP)
                (getComponentByStringId db "ad9d7f23-076b-49c5-93a4-ee1cd7b53973")
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
                            { impacts = Impact.empty
                            , items = []
                            , mass = Mass.kilogram
                            , stage = Nothing
                            }
                            |> Component.applyTransforms db.processes transforms
                            |> Result.withDefault Component.emptyResults
                            |> Component.extractMass
                            |> Mass.inKilograms
                  in
                  describe "waste"
                    [ it "should not apply any waste when no transforms are passed"
                        (getTestMass []
                            |> Expect.within (Expect.Absolute 0.00001) 1
                        )
                    , it "should apply waste when one transform is passed"
                        (getTestMass [ { weaving | waste = Split.half } ]
                            |> Expect.within (Expect.Absolute 0.00001) 0.5
                        )
                    , it "should apply waste sequentially when multiple transforms are passed"
                        (getTestMass [ { weaving | waste = Split.half }, { weaving | waste = Split.half } ]
                            |> Expect.within (Expect.Absolute 0.00001) 0.25
                        )
                    ]
                , let
                    getTestEcsImpact transforms =
                        Component.Results
                            { impacts = Impact.empty
                            , items = []
                            , mass = Mass.kilogram
                            , stage = Nothing
                            }
                            |> Component.applyTransforms db.processes transforms
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
                            |> Expect.within (Expect.Absolute 1) 10
                        )
                    , it "should add impacts when one transform is passed (including elec and heat)"
                        (getTestEcsImpact
                            [ { fading
                                | impacts =
                                    fading.impacts
                                        |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 10)
                              }
                            ]
                            |> Expect.within (Expect.Absolute 1) 383
                        )
                    , it "should add impacts when multiple transforms are passed (no elec, no heat)"
                        (getTestEcsImpact
                            [ fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 10)
                            , fading |> resetProcessElecAndHeat |> setProcessEcsImpact (Unit.impact 20)
                            ]
                            |> Expect.within (Expect.Absolute 1) 30
                        )
                    , it "should add impacts when multiple transforms are passed (including elec and heat)"
                        (getTestEcsImpact
                            [ fading |> setProcessEcsImpact (Unit.impact 10)
                            , fading |> setProcessEcsImpact (Unit.impact 20)
                            ]
                            |> Expect.within (Expect.Absolute 1) 776
                        )
                    ]
                , let
                    getTestResults transforms =
                        Component.Results
                            { impacts = Impact.empty |> Impact.insertWithoutAggregateComputation Definition.Ecs (Unit.impact 100)
                            , items = []
                            , mass = Mass.kilogram
                            , stage = Nothing
                            }
                            |> Component.applyTransforms db.processes transforms
                            |> Result.withDefault Component.emptyResults
                  in
                  describe "impacts & waste"
                    [ let
                        noElecAndNoHeat =
                            getTestResults
                                [ fading
                                    |> resetProcessElecAndHeat
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 10)
                                , fading
                                    |> resetProcessElecAndHeat
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 20)
                                ]
                      in
                      describe "excluding elec and heat"
                        [ -- Note: impacts are always computed from input mass
                          -- 100 + (1kg * 10) + (0.5kg * 20) = 120
                          it "should handle impacts+waste when applying transforms: impacts"
                            (noElecAndNoHeat
                                |> extractEcsImpact
                                |> Expect.within (Expect.Absolute 1) 120
                            )

                        -- (1kg * 0.5) * 0.5 == 0.25
                        , it "should handle impacts+waste when applying transforms: mass"
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
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 10)
                                , fading
                                    |> setProcessWaste Split.half
                                    |> setProcessEcsImpact (Unit.impact 20)
                                ]
                      in
                      describe "including elec and heat"
                        [ it "should handle impacts+waste when applying transforms: impacts"
                            (withElecAndHeat
                                |> extractEcsImpact
                                |> Expect.within (Expect.Absolute 1) 679
                            )
                        , it "should handle impacts+waste when applying transforms: mass"
                            (withElecAndHeat
                                |> Component.extractMass
                                |> Mass.inKilograms
                                |> Expect.within (Expect.Absolute 0.01) 0.25
                            )
                        ]
                    ]
                ]
            , describe "compute"
                [ it "should compute results from decoded component items"
                    (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                         , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                         , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                         ]"""
                        |> decodeJsonThen (Decode.list Component.decodeItem) (Component.compute db)
                        |> Result.map extractEcsImpact
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 401
                    )
                , it "should compute results from decoded component items with custom component elements"
                    (""" [ {
                             "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                             "quantity": 4,
                             "custom": {
                               "elements": [
                                 {
                                   "amount": 0.00044,
                                   "material": "07e9e916-e02b-45e2-a298-2b5084de6242",
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
                        |> TestUtils.expectResultWithin (Expect.Absolute 1) 421
                    )
                ]
            , TestUtils.suiteFromResult "computeElementResults"
                -- setup
                (Process.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84"
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
                            |> Expect.within (Expect.Absolute 1) 2006
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
                                  "material": "07e9e916-e02b-45e2-a298-2b5084de6242"
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
                            "material": "07e9e916-e02b-45e2-a298-2b5084de6242"
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
                            "material": "07e9e916-e02b-45e2-a298-2b5084de6242"
                          },
                          {
                            "amount": 0.00088,
                            "material": "3295b2a5-328a-4c00-b046-e2ddeb0da823"
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
                            "1 Custom piece [ 0.00044m3 Planche (bois de feuillus) | 0.00088kg Composant en plastique (PP) ]"
                        )
                    ]
                )
            , TestUtils.suiteFromResult2 "removeElement"
                -- Tissu pour canapé
                (getComponentByStringId db "8ca2ca05-8aec-4121-acaa-7cdcc03150a9")
                -- Steel (valid as a material)
                (getProcessByStringId db "8b91651b-9651-46fc-8bc2-37a141494086")
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
                -- Dossier plastique (PP)
                (getComponentByStringId db "ad9d7f23-076b-49c5-93a4-ee1cd7b53973")
                -- Injection moulding
                (getProcessByStringId db "b1177e7f-e14e-415c-9077-c7063e1ab8cd")
                -- tests
                (\testComponent testProcess ->
                    [ it "should remove an element transform"
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.addElementTransform ( ( testComponent, 1 ), 0 ) testProcess
                                    >> Result.map (Component.removeElementTransform ( ( testComponent, 1 ), 0 ) 0)
                                )
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
                -- Dossier plastique (PP)
                (getComponentByStringId db "ad9d7f23-076b-49c5-93a4-ee1cd7b53973")
                -- Steel (valid as a material)
                (getProcessByStringId db "8b91651b-9651-46fc-8bc2-37a141494086")
                -- Injection moulding (invalid as a material)
                (getProcessByStringId db "b1177e7f-e14e-415c-9077-c7063e1ab8cd")
                -- tests
                (\testComponent validTestProcess invalidTestProcess ->
                    [ it "should set a valid element material"
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.setElementMaterial ( ( testComponent, 1 ), 0 ) validTestProcess)
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
                        (""" [ { "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08", "quantity": 4 }
                             , { "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973", "quantity": 1 }
                             , { "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6", "quantity": 1 }
                             ]"""
                            |> decodeJsonThen (Decode.list Component.decodeItem)
                                (Component.setElementMaterial ( ( testComponent, 1 ), 0 ) invalidTestProcess)
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
            , TestUtils.suiteFromResult "updateItemCustomName"
                -- Tissu pour canapé
                (getComponentByStringId db "8ca2ca05-8aec-4121-acaa-7cdcc03150a9")
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


getComponentByStringId : Db -> String -> Result String Component
getComponentByStringId db =
    Component.idFromString
        >> Result.andThen (\id -> Component.findById id db.components)


getProcessByStringId : Db -> String -> Result String Process
getProcessByStringId db =
    Process.idFromString
        >> Result.andThen (\id -> Process.findById id db.processes)


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
