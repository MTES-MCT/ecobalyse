module Data.Component exposing
    ( Amount(..)
    , Component
    , Config
    , Custom
    , DataContainer
    , Element
    , EndOfLifeMaterialImpacts
    , ExpandedElement
    , ExpandedItem
    , Id
    , Index
    , Item
    , LifeCycle
    , Quantity
    , Query
    , Requirements
    , Results(..)
    , Stage
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
    , computeItemTransportToAssembly
    , createItem
    , decode
    , decodeItem
    , decodeList
    , decodeListFromJsonString
    , decodeQuery
    , defaultConfig
    , elementTransforms
    , elementsToString
    , emptyLifeCycle
    , emptyQuery
    , emptyResults
    , encode
    , encodeBase64Query
    , encodeId
    , encodeItem
    , encodeLifeCycle
    , encodeQuery
    , expandElements
    , expandItems
    , extractAmount
    , extractImpacts
    , extractItems
    , extractMass
    , findById
    , getEndOfLifeDetailedImpacts
    , getEndOfLifeImpacts
    , getEndOfLifeScopeCollectionRate
    , getTotalTransportImpacts
    , idFromString
    , idToString
    , isEmpty
    , itemToComponent
    , itemToString
    , itemsToString
    , loadEnergyMixes
    , mapItems
    , parseBase64Query
    , parseConfig
    , quantityFromInt
    , quantityToInt
    , removeElement
    , removeElementTransform
    , setCustomScope
    , setElementMaterial
    , setQueryItems
    , stagesImpacts
    , sumLifeCycleImpacts
    , toSearchableString
    , tryMapItems
    , updateDurability
    , updateElement
    , updateElementAmount
    , updateItem
    , updateItemCustomName
    , validateItem
    )

import Base64
import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Component.Config as Config exposing (EndOfLifeStrategies, EndOfLifeStrategy)
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Trigram)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category, MaterialDict)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Dict.Any as AnyDict
import Energy
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type Id
    = Id Uuid


{-| A Component is a named collection of elements
-}
type alias Component =
    { comment : Maybe String
    , elements : List Element
    , id : Id
    , name : String
    , published : Bool
    , scope : Scope
    }


{-| Proxified for convenience
-}
type alias Config =
    Config.Config


type alias EnergyMixes =
    { elec : Process
    , heat : Process
    }


type alias Query =
    { assemblyCountry : Maybe Country.Code

    -- Note: component durability is experimental, future work may eventually be needed to
    -- reuse existing mechanics and handle holistic durability like it's implemented for textile,
    -- though it's still an ongoing discussion and we need to move forward and iterate.
    , durability : Unit.Ratio
    , items : List Item
    }


{-| A compact reference to a component, a quantity of it, a production localization
and optional overrides, typically used for queries
-}
type alias Item =
    { country : Maybe Country.Code
    , custom : Maybe Custom
    , id : Id
    , quantity : Quantity
    }


type alias ExpandedItem =
    { component : Component
    , country : Maybe Country
    , elements : List ExpandedElement
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
        , countries : List Country
        , distances : Transport.Distances
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

Note: the `country` field is propagated from the parent component item, for convenience

-}
type alias ExpandedElement =
    { amount : Amount
    , country : Maybe Country
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


{-| A data structure exposing detailed impacts at the end of life stage of the lifeCycle
-}
type alias DetailedEndOfLifeImpacts =
    MaterialDict EndOfLifeMaterialImpacts


type alias EndOfLifeMaterialImpacts =
    { collected : ( Mass, EndOfLifeStrategies )
    , nonCollected : ( Mass, EndOfLifeStrategies )
    }


{-| Lifecycle impacts
-}
type alias LifeCycle =
    { endOfLife : Impacts
    , production : Results
    , transports : LifeCycleTransport
    }


type alias LifeCycleTransport =
    -- TODO: rename to TransportsDetails?
    { toAssembly : Transport
    , toDistribution : Transport
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
    , transports : Impacts
    }


type alias Requirements db =
    { config : Config
    , db : DataContainer db
    , scope : Scope
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
applyTransforms : Config -> Maybe Country -> Process.Unit -> List Process -> Results -> Result String Results
applyTransforms config maybeCountry unit transforms materialResults =
    checkTransformsUnit unit transforms
        |> Result.andThen (\_ -> loadEnergyMixes config maybeCountry)
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
compute : Requirements db -> Query -> Result String LifeCycle
compute requirements query =
    query.items
        |> List.map (computeItemResults requirements)
        |> RE.combine
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map (\(Results results) -> { emptyLifeCycle | production = Results { results | label = Just "Production" } })
        |> Result.map (computeEndOfLifeResults requirements)
        |> Result.andThen (computeTransports requirements query)


computeElementResults : Requirements db -> Maybe Country.Code -> Element -> Result String Results
computeElementResults requirements maybeCountry =
    expandElement requirements.db maybeCountry
        >> Result.andThen
            (\{ amount, country, material, transforms } ->
                amount
                    |> computeInitialAmount (List.map .waste transforms)
                    |> Result.andThen
                        (\initialAmount ->
                            material
                                |> computeMaterialResults initialAmount
                                |> applyTransforms requirements.config country material.unit transforms
                        )
            )


computeEndOfLifeResults : Requirements db -> LifeCycle -> LifeCycle
computeEndOfLifeResults requirements lifeCycle =
    { lifeCycle
        | endOfLife =
            lifeCycle.production
                |> getEndOfLifeImpacts requirements
    }


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


{-| Compute a single component impact
-}
computeImpacts : Requirements db -> Component -> Result String Results
computeImpacts requirements =
    .elements
        >> List.map (computeElementResults requirements Nothing)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)


computeItemResults : Requirements db -> Item -> Result String Results
computeItemResults requirements { country, custom, id, quantity } =
    let
        component_ =
            findById id requirements.db.components
    in
    component_
        |> Result.andThen
            (\component ->
                custom
                    |> customElements component
                    |> List.map (computeElementResults requirements country)
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


computeItemTransportToAssembly : Requirements db -> Maybe Country -> ExpandedItem -> Results -> ( String, Transport )
computeItemTransportToAssembly { config, db } assemblyCountry item itemResults =
    let
        ( label, itemTransport ) =
            case ( item.country, assemblyCountry ) of
                ( Just from, Just to ) ->
                    ( from.name ++ " → " ++ to.name
                    , db.distances
                        |> Transport.getTransportBetween Impact.empty from.code to.code
                    )

                _ ->
                    ( "Trajet inconnu majoré", config.transports.defaultDistance )
    in
    ( label
    , itemTransport
        |> Transport.applyTransportRatios Split.zero
        |> Transport.computeImpacts config.transports.modeProcesses (extractMass itemResults)
    )


computeMaterialResults : Amount -> Process -> Results
computeMaterialResults amount process =
    let
        impacts =
            -- Note: materials impacts embed energy ones
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


computeTransports : Requirements db -> Query -> LifeCycle -> Result String LifeCycle
computeTransports ({ config, db } as req) query lifeCycle =
    Result.map2
        (\expandedItems maybeAssemblyCountry ->
            { lifeCycle
                | transports =
                    -- Note: for now it's assumed there's never air transport
                    { toAssembly =
                        -- Only convey multiple items to assembly step
                        -- TODO: refactor query to handle this through types https://github.com/MTES-MCT/ecobalyse/issues/1609
                        if List.length query.items > 1 then
                            expandedItems
                                |> List.indexedMap
                                    (\index item ->
                                        lifeCycle.production
                                            |> extractItems
                                            |> LE.getAt index
                                            |> Maybe.map (computeItemTransportToAssembly req maybeAssemblyCountry item >> Tuple.second)
                                    )
                                |> List.filterMap identity
                                |> Transport.sum

                        else
                            Transport.default Impact.empty
                    , toDistribution =
                        expandedItems
                            |> computeDistributionTransports req maybeAssemblyCountry
                            |> Transport.applyTransportRatios Split.zero
                            |> Transport.computeImpacts config.transports.modeProcesses (extractMass lifeCycle.production)
                    }
            }
        )
        (expandItems db query.items)
        (Country.resolveMaybe query.assemblyCountry db.countries)


{-| Computes transports of components from the number of shipped items, and either their respective country
of production or country of assembly to France (the only possible distribution destination).
-}
computeDistributionTransports : Requirements db -> Maybe Country -> List ExpandedItem -> Transport
computeDistributionTransports { config, db } maybeAssemblyCountry items =
    case ( items, maybeAssemblyCountry ) of
        -- No items at all
        ( [], _ ) ->
            Transport.default Impact.empty

        -- Single item, no possible assembly country
        ( [ { country } ], _ ) ->
            country
                |> Maybe.map
                    (\{ code } ->
                        db.distances
                            |> Transport.getTransportBetween Impact.empty code config.distribution.country.code
                    )
                |> Maybe.withDefault config.transports.defaultDistance

        -- Many items, assembly country specified
        ( _, Just { code } ) ->
            db.distances
                |> Transport.getTransportBetween Impact.empty code config.distribution.country.code

        -- Many items, no assembly country specified
        ( _, Nothing ) ->
            config.transports.defaultDistance


createItem : Id -> Item
createItem id =
    { country = Nothing
    , custom = Nothing
    , id = id
    , quantity = quantityFromInt 1
    }


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
        -- If there is no published field provided, we’re reading the values from
        -- static files and by default, all components in the static files should
        -- be considered as published
        |> Decode.optional "published" Decode.bool True
        |> Decode.required "scopes"
            -- Note: the backend exposes multiple scopes per component, though it's been decided
            -- a component should only allow one, so here we take the first declared scope.
            (Decode.list Scope.decode
                |> Decode.map (List.head >> Maybe.withDefault Scope.Object)
            )


decodeBase64Query : String -> Result String Query
decodeBase64Query =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decodeQuery
                >> Result.mapError Decode.errorToString
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
        |> DU.strictOptional "country" Country.decodeCode
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


decodeQuery : Decoder Query
decodeQuery =
    Decode.succeed Query
        |> DU.strictOptional "assemblyCountry" Country.decodeCode
        |> Decode.optional "durability" Unit.decodeRatio (Unit.ratio 1)
        |> Decode.required "components" (Decode.list decodeItem)


{-| Proxified for convenience
-}
defaultConfig : List Process -> List Country -> Result String Config
defaultConfig =
    Config.default


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
    , transports = emptyLifeCycleTransports
    }


emptyLifeCycleTransports : LifeCycleTransport
emptyLifeCycleTransports =
    { toAssembly = Transport.default Impact.empty
    , toDistribution = Transport.default Impact.empty
    }


emptyQuery : Query
emptyQuery =
    { assemblyCountry = Nothing
    , durability = Unit.ratio 1
    , items = []
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
        , ( "published", v.published |> Encode.bool )
        , ( "scopes", [ v.scope ] |> Encode.list Scope.encode )
        ]


encodeBase64Query : Query -> String
encodeBase64Query =
    encodeQuery >> Encode.encode 0 >> Base64.encode


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


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


encodeItem : Item -> Encode.Value
encodeItem item =
    EU.optionalPropertiesObject
        [ ( "id", item.id |> idToString |> Encode.string |> Just )
        , ( "quantity", item.quantity |> quantityToInt |> Encode.int |> Just )
        , ( "country", item.country |> Maybe.map Country.encodeCode )
        , ( "custom", item.custom |> Maybe.map encodeCustom )
        ]


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


encodeQuery : Query -> Encode.Value
encodeQuery query =
    EU.optionalPropertiesObject
        [ ( "assemblyCountry", query.assemblyCountry |> Maybe.map Country.encodeCode )
        , ( "durability", query.durability |> Unit.encodeRatio |> Just )
        , ( "components", query.items |> Encode.list encodeItem |> Just )
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
expandElement : DataContainer db -> Maybe Country.Code -> Element -> Result String ExpandedElement
expandElement { countries, processes } maybeCountry { amount, material, transforms } =
    Ok (ExpandedElement amount)
        |> RE.andMap (Country.resolveMaybe maybeCountry countries)
        |> RE.andMap (Process.findById material processes)
        |> RE.andMap
            (transforms
                |> List.map (\id -> Process.findById id processes)
                |> RE.combine
            )


{-| Take a list of elements and resolve them with fully qualified processes
-}
expandElements : DataContainer db -> Maybe Country.Code -> List Element -> Result String (List ExpandedElement)
expandElements db maybeCountry =
    RE.combineMap (expandElement db maybeCountry)


expandItem : DataContainer a -> Item -> Result String ExpandedItem
expandItem ({ components, countries } as db) { country, custom, id, quantity } =
    findById id components
        |> Result.andThen
            (\component ->
                countries
                    |> Country.resolveMaybe country
                    |> Result.andThen
                        (\maybeCountry ->
                            custom
                                |> customElements component
                                |> expandElements db country
                                |> Result.map
                                    (\expandedElements ->
                                        { component =
                                            case custom |> Maybe.andThen .name of
                                                Just customName ->
                                                    { component | name = customName }

                                                Nothing ->
                                                    component
                                        , country = maybeCountry
                                        , elements = expandedElements
                                        , quantity = quantity
                                        }
                                    )
                        )
            )


{-| Take a list of component items and resolve them with actual components and processes
-}
expandItems : DataContainer a -> List Item -> Result String (List ExpandedItem)
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


getEndOfLifeDetailedImpacts : Requirements db -> Results -> DetailedEndOfLifeImpacts
getEndOfLifeDetailedImpacts { config, scope } =
    let
        collectionRatio =
            getEndOfLifeScopeCollectionRate config scope

        nonCollectionRatio =
            Split.complement collectionRatio

        applyStrategies : Mass -> EndOfLifeStrategies -> ( Mass, EndOfLifeStrategies )
        applyStrategies mass { incinerating, landfilling, recycling } =
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
                { collected =
                    config.endOfLife.strategies.collected
                        |> AnyDict.get materialCategory
                        |> Maybe.withDefault config.endOfLife.strategies.default
                        |> applyStrategies (collectionRatio |> Split.applyToQuantity mass)
                , nonCollected =
                    config.endOfLife.strategies.nonCollected
                        |> AnyDict.get materialCategory
                        |> Maybe.withDefault config.endOfLife.strategies.default
                        |> applyStrategies (nonCollectionRatio |> Split.applyToQuantity mass)
                }
            )
        >> AnyDict.toList
        >> AnyDict.fromList Category.materialTypeToString


getEndOfLifeImpacts : Requirements db -> Results -> Impacts
getEndOfLifeImpacts requirements (Results results) =
    Results results
        |> getEndOfLifeDetailedImpacts requirements
        |> AnyDict.map
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
        |> AnyDict.values
        |> Impact.sumImpacts


getEndOfLifeScopeCollectionRate : Config -> Scope -> Split
getEndOfLifeScopeCollectionRate { endOfLife } scope =
    endOfLife.scopeCollectionRates
        |> AnyDict.get scope
        -- Assume every material is fully collected by default
        |> Maybe.withDefault Split.full


{-| Compute mass distribution by material types
-}
getMaterialDistribution : Results -> MaterialDict Mass
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


getTotalTransportImpacts : LifeCycleTransport -> Impacts
getTotalTransportImpacts transports =
    Impact.sumImpacts
        [ transports.toAssembly.impacts
        , transports.toDistribution.impacts
        ]


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
    -- FIXME: handle query
    RE.combineMap (itemToString db)
        >> Result.map (String.join ", ")


loadEnergyMixes : Config -> Maybe Country -> Result String EnergyMixes
loadEnergyMixes config =
    Maybe.map
        (\{ electricityProcess, heatProcess } -> Ok <| EnergyMixes electricityProcess heatProcess)
        >> Maybe.withDefault
            (Ok
                { elec = config.production.defaultElecProcess
                , heat = config.production.defaultHeatProcess
                }
            )


mapAmount : (Float -> Float) -> Amount -> Amount
mapAmount fn (Amount float) =
    Amount <| fn float


mapItems : (List Item -> List Item) -> Query -> Query
mapItems fn query =
    setQueryItems (fn query.items) query


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        decodeBase64Query
            >> Result.toMaybe
            >> Just


{-| Proxified for convenience
-}
parseConfig : List Process -> List Country -> String -> Result String Config
parseConfig =
    Config.parse


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


{-| Sets query items, adapting the country of assembly if needed
-}
setQueryItems : List Item -> Query -> Query
setQueryItems items query =
    { query
        | assemblyCountry =
            if List.length items > 1 then
                query.assemblyCountry

            else
                -- reset assembly country if no or single item
                Nothing
        , items = items
    }


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
            , transports = getTotalTransportImpacts lifeCycle.transports
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
        , lifeCycle.transports.toAssembly.impacts
        , lifeCycle.transports.toDistribution.impacts
        ]


toSearchableString : DataContainer db -> Component -> String
toSearchableString db component =
    String.join " "
        [ component.id |> idToString
        , component.name
        , component.comment |> Maybe.withDefault ""
        , component |> elementsToString db |> Result.withDefault ""
        ]


{-| Update a list of component items that may fail
-}
tryMapItems : (List Item -> Result String (List Item)) -> Query -> Result String Query
tryMapItems fn query =
    fn query.items
        |> Result.map (\items -> setQueryItems items query)


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


updateDurability : Unit.Ratio -> Query -> Query
updateDurability durability query =
    { query | durability = durability }


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
