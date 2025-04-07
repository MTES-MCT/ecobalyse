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
    , Quantity
    , Results(..)
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
    , decodeItem
    , decodeListFromJsonString
    , emptyResults
    , encodeId
    , encodeItem
    , encodeResults
    , expandElements
    , expandItems
    , extractImpacts
    , extractItems
    , extractMass
    , findById
    , idFromString
    , idToString
    , itemToComponent
    , itemToString
    , itemsToString
    , quantityFromInt
    , quantityToInt
    , removeElement
    , removeElementTransform
    , setElementMaterial
    , updateElement
    , updateItem
    , updateItemCustomName
    , validateItem
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Trigram)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
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
    { elements : List Element
    , id : Id
    , name : String
    , scopes : List Scope
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


{-| A nested data structure carrying the impacts and mass resulting from a computation
-}
type Results
    = Results
        { impacts : Impacts
        , items : List Results
        , mass : Mass
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
    items ++ [ { custom = Nothing, id = id, quantity = quantityFromInt 1 } ]


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
        }


amountToFloat : Amount -> Float
amountToFloat (Amount float) =
    float


{-| Sequencially apply transforms to existing Results (typically, material ones).

Note: for now we use average elec and heat mixes, but we might want to allow
specifying specific country mixes in the future.

-}
applyTransforms : List Process -> List Process -> Results -> Result String Results
applyTransforms allProcesses transforms materialResults =
    loadDefaultEnergyMixes allProcesses
        |> Result.map
            (\{ elec, heat } ->
                transforms
                    |> List.foldl
                        (\transform (Results { impacts, items, mass }) ->
                            let
                                wastedMass =
                                    mass |> Quantity.multiplyBy (Split.toFloat transform.waste)

                                outputMass =
                                    mass |> Quantity.minus wastedMass

                                -- Note: impacts are always computed from input mass
                                transformImpacts =
                                    [ transform.impacts
                                    , elec.impacts
                                        |> Impact.multiplyBy (Energy.inKilowattHours transform.elec)
                                    , heat.impacts
                                        |> Impact.multiplyBy (Energy.inMegajoules transform.heat)
                                    ]
                                        |> Impact.sumImpacts
                                        |> Impact.multiplyBy (Mass.inKilograms mass)
                            in
                            Results
                                -- global result
                                { impacts = Impact.sumImpacts [ transformImpacts, impacts ]
                                , items =
                                    items
                                        ++ [ -- transform result
                                             Results
                                                { impacts = transformImpacts
                                                , items = []
                                                , mass = outputMass
                                                }
                                           ]
                                , mass = outputMass
                                }
                        )
                        materialResults
            )


{-| Computes impacts from a list of available components, processes and specified component items
-}
compute : DataContainer db -> List Item -> Result String Results
compute db =
    List.map (computeItemResults db)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)


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
                                |> applyTransforms processes transforms
                        )
            )


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
    components
        |> findById id
        |> Result.andThen
            (\component ->
                custom
                    |> Maybe.map .elements
                    |> Maybe.withDefault component.elements
                    |> List.map (computeElementResults processes)
                    |> RE.combine
            )
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map
            (\(Results { impacts, mass, items }) ->
                Results
                    { impacts =
                        impacts
                            |> List.repeat (quantityToInt quantity)
                            |> Impact.sumImpacts
                    , items = items
                    , mass =
                        mass
                            |> List.repeat (quantityToInt quantity)
                            |> Quantity.sum
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
                if process.unit == "kg" then
                    amountToFloat amount

                else
                    -- apply density
                    amountToFloat amount * process.density
    in
    -- global result
    Results
        { impacts = impacts
        , items =
            [ -- material result
              Results { impacts = impacts, items = [], mass = mass }
            ]
        , mass = mass
        }


decode : List Scope -> Decoder Component
decode scopes =
    Decode.succeed Component
        |> Decode.required "elements" (Decode.list decodeElement)
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "name" Decode.string
        |> Decode.optional "scopes" (Decode.list Scope.decode) scopes


decodeCustom : Decoder Custom
decodeCustom =
    Decode.succeed Custom
        |> Decode.required "elements" (Decode.list decodeElement)
        |> DU.strictOptional "name" Decode.string


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


decodeList : List Scope -> Decoder (List Component)
decodeList scopes =
    Decode.list (decode scopes)


decodeListFromJsonString : List Scope -> String -> Result String (List Component)
decodeListFromJsonString scopes =
    Decode.decodeString (decodeList scopes)
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
                    ++ process.unit
                    ++ " "
                    ++ Process.getDisplayName process
            )


encodeCustom : Custom -> Encode.Value
encodeCustom custom =
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
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeElement : Element -> Encode.Value
encodeElement element =
    Encode.object
        [ ( "amount", element.amount |> amountToFloat |> Encode.float )
        , ( "material", Process.encodeId element.material )
        , ( "transforms", element.transforms |> Encode.list Process.encodeId )
        ]


encodeItem : Item -> Encode.Value
encodeItem item =
    [ ( "id", item.id |> idToString |> Encode.string |> Just )
    , ( "quantity", item.quantity |> quantityToInt |> Encode.int |> Just )
    , ( "custom", item.custom |> Maybe.map encodeCustom )
    ]
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


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
                    |> Maybe.map .elements
                    |> Maybe.withDefault component.elements
                    |> expandElements processes
                    |> Result.map (\expanded -> ( quantity, component, expanded ))
            )


{-| Take a list of component items and resolve them with actual components and processes
-}
expandItems : DataContainer a -> List Item -> Result String (List ( Quantity, Component, List ExpandedElement ))
expandItems db =
    List.map (expandItem db) >> RE.combine


encodeResults : Maybe Trigram -> Results -> Encode.Value
encodeResults maybeTrigram (Results results) =
    Encode.object
        [ ( "impacts"
          , case maybeTrigram of
                Just trigram ->
                    results.impacts
                        |> Impact.getImpact trigram
                        |> Unit.impactToFloat
                        |> Encode.float

                Nothing ->
                    Impact.encode results.impacts
          )
        , ( "items", Encode.list (encodeResults maybeTrigram) results.items )
        , ( "mass", results.mass |> Mass.inKilograms |> Encode.float )
        ]


{-| Lookup a Component from a provided Id
-}
findById : Id -> List Component -> Result String Component
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Aucun composant avec id=" ++ idToString id)


idFromString : String -> Result String Id
idFromString str =
    str
        |> Uuid.fromString
        |> Result.fromMaybe ("Identifiant invalide: " ++ str)
        |> Result.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


isCustomized : Component -> Custom -> Bool
isCustomized component custom =
    List.any identity
        [ custom.elements /= component.elements
        , custom.name /= Nothing && custom.name /= Just component.name
        ]


itemToComponent : DataContainer db -> Item -> Result String Component
itemToComponent { components } { custom, id } =
    findById id components
        |> Result.map
            (\component ->
                case custom of
                    Just { elements, name } ->
                        { component
                            | elements = elements
                            , name = name |> Maybe.withDefault component.name
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
                    |> Maybe.map .elements
                    |> Maybe.withDefault component.elements
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


loadDefaultEnergyMixes : List Process -> Result String { elec : Process, heat : Process }
loadDefaultEnergyMixes processes =
    let
        fromIdString =
            Process.idFromString
                >> Result.andThen (\id -> Process.findById id processes)
    in
    Result.map2 (\elec heat -> { elec = elec, heat = heat })
        (fromIdString "9c70a439-ee05-4fc4-9598-7448345f7081")
        (fromIdString "e70b2dc1-41be-4db6-8267-4e9f4822e8bc")


quantityFromInt : Int -> Quantity
quantityFromInt int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int


emptyResults : Results
emptyResults =
    Results
        { impacts = Impact.empty
        , items = []
        , mass = Quantity.zero
        }


extractImpacts : Results -> Impacts
extractImpacts (Results { impacts }) =
    impacts


extractItems : Results -> List Results
extractItems (Results { items }) =
    items


extractMass : Results -> Mass
extractMass (Results { mass }) =
    mass


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


setElementMaterial : TargetElement -> Process -> List Item -> Result String (List Item)
setElementMaterial targetElement material items =
    if not <| List.member Category.Material material.categories then
        Err "Seuls les procédés de catégorie `material` sont mobilisables comme matière"

    else
        items
            |> updateElement targetElement (\el -> { el | material = material.id })
            |> Ok


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
            Just (fn { elements = component.elements, name = Nothing })


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
