module Data.Component exposing
    ( Amount(..)
    , Component
    , Custom
    , DataContainer
    , Element
    , ExpandedElement
    , Id
    , Index
    , Item
    , LifeCycle
    , Quantity
    , Results(..)
    , Stage(..)
    , TargetElement
    , TargetItem
    , addElement
    , addElementTransform
    , addItem
    , addOrSetProcess
    , amountToFloat
    , applyTransforms
    , compute
    , computeElementResults
    , computeImpacts
    , computeInitialAmount
    , computeItemResults
    , createItem
    , decode
    , decodeItem
    , decodeList
    , decodeListFromJsonString
    , elementTransforms
    , elementsToString
    , emptyLifeCycle
    , emptyResults
    , encode
    , encodeId
    , encodeItem
    , encodeLifeCycle
    , expandElements
    , expandItems
    , extractAmount
    , extractImpacts
    , extractItems
    , extractMass
    , findById
    , getEndOfLifeDetailedImpacts
    , getEndOfLifeImpacts
    , idFromString
    , idToString
    , isEmpty
    , itemToComponent
    , itemToString
    , itemsToString
    , quantityFromInt
    , quantityToInt
    , removeElement
    , removeElementTransform
    , setCustomScope
    , setElementMaterial
    , stagesImpacts
    , sumLifeCycleImpacts
    , updateElement
    , updateElementAmount
    , updateItem
    , updateItemCustomName
    , validateItem
    )

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Trigram)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Dict.Any as AnyDict exposing (AnyDict)
import Energy
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE


type Id
    = Id Uuid


{-| A Component is a named collection of elements
-}
type alias Component =
    { comment : Maybe String
    , elements : List Element
    , id : Id
    , name : String
    , scope : Scope
    }


type alias EnergyMixes =
    { elec : Process
    , heat : Process
    }


{-| A compact reference to a component, a quantity of it, and optionally some overrides,
typically used for queries
-}
type alias Item =
    { custom : Maybe Custom
    , id : Id
    , quantity : Quantity
    }


type alias Custom =
    { elements : List Element
    , name : Maybe String
    , scope : Maybe Scope
    }


{-| A Db-like interface holding components and processes
-}
type alias DataContainer db =
    { db
        | components : List Component
        , processes : List Process
    }


{-| A compact representation of an amount of material and optional transformations of it
-}
type alias Element =
    { amount : Amount
    , material : Process.Id
    , transforms : List Process.Id
    }


{-| A full representation of an amount of material and optional transformations of it
-}
type alias ExpandedElement =
    { amount : Amount
    , material : Process
    , transforms : List Process
    }


type alias Index =
    Int


{-| Index of an item element and associated source component
-}
type alias TargetElement =
    ( TargetItem, Index )


{-| Index of an item and associated source component
-}
type alias TargetItem =
    ( Component, Index )


{-| An amount of some element
-}
type Amount
    = Amount Float


{-| A number of components
-}
type Quantity
    = Quantity Int


{-| Holds the distribution of material masses per material type
-}
type alias MaterialDistribution a =
    AnyDict String Category.Material a


{-| Material end of life strategy (incinerating, landfilling, recycling)
-}
type alias EndOfLifeStrategies =
    { incinerating : EndOfLifeStrategy
    , landfilling : EndOfLifeStrategy
    , recycling : EndOfLifeStrategy
    }


type alias EndOfLifeStrategy =
    { impacts : Impacts
    , process : Maybe Process
    , split : Split
    }


{-| A data structure exposing detailed impacts at the end of life stage of the lifeCycle
-}
type alias DetailedEndOfLifeImpacts =
    MaterialDistribution
        { collected : ( Mass, EndOfLifeStrategies )
        , nonCollected : ( Mass, EndOfLifeStrategies )
        }


{-| Lifecycle impacts
-}
type alias LifeCycle =
    { endOfLife : Impacts
    , production : Results
    }


{-| A nested data structure carrying the impacts and mass resulting from a computation
-}
type Results
    = Results
        { amount : Amount
        , impacts : Impacts
        , items : List Results
        , label : Maybe String
        , mass : Mass
        , materialType : Maybe Category.Material
        , quantity : Int
        , stage : Maybe Stage
        }


{-| Lifecycle stage. Note: End of life stage is handled separately.
-}
type Stage
    = MaterialStage
    | TransformStage


type alias StagesImpacts =
    { endOfLife : Impacts
    , material : Impacts
    , transformation : Impacts
    }


{-| Add a new element, defined by a required material process, to an item.
-}
addElement : TargetItem -> Process -> List Item -> Result String (List Item)
addElement targetItem material items =
    if not <| List.member Category.Material material.categories then
        Err "L'ajout d'un élément ne peut se faire qu'à partir d'un procédé matière"

    else
        items
            |> updateItemCustom targetItem
                (\custom ->
                    { custom
                        | elements =
                            custom.elements
                                ++ [ { amount = Amount 1, material = material.id, transforms = [] } ]
                    }
                )
            |> Ok


addElementTransform : TargetElement -> Process -> List Item -> Result String (List Item)
addElementTransform targetElement transform items =
    if not <| List.member Category.Transform transform.categories then
        Err "Seuls les procédés de catégorie `transformation` sont mobilisables comme procédés de transformation"

    else
        items
            |> updateElement targetElement
                (\el -> { el | transforms = el.transforms ++ [ transform.id ] })
            |> Ok


addItem : Id -> List Item -> List Item
addItem id items =
    items ++ [ createItem id ]


addOrSetProcess : Category -> TargetItem -> Maybe Index -> Process -> List Item -> Result String (List Item)
addOrSetProcess category targetItem maybeElementIndex process items =
    case ( category, maybeElementIndex ) of
        ( Category.Material, Just elementIndex ) ->
            items |> setElementMaterial ( targetItem, elementIndex ) process

        ( Category.Material, Nothing ) ->
            items |> addElement targetItem process

        ( Category.Transform, Just elementIndex ) ->
            items |> addElementTransform ( targetItem, elementIndex ) process

        ( Category.Transform, Nothing ) ->
            Err "Un procédé de transformation ne peut être ajouté qu'à un élément existant"

        _ ->
            Err <| "Catégorie de procédé non supportée\u{00A0}: " ++ Category.toLabel category


{-| Add two results together
-}
addResults : Results -> Results -> Results
addResults (Results results) (Results acc) =
    Results
        { acc
            | impacts = Impact.sumImpacts [ results.impacts, acc.impacts ]
            , items = Results results :: acc.items
            , mass = Quantity.sum [ results.mass, acc.mass ]
            , stage = Nothing
        }


amountToFloat : Amount -> Float
amountToFloat (Amount float) =
    float


applyTransform : EnergyMixes -> Process -> Results -> Results
applyTransform { elec, heat } transform (Results { amount, label, impacts, items, mass }) =
    let
        transformImpacts =
            [ transform.impacts
            , elec.impacts |> Impact.multiplyBy (Energy.inKilowattHours transform.elec)
            , heat.impacts |> Impact.multiplyBy (Energy.inMegajoules transform.heat)
            ]
                |> Impact.sumImpacts
                -- Note: impacts are always computed from input amount
                |> Impact.multiplyBy (amountToFloat amount)

        outputAmount =
            amount |> applyWaste transform.waste

        outputMass =
            mass
                |> Quantity.minus
                    (mass |> Quantity.multiplyBy (Split.toFloat transform.waste))
    in
    Results
        { amount = outputAmount
        , impacts = Impact.sumImpacts [ transformImpacts, impacts ]
        , items =
            items
                ++ [ -- transform result
                     Results
                        { amount = outputAmount
                        , impacts = transformImpacts
                        , items = []
                        , label = Just <| Process.getDisplayName transform
                        , mass = outputMass
                        , materialType = Nothing
                        , quantity = 1
                        , stage = Just TransformStage
                        }
                   ]
        , label = label
        , mass = outputMass
        , materialType = Nothing
        , quantity = 1
        , stage = Nothing
        }


{-| Sequencially apply transforms to existing Results (typically, material ones).

Note: for now we use average elec and heat mixes, but we might want to allow
specifying specific country mixes in the future.

-}
applyTransforms : List Process -> Process.Unit -> List Process -> Results -> Result String Results
applyTransforms allProcesses unit transforms materialResults =
    checkTransformsUnit unit transforms
        |> Result.andThen (\_ -> loadDefaultEnergyMixes allProcesses)
        |> Result.map
            (\energyMixes ->
                transforms
                    |> List.foldl (applyTransform energyMixes) materialResults
            )


applyWaste : Split -> Amount -> Amount
applyWaste waste =
    mapAmount (\amount -> amount - (amount * Split.toFloat waste))


checkTransformsUnit : Process.Unit -> List Process -> Result String (List Process)
checkTransformsUnit unit transforms =
    if not <| List.all (.unit >> (==) unit) transforms then
        "Les procédés de transformation ne partagent pas la même unité que la matière source ("
            ++ Process.unitToString unit
            ++ ")\u{00A0}: "
            ++ (transforms
                    |> List.filter (.unit >> (/=) unit)
                    |> List.map (\p -> Process.getDisplayName p ++ " (" ++ Process.unitToString p.unit ++ ")")
                    |> String.join ", "
               )
            |> Err

    else
        Ok transforms


{-| Computes impacts from a list of available components, processes and specified component items
-}
compute : DataContainer db -> Scope -> List Item -> Result String LifeCycle
compute db scope =
    List.map (computeItemResults db)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)
        >> Result.map (\(Results results) -> { emptyLifeCycle | production = Results { results | label = Just "Production" } })
        >> Result.andThen (computeEndOfLifeResults db scope)


computeElementResults : List Process -> Element -> Result String Results
computeElementResults processes =
    expandElement processes
        >> Result.andThen
            (\{ amount, material, transforms } ->
                amount
                    |> computeInitialAmount (List.map .waste transforms)
                    |> Result.andThen
                        (\initialAmount ->
                            material
                                |> computeMaterialResults initialAmount
                                |> applyTransforms processes material.unit transforms
                        )
            )


computeEndOfLifeResults : DataContainer db -> Scope -> LifeCycle -> Result String LifeCycle
computeEndOfLifeResults db scope lifeCycle =
    lifeCycle.production
        |> getEndOfLifeImpacts db scope
        |> Result.map (\endOfLife -> { lifeCycle | endOfLife = endOfLife })


{-| Compute an initially required amount from sequentially applied waste ratios
-}
computeInitialAmount : List Split -> Amount -> Result String Amount
computeInitialAmount wastes amount =
    if List.member Split.full wastes then
        Err "Un taux de perte ne peut pas être de 100%"

    else
        wastes
            |> List.foldr
                (\waste (Amount float) ->
                    Amount <| float / (1 - Split.toFloat waste)
                )
                amount
            |> Ok


computeImpacts : List Process -> Component -> Result String Results
computeImpacts processes =
    .elements
        >> List.map (computeElementResults processes)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)


computeItemResults : DataContainer db -> Item -> Result String Results
computeItemResults { components, processes } { custom, id, quantity } =
    let
        component_ =
            findById id components
    in
    component_
        |> Result.andThen
            (\component ->
                custom
                    |> customElements component
                    |> List.map (computeElementResults processes)
                    |> RE.combine
            )
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map
            (\(Results { impacts, mass, materialType, items }) ->
                Results
                    { amount = Amount 0
                    , impacts =
                        impacts
                            |> List.repeat (quantityToInt quantity)
                            |> Impact.sumImpacts
                    , items = items
                    , label =
                        case custom |> Maybe.andThen .name of
                            Just name ->
                                Just name

                            Nothing ->
                                component_
                                    |> Result.map (.name >> Just)
                                    |> Result.withDefault Nothing
                    , mass =
                        mass
                            |> List.repeat (quantityToInt quantity)
                            |> Quantity.sum
                    , materialType = materialType
                    , quantity = quantityToInt quantity
                    , stage = Nothing
                    }
            )


computeMaterialResults : Amount -> Process -> Results
computeMaterialResults amount process =
    let
        impacts =
            process.impacts
                |> Impact.multiplyBy (amountToFloat amount)

        mass =
            Mass.kilograms <|
                if process.unit == Process.Kilogram then
                    amountToFloat amount

                else
                    -- apply density
                    amountToFloat amount * process.density

        materialType =
            Process.getMaterialTypes process
                |> List.head
                |> Maybe.withDefault Category.OtherMaterial
                |> Just
    in
    -- global result
    Results
        { amount = amount
        , impacts = impacts
        , items =
            [ -- material result
              Results
                { amount = amount
                , impacts = impacts
                , items = []
                , label = Just <| Process.getDisplayName process
                , mass = mass
                , materialType = materialType
                , quantity = 1
                , stage = Just MaterialStage
                }
            ]
        , label = Just <| "Element: " ++ Process.getDisplayName process
        , mass = mass
        , materialType = materialType
        , quantity = 1
        , stage = Nothing
        }


computeShareImpacts : Mass -> EndOfLifeStrategy -> Impacts
computeShareImpacts mass { process, split } =
    process
        |> Maybe.map
            (.impacts
                >> Impact.multiplyBy
                    (split
                        |> Split.applyToQuantity mass
                        |> Mass.inKilograms
                    )
            )
        |> Maybe.withDefault Impact.empty


createItem : Id -> Item
createItem id =
    { custom = Nothing, id = id, quantity = quantityFromInt 1 }


customElements : Component -> Maybe Custom -> List Element
customElements { elements } =
    Maybe.map .elements >> Maybe.withDefault elements


decode : Decoder Component
decode =
    Decode.succeed Component
        |> DU.strictOptional "comment" Decode.string
        |> Decode.required "elements" (Decode.list decodeElement)
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "name" Decode.string
        |> Decode.required "scopes"
            -- Note: the backend exposes multiple scopes per component, though it's been decided
            -- a component should only allow one, so here we take the first declared scope.
            (Decode.list Scope.decode
                |> Decode.map (List.head >> Maybe.withDefault Scope.Object)
            )


decodeCustom : Decoder Custom
decodeCustom =
    Decode.succeed Custom
        |> Decode.required "elements" (Decode.list decodeElement)
        |> DU.strictOptional "name" Decode.string
        |> DU.strictOptionalWithDefault "scopes"
            (Decode.list Scope.decode |> Decode.map List.head)
            Nothing


decodeElement : Decoder Element
decodeElement =
    Decode.succeed Element
        |> Decode.required "amount" (Decode.map Amount Decode.float)
        |> Decode.required "material" Process.decodeId
        |> Decode.optional "transforms" (Decode.list Process.decodeId) []


decodeItem : Decoder Item
decodeItem =
    Decode.succeed Item
        |> DU.strictOptional "custom" decodeCustom
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "quantity" decodeQuantity


decodeList : Decoder (List Component)
decodeList =
    Decode.list decode


decodeListFromJsonString : String -> Result String (List Component)
decodeListFromJsonString =
    Decode.decodeString decodeList
        >> Result.mapError Decode.errorToString


decodeQuantity : Decoder Quantity
decodeQuantity =
    Decode.int
        |> Decode.andThen
            (\int ->
                if int < 1 then
                    Decode.fail "La quantité doit être un nombre entier positif"

                else
                    Decode.succeed int
            )
        |> Decode.map Quantity


elementToString : List Process -> Element -> Result String String
elementToString processes element =
    processes
        |> Process.findById element.material
        |> Result.map
            (\process ->
                String.fromFloat (amountToFloat element.amount)
                    ++ Process.unitToString process.unit
                    ++ " "
                    ++ Process.getDisplayName process
            )


elementTransforms : TargetElement -> List Item -> List Process.Id
elementTransforms ( targetItem, elementIndex ) =
    itemElements targetItem
        >> LE.getAt elementIndex
        >> Maybe.map .transforms
        >> Maybe.withDefault []


elementsToString : DataContainer db -> Component -> Result String String
elementsToString db component =
    component.elements
        |> RE.combineMap (elementToString db.processes)
        |> Result.map (String.join " | ")


emptyLifeCycle : LifeCycle
emptyLifeCycle =
    { endOfLife = Impact.empty
    , production = emptyResults
    }


emptyResults : Results
emptyResults =
    Results
        { amount = Amount 0
        , impacts = Impact.empty
        , items = []
        , label = Nothing
        , mass = Quantity.zero
        , materialType = Nothing
        , quantity = 1
        , stage = Nothing
        }


encode : Component -> Encode.Value
encode v =
    Encode.object
        [ ( "comment", v.comment |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "elements", v.elements |> Encode.list encodeElement )
        , ( "id", v.id |> encodeId )
        , ( "name", v.name |> Encode.string )
        , ( "scopes", [ v.scope ] |> Encode.list Scope.encode )
        ]


encodeCustom : Custom -> Encode.Value
encodeCustom custom =
    -- Note: custom scopes are never serialized nor exported as JSON, they are
    --       only used by itemToComponent in the admin
    EU.optionalPropertiesObject
        [ ( "name"
          , custom.name
                |> Maybe.map String.trim
                |> Maybe.andThen
                    (\name ->
                        -- Forbid serializing an empty name
                        if name == "" then
                            Nothing

                        else
                            Just name
                    )
                |> Maybe.map Encode.string
          )
        , ( "elements", custom.elements |> Encode.list encodeElement |> Just )
        ]


encodeElement : Element -> Encode.Value
encodeElement element =
    Encode.object
        [ ( "amount", element.amount |> amountToFloat |> Encode.float )
        , ( "material", Process.encodeId element.material )
        , ( "transforms", element.transforms |> Encode.list Process.encodeId )
        ]


encodeItem : Item -> Encode.Value
encodeItem item =
    EU.optionalPropertiesObject
        [ ( "id", item.id |> idToString |> Encode.string |> Just )
        , ( "quantity", item.quantity |> quantityToInt |> Encode.int |> Just )
        , ( "custom", item.custom |> Maybe.map encodeCustom )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


encodeLifeCycle : Maybe Trigram -> LifeCycle -> Encode.Value
encodeLifeCycle maybeTrigram lifeCycle =
    Encode.object
        [ ( "production", encodeResults maybeTrigram lifeCycle.production )
        , ( "endOfLife"
          , case maybeTrigram of
                Just trigram ->
                    lifeCycle.endOfLife
                        |> Impact.getImpact trigram
                        |> Unit.impactToFloat
                        |> Encode.float

                Nothing ->
                    Impact.encode lifeCycle.endOfLife
          )
        ]


encodeResults : Maybe Trigram -> Results -> Encode.Value
encodeResults maybeTrigram (Results results) =
    EU.optionalPropertiesObject
        [ ( "label", results.label |> Maybe.map Encode.string )
        , ( "stage", results.stage |> Maybe.map (stageToString >> Encode.string) )
        , ( "mass", results.mass |> Mass.inKilograms |> Encode.float |> Just )
        , ( "materialType", results.materialType |> Maybe.map (Category.materialTypeToString >> Encode.string) )
        , ( "quantity", results.quantity |> Encode.int |> Just )
        , ( "impacts"
          , Just <|
                case maybeTrigram of
                    Just trigram ->
                        results.impacts
                            |> Impact.getImpact trigram
                            |> Unit.impactToFloat
                            |> Encode.float

                    Nothing ->
                        Impact.encode results.impacts
          )
        , ( "items", results.items |> Encode.list (encodeResults maybeTrigram) |> Just )
        ]


{-| Turn an Element to an ExpandedElement
-}
expandElement : List Process -> Element -> Result String ExpandedElement
expandElement processes { amount, material, transforms } =
    Ok (ExpandedElement amount)
        |> RE.andMap (Process.findById material processes)
        |> RE.andMap
            (transforms
                |> List.map (\id -> Process.findById id processes)
                |> RE.combine
            )


{-| Take a list of elements and resolve them with fully qualified processes
-}
expandElements : List Process -> List Element -> Result String (List ExpandedElement)
expandElements processes =
    RE.combineMap (expandElement processes)


expandItem : DataContainer a -> Item -> Result String ( Quantity, Component, List ExpandedElement )
expandItem { components, processes } { custom, id, quantity } =
    findById id components
        |> Result.andThen
            (\component ->
                custom
                    |> customElements component
                    |> expandElements processes
                    |> Result.map (\expanded -> ( quantity, component, expanded ))
            )


{-| Take a list of component items and resolve them with actual components and processes
-}
expandItems : DataContainer a -> List Item -> Result String (List ( Quantity, Component, List ExpandedElement ))
expandItems db =
    List.map (expandItem db) >> RE.combine


extractAmount : Results -> Amount
extractAmount (Results { amount }) =
    amount


extractImpacts : Results -> Impacts
extractImpacts (Results { impacts }) =
    impacts


extractItems : Results -> List Results
extractItems (Results { items }) =
    items


extractMass : Results -> Mass
extractMass (Results { mass }) =
    mass


{-| Lookup a Component from a provided Id
-}
findById : Id -> List Component -> Result String Component
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Aucun composant avec id=" ++ idToString id)


getEndOfLifeCollectionShare : Scope -> Split
getEndOfLifeCollectionShare scope =
    (case scope of
        Scope.Object ->
            70

        _ ->
            100
    )
        |> Split.fromPercent
        |> Result.withDefault Split.zero


getEndOfLifeDetailedImpacts : List Process -> Scope -> Results -> Result String DetailedEndOfLifeImpacts
getEndOfLifeDetailedImpacts processes scope =
    let
        collectionRatio =
            getEndOfLifeCollectionShare scope

        nonCollectionRatio =
            Split.complement collectionRatio

        applyStrategies { incinerating, landfilling, recycling } mass =
            ( mass
            , { incinerating = { incinerating | impacts = incinerating |> computeShareImpacts mass }
              , landfilling = { landfilling | impacts = landfilling |> computeShareImpacts mass }
              , recycling = { recycling | impacts = recycling |> computeShareImpacts mass }
              }
            )
    in
    getMaterialDistribution
        >> AnyDict.map
            (\materialCategory mass ->
                Result.map2
                    (\collectionStrategies nonCollectionStrategies ->
                        { collected =
                            collectionRatio
                                |> Split.applyToQuantity mass
                                |> applyStrategies collectionStrategies
                        , nonCollected =
                            nonCollectionRatio
                                |> Split.applyToQuantity mass
                                |> applyStrategies nonCollectionStrategies
                        }
                    )
                    (materialCategory |> getEndOfLifeCollectionStrategies processes)
                    (materialCategory |> getEndOfLifeNonCollectionStrategies processes)
            )
        >> AnyDict.toList
        >> RE.combineMap RE.combineSecond
        >> Result.map (AnyDict.fromList Category.materialTypeToString)


getEndOfLifeImpacts : DataContainer db -> Scope -> Results -> Result String Impacts
getEndOfLifeImpacts db scope (Results results) =
    Results results
        |> getEndOfLifeDetailedImpacts db.processes scope
        |> Result.map
            (AnyDict.map
                (\_ { collected, nonCollected } ->
                    let
                        ( collectedStrategies, nonCollectedStrategies ) =
                            ( Tuple.second collected, Tuple.second nonCollected )
                    in
                    [ collectedStrategies.incinerating
                    , collectedStrategies.landfilling
                    , collectedStrategies.recycling
                    , nonCollectedStrategies.incinerating
                    , nonCollectedStrategies.landfilling
                    , nonCollectedStrategies.recycling
                    ]
                        |> List.map .impacts
                        |> Impact.sumImpacts
                )
                >> AnyDict.values
                >> Impact.sumImpacts
            )


getEndOfLifeCollectionStrategies : List Process -> Category.Material -> Result String EndOfLifeStrategies
getEndOfLifeCollectionStrategies processes material =
    -- TODO: eventually, it would be nice to load this from an external config file or
    --       even better, from the backend
    Result.map5
        (\defaultIncinerating defaultLandfilling plasticIncinerating woodIncinerating upholsteryIncinerating ->
            let
                emptyStrategy =
                    { impacts = Impact.empty, process = Nothing, split = Split.zero }

                split =
                    Split.fromPercent >> Result.withDefault Split.zero

                defaultStrategies =
                    { incinerating = { emptyStrategy | process = Just defaultIncinerating, split = split 82 }
                    , landfilling = { emptyStrategy | process = Just defaultLandfilling, split = split 18 }
                    , recycling = { emptyStrategy | process = Nothing, split = Split.zero }
                    }
            in
            [ ( Category.Metal
              , { incinerating = emptyStrategy
                , landfilling = emptyStrategy
                , recycling = { emptyStrategy | process = Nothing, split = Split.full }
                }
              )
            , ( Category.Plastic
              , { incinerating = { emptyStrategy | process = Just plasticIncinerating, split = split 8 }
                , landfilling = emptyStrategy
                , recycling = { emptyStrategy | process = Nothing, split = split 92 }
                }
              )
            , ( Category.Upholstery
              , { incinerating = { emptyStrategy | process = Just upholsteryIncinerating, split = split 94 }
                , landfilling = { emptyStrategy | process = Just defaultLandfilling, split = split 2 }
                , recycling = { emptyStrategy | process = Nothing, split = split 4 }
                }
              )
            , ( Category.Wood
              , { incinerating = { emptyStrategy | process = Just woodIncinerating, split = split 31 }
                , landfilling = emptyStrategy
                , recycling = { emptyStrategy | process = Nothing, split = split 69 }
                }
              )
            ]
                |> AnyDict.fromList Category.materialTypeToString
                |> AnyDict.get material
                |> Maybe.withDefault defaultStrategies
        )
        -- Default incineration process
        (Process.findByStringId "6fad4e70-5736-552d-a686-97e4fb627c37" processes)
        -- Default landfilling process
        (Process.findByStringId "d4954f69-e647-531d-aa32-c34be5556736" processes)
        -- Plastic incineration process
        (Process.findByStringId "17986210-aeb8-5f4f-99fd-cbecb5439fde" processes)
        -- Wood incineration process
        (Process.findByStringId "316be695-bf3e-5562-9f09-77f213c3ec67" processes)
        -- Upholstery incineration process
        (Process.findByStringId "3fe5a5b1-c1b2-5c17-8b59-0e37b09f1037" processes)


getEndOfLifeNonCollectionStrategies : List Process -> Category.Material -> Result String EndOfLifeStrategies
getEndOfLifeNonCollectionStrategies processes material =
    Result.map3
        (\defaultIncinerating metalIncineration defaultLandfilling ->
            let
                emptyStrategy =
                    { impacts = Impact.empty, process = Nothing, split = Split.zero }

                split =
                    Split.fromPercent >> Result.withDefault Split.zero

                defaultStrategies =
                    { incinerating = { emptyStrategy | process = Just defaultIncinerating, split = split 82 }
                    , landfilling = { emptyStrategy | process = Just defaultLandfilling, split = split 18 }
                    , recycling = { emptyStrategy | process = Nothing, split = Split.zero }
                    }
            in
            [ ( Category.Metal
              , { incinerating = { emptyStrategy | process = Just metalIncineration, split = split 5 }
                , landfilling = { emptyStrategy | process = Just defaultLandfilling, split = split 5 }
                , recycling = { emptyStrategy | process = Nothing, split = split 90 }
                }
              )
            ]
                |> AnyDict.fromList Category.materialTypeToString
                |> AnyDict.get material
                |> Maybe.withDefault defaultStrategies
        )
        -- Default incineration process
        (Process.findByStringId "6fad4e70-5736-552d-a686-97e4fb627c37" processes)
        -- Metal Incineration process
        (Process.findByStringId "5719f399-c2a3-5268-84e2-894aba588f1b" processes)
        -- Default landfilling process
        (Process.findByStringId "d4954f69-e647-531d-aa32-c34be5556736" processes)


{-| Compute mass distribution by material types
-}
getMaterialDistribution : Results -> MaterialDistribution Mass
getMaterialDistribution (Results results) =
    results.items
        -- component level
        -- propagate component quantity to children elements
        |> List.concatMap
            (\(Results { quantity, items }) -> items |> List.map (\item -> ( quantity, item )))
        -- element level
        -- propagate element unit mass to material children
        |> List.concatMap
            (\( quantity, Results { items, mass } ) -> items |> List.map (\item -> ( quantity, mass, item )))
        -- exclude whatever doesn't have a material type and isn't tagged as material
        |> List.filter
            (\( _, _, Results { materialType, stage } ) -> materialType /= Nothing && stage == Just MaterialStage)
        -- sum masses per material types
        |> List.foldl
            (\( quantity, unitMass, Results { materialType } ) acc ->
                let
                    materialCategory =
                        materialType |> Maybe.withDefault Category.OtherMaterial

                    totalMass =
                        unitMass |> Quantity.multiplyBy (toFloat quantity)
                in
                acc
                    |> AnyDict.update materialCategory
                        (Maybe.map (Quantity.plus totalMass)
                            >> Maybe.withDefault totalMass
                            >> Just
                        )
            )
            (AnyDict.empty Category.materialTypeToString)


idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


isCustomized : Component -> Custom -> Bool
isCustomized component custom =
    List.any identity
        [ custom.elements /= component.elements
        , custom.name /= Nothing && custom.name /= Just component.name
        , custom.scope /= Nothing && custom.scope /= Just component.scope
        ]


isEmpty : Component -> Bool
isEmpty component =
    List.isEmpty component.elements


itemElements : TargetItem -> List Item -> List Element
itemElements ( component, itemIndex ) =
    LE.getAt itemIndex
        >> Maybe.andThen .custom
        >> customElements component


itemToComponent : DataContainer db -> Item -> Result String Component
itemToComponent { components } { custom, id } =
    findById id components
        |> Result.map
            (\component ->
                case custom of
                    Just { elements, name, scope } ->
                        { component
                            | elements = elements
                            , name = name |> Maybe.withDefault component.name
                            , scope = scope |> Maybe.withDefault component.scope
                        }

                    Nothing ->
                        component
            )


itemToString : DataContainer db -> Item -> Result String String
itemToString db { custom, id, quantity } =
    db.components
        |> findById id
        |> Result.andThen
            (\component ->
                custom
                    |> customElements component
                    |> RE.combineMap (elementToString db.processes)
                    |> Result.map (String.join " | ")
                    |> Result.map
                        (\processesString ->
                            String.fromInt (quantityToInt quantity)
                                ++ " "
                                ++ (custom
                                        |> Maybe.andThen .name
                                        |> Maybe.withDefault component.name
                                   )
                                ++ " [ "
                                ++ processesString
                                ++ " ]"
                        )
            )


itemsToString : DataContainer db -> List Item -> Result String String
itemsToString db =
    RE.combineMap (itemToString db)
        >> Result.map (String.join ", ")


loadDefaultEnergyMixes : List Process -> Result String EnergyMixes
loadDefaultEnergyMixes processes =
    let
        fromIdString =
            Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
    in
    Result.map2 (\elec heat -> { elec = elec, heat = heat })
        (fromIdString "a2129ece-5dd9-5e66-969c-2603b3c97244")
        (fromIdString "3561ace1-f710-50ce-a69c-9cf842e729e4")


mapAmount : (Float -> Float) -> Amount -> Amount
mapAmount fn (Amount float) =
    Amount <| fn float


quantityFromInt : Int -> Quantity
quantityFromInt int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int


{-| Remove an element from an item
-}
removeElement : TargetElement -> List Item -> List Item
removeElement ( targetItem, elementIndex ) =
    updateItemCustom targetItem
        (\custom ->
            { custom
                | elements =
                    custom.elements |> LE.removeAt elementIndex
            }
        )


removeElementTransform : TargetElement -> Index -> List Item -> List Item
removeElementTransform targetElement transformIndex =
    updateElement targetElement <|
        \el -> { el | transforms = el.transforms |> LE.removeAt transformIndex }


setCustomScope : Component -> Scope -> Item -> Item
setCustomScope component scope item =
    { item
        | custom =
            item.custom
                |> updateCustom component
                    (\custom ->
                        { custom
                            | scope =
                                if scope == component.scope then
                                    Nothing

                                else
                                    Just scope
                        }
                    )
    }


setElementMaterial : TargetElement -> Process -> List Item -> Result String (List Item)
setElementMaterial targetElement material items =
    if not <| List.member Category.Material material.categories then
        Err "Seuls les procédés de catégorie `material` sont mobilisables comme matière"

    else
        items
            |> updateElement targetElement
                (\el ->
                    { el
                        | material = material.id

                        -- Note: always reset the transforms when replacing a material for consistency
                        , transforms = []
                    }
                )
            |> Ok


stagesImpacts : LifeCycle -> StagesImpacts
stagesImpacts lifeCycle =
    lifeCycle.production
        |> extractItems
        -- component level
        |> List.concatMap extractItems
        -- element level
        |> List.concatMap extractItems
        |> List.foldl
            (\(Results { impacts, stage }) acc ->
                case stage of
                    Just MaterialStage ->
                        { acc | material = Impact.sumImpacts [ acc.material, impacts ] }

                    Just TransformStage ->
                        { acc | transformation = Impact.sumImpacts [ acc.transformation, impacts ] }

                    Nothing ->
                        acc
            )
            { endOfLife = lifeCycle.endOfLife
            , material = Impact.empty
            , transformation = Impact.empty
            }


stageToString : Stage -> String
stageToString stage =
    case stage of
        MaterialStage ->
            "material"

        TransformStage ->
            "transformation"


sumLifeCycleImpacts : LifeCycle -> Impacts
sumLifeCycleImpacts lifeCycle =
    Impact.sumImpacts
        [ extractImpacts lifeCycle.production
        , lifeCycle.endOfLife
        ]


updateCustom : Component -> (Custom -> Custom) -> Maybe Custom -> Maybe Custom
updateCustom component fn maybeCustom =
    case maybeCustom of
        Just custom ->
            let
                updated =
                    fn custom
            in
            if isCustomized component updated then
                Just updated

            else
                Nothing

        Nothing ->
            Just
                (fn
                    { elements = component.elements
                    , name = Nothing
                    , scope = Nothing
                    }
                )


updateElement : TargetElement -> (Element -> Element) -> List Item -> List Item
updateElement ( ( component, itemIndex ), elementIndex ) update =
    updateItem itemIndex <|
        \item ->
            { item
                | custom =
                    item.custom
                        |> updateCustom component
                            (\custom ->
                                { custom
                                    | elements =
                                        custom.elements
                                            |> LE.updateAt elementIndex update
                                }
                            )
            }


updateElementAmount : TargetElement -> Amount -> List Item -> List Item
updateElementAmount targetElement amount =
    updateElement targetElement <|
        \el -> { el | amount = amount }


updateItemCustom : TargetItem -> (Custom -> Custom) -> List Item -> List Item
updateItemCustom ( component, itemIndex ) fn =
    updateItem itemIndex <|
        \item ->
            { item
                | custom =
                    item.custom
                        |> updateCustom component fn
            }


updateItemCustomName : TargetItem -> String -> List Item -> List Item
updateItemCustomName targetItem name =
    updateItemCustom targetItem <|
        \custom -> { custom | name = Just name }


updateItem : Index -> (Item -> Item) -> List Item -> List Item
updateItem itemIndex =
    LE.updateAt itemIndex


validateItem : List Component -> Item -> Result String Item
validateItem components item =
    findById item.id components
        |> Result.andThen
            (always <|
                if quantityToInt item.quantity < 1 then
                    Err "La quantité doit être un nombre entier positif"

                else
                    Ok item
            )
