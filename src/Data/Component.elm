module Data.Component exposing
    ( Amount
    , Component
    , ComponentItem
    , Id
    , ProcessItem
    , Quantity
    , Results
    , amountToFloat
    , available
    , componentItemToString
    , compute
    , decodeComponentItem
    , decodeList
    , emptyResults
    , encodeComponentItem
    , expandComponentItems
    , expandProcessItems
    , extractImpacts
    , extractItems
    , extractMass
    , findById
    , idFromString
    , idToString
    , quantityFromInt
    , quantityToInt
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE


type Id
    = Id Uuid


{-| A component is a named collection of processes and amounts of them
-}
type alias Component =
    { id : Id
    , name : String
    , processes : List ProcessItem
    }


{-| A compact representation of a component and a quantity of it
-}
type alias ComponentItem =
    { id : Id
    , quantity : Quantity
    }


{-| A compact representation of a component process, and an amount of it
-}
type alias ProcessItem =
    { amount : Amount
    , processId : Process.Id
    }


type Amount
    = Amount Float


type Quantity
    = Quantity Int


type Results
    = Results
        { impacts : Impacts
        , items : List Results
        , mass : Mass
        }


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


available : List Id -> List Component -> List Component
available ids =
    List.filter (\{ id } -> not <| List.member id ids)
        >> List.sortBy .name


componentItemToString : List Component -> List Process -> ComponentItem -> Result String String
componentItemToString components processes { id, quantity } =
    components
        |> findById id
        |> Result.andThen
            (\component ->
                component.processes
                    |> RE.combineMap (processItemToString processes)
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


compute : List Component -> List Process -> List ComponentItem -> Result String Results
compute components processes =
    List.map (computeComponentItemResults components processes)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)


computeComponentItemResults : List Component -> List Process -> ComponentItem -> Result String Results
computeComponentItemResults components processes { id, quantity } =
    components
        |> findById id
        |> Result.andThen (.processes >> List.map (computeProcessItemResults processes) >> RE.combine)
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


computeProcessItemResults : List Process -> ProcessItem -> Result String Results
computeProcessItemResults processes { amount, processId } =
    processes
        |> Process.findById processId
        |> Result.map
            (\process ->
                let
                    impacts =
                        process.impacts
                            |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (amountToFloat amount))

                    mass =
                        Mass.kilograms <|
                            if process.unit == "kg" then
                                amountToFloat amount

                            else
                                -- apply density
                                amountToFloat amount * process.density
                in
                Results
                    { impacts = impacts
                    , items = [ Results { impacts = impacts, items = [], mass = mass } ]
                    , mass = mass
                    }
            )


expandComponentItems :
    { a | components : List Component, processes : List Process }
    -> List ComponentItem
    -> Result String (List ( Quantity, Component, List ( Amount, Process ) ))
expandComponentItems { components, processes } =
    List.map
        (\{ id, quantity } ->
            findById id components
                |> Result.andThen
                    (\component ->
                        component.processes
                            |> expandProcessItems processes
                            |> Result.map (\expandedItems -> ( quantity, component, expandedItems ))
                    )
        )
        >> RE.combine


expandProcessItems : List Process -> List ProcessItem -> Result String (List ( Amount, Process ))
expandProcessItems processes =
    List.map (\{ amount, processId } -> ( amount, processId ))
        >> List.map (RE.combineMapSecond (\id -> Process.findById id processes))
        >> RE.combine


decode : Decoder Component
decode =
    Decode.succeed Component
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "name" Decode.string
        |> Decode.required "processes" (Decode.list decodeProcessItem)


decodeList : Decoder (List Component)
decodeList =
    Decode.list decode


decodeComponentItem : Decoder ComponentItem
decodeComponentItem =
    Decode.succeed ComponentItem
        |> Decode.required "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "quantity" (Decode.map Quantity Decode.int)


decodeProcessItem : Decoder ProcessItem
decodeProcessItem =
    Decode.succeed ProcessItem
        |> Decode.required "amount" (Decode.map Amount Decode.float)
        |> Decode.required "process_id" Process.decodeId


encodeComponentItem : ComponentItem -> Encode.Value
encodeComponentItem componentItem =
    Encode.object
        [ ( "id", componentItem.id |> idToString |> Encode.string )
        , ( "quantity", componentItem.quantity |> quantityToInt |> Encode.int )
        ]


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


processItemToString : List Process -> ProcessItem -> Result String String
processItemToString processes processItem =
    processes
        |> Process.findById processItem.processId
        |> Result.map
            (\process ->
                String.fromFloat (amountToFloat processItem.amount)
                    ++ process.unit
                    ++ " "
                    ++ Process.getDisplayName process
            )


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
