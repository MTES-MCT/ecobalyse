module Data.Component exposing
    ( Amount(..)
    , Component
    , DataContainer
    , Element
    , ExpandedElement
    , Id
    , Item
    , Quantity
    , Results(..)
    , amountToFloat
    , applyTransforms
    , available
    , compute
    , computeElementResults
    , computeImpacts
    , decodeItem
    , decodeListFromJsonString
    , emptyResults
    , encodeId
    , encodeItem
    , expandElements
    , expandItems
    , extractImpacts
    , extractItems
    , extractMass
    , findById
    , idFromString
    , idToString
    , itemToString
    , quantityFromInt
    , quantityToInt
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Split as Split
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
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
    }


{-| A compact representation of a component and a quantity of it, typically used for queries
-}
type alias Item =
    { id : Id
    , quantity : Quantity
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


{-| List components which ids are not part of the provided list of ids
-}
available : List Id -> List Component -> List Component
available alreadyUsedIds =
    List.filter (\{ id } -> not <| List.member id alreadyUsedIds)
        >> List.sortBy .name


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
                material
                    |> computeMaterialResults amount
                    |> applyTransforms processes transforms
            )


computeMaterialResults : Amount -> Process -> Results
computeMaterialResults amount process =
    let
        ( impacts, mass ) =
            ( process.impacts
                |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (amountToFloat amount))
            , Mass.kilograms <|
                if process.unit == "kg" then
                    amountToFloat amount

                else
                    -- apply density
                    amountToFloat amount * process.density
            )
    in
    Results
        { impacts = impacts
        , items = [ Results { impacts = impacts, items = [], mass = mass } ]
        , mass = mass
        }


{-| Sequencially apply transforms to existing Results (typically, material ones).

Note: for now we use average elec and heat mixes, but we might want to allow
specifying specific country mixes in the future.

-}
applyTransforms : List Process -> List Process -> Results -> Result String Results
applyTransforms allProcesses transforms (Results materialResults) =
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
                                    Impact.sumImpacts
                                        [ transform.impacts |> Impact.multiplyBy (Mass.inKilograms mass)
                                        , elec.impacts |> Impact.multiplyBy (Mass.inKilograms mass)
                                        , heat.impacts |> Impact.multiplyBy (Mass.inKilograms mass)
                                        ]
                            in
                            Results
                                { impacts = Impact.sumImpacts [ transformImpacts, impacts ]
                                , items = Results { impacts = transformImpacts, items = [], mass = Quantity.negate wastedMass } :: items
                                , mass = outputMass
                                }
                        )
                        (Results materialResults)
            )


computeImpacts : List Process -> Component -> Result String Results
computeImpacts processes =
    .elements
        >> List.map (computeElementResults processes)
        >> RE.combine
        >> Result.map (List.foldl addResults emptyResults)


computeItemResults : DataContainer db -> Item -> Result String Results
computeItemResults { components, processes } { id, quantity } =
    components
        |> findById id
        |> Result.andThen (.elements >> List.map (computeElementResults processes) >> RE.combine)
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


decode : Decoder Component
decode =
    Decode.succeed Component
        |> Decode.required "elements" (Decode.list decodeElement)
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "name" Decode.string


decodeList : Decoder (List Component)
decodeList =
    Decode.list decode


decodeElement : Decoder Element
decodeElement =
    Decode.succeed Element
        |> Decode.required "amount" (Decode.map Amount Decode.float)
        |> Decode.required "material" Process.decodeId
        |> Decode.required "transforms" (Decode.list Process.decodeId)


decodeItem : Decoder Item
decodeItem =
    Decode.succeed Item
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "quantity" (Decode.map Quantity Decode.int)


decodeListFromJsonString : String -> Result String (List Component)
decodeListFromJsonString =
    Decode.decodeString decodeList
        >> Result.mapError Decode.errorToString


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


{-| Take a list of component items and resolve them with actual components and processes
-}
expandItems : DataContainer a -> List Item -> Result String (List ( Quantity, Component, List ExpandedElement ))
expandItems { components, processes } =
    List.map
        (\{ id, quantity } ->
            findById id components
                |> Result.andThen
                    (\component ->
                        component.elements
                            |> expandElements processes
                            |> Result.map (\expandedElements -> ( quantity, component, expandedElements ))
                    )
        )
        >> RE.combine


{-| Take a list of elements and resolve them with fully qualified processes
-}
expandElements : List Process -> List Element -> Result String (List ExpandedElement)
expandElements processes =
    RE.combineMap (expandElement processes)


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


encodeItem : Item -> Encode.Value
encodeItem item =
    Encode.object
        [ ( "id", item.id |> idToString |> Encode.string )
        , ( "quantity", item.quantity |> quantityToInt |> Encode.int )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


{-| Lookup a Component from a provided Id
-}
findById : Id -> List Component -> Result String Component
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Aucun composant avec id=" ++ idToString id)


idFromString : String -> Maybe Id
idFromString str =
    Uuid.fromString str |> Maybe.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


itemToString : DataContainer db -> Item -> Result String String
itemToString db { id, quantity } =
    db.components
        |> findById id
        |> Result.andThen
            (\component ->
                component.elements
                    |> RE.combineMap (elementToString db.processes)
                    |> Result.map (String.join " | ")
                    |> Result.map
                        (\processesString ->
                            String.fromInt (quantityToInt quantity)
                                ++ " "
                                ++ component.name
                                ++ " [ "
                                ++ processesString
                                ++ " ]"
                        )
            )


loadDefaultEnergyMixes : List Process -> Result String { elec : Process, heat : Process }
loadDefaultEnergyMixes processes =
    Result.map2 (\elec heat -> { elec = elec, heat = heat })
        (Process.findByAlias "elec-medium-region-asia" processes)
        (Process.findByAlias "heat-row" processes)


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
