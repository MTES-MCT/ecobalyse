module Data.Component exposing
    ( Component
    , Config
    , Consumption
    , Custom
    , DataContainer
    , Element
    , EndOfLifeMaterialImpacts
    , ExpandedElement
    , ExpandedItem
    , ExpandedLocalizedProcess
    , Id
    , Index
    , Item
    , LifeCycle
    , Packaging(..)
    , Quantity
    , Query
    , Requirements
    , ResultedElement
    , Results(..)
    , Stage(..)
    , TargetElement
    , TargetItem
    , TransportOptions
    , addElement
    , addElementTransform
    , addItem
    , addOrSetProcess
    , applyDurability
    , applyTransforms
    , compute
    , computeElementResults
    , computeImpacts
    , computeInitialAmount
    , computeItemResults
    , computeScoring
    , computeTransportDistance
    , computeTransportedMassImpacts
    , computeVolumeFromMass
    , createItem
    , decode
    , decodeItem
    , decodeList
    , decodeListFromJsonString
    , decodeQuery
    , defaultConfig
    , defaultDurability
    , defaultTransportOptions
    , elementTransforms
    , elementsToString
    , emptyComponent
    , emptyLifeCycle
    , emptyQuery
    , emptyResults
    , encode
    , encodeBase64Query
    , encodeId
    , encodeItem
    , encodeLifeCycle
    , encodeQuery
    , expandConsumptions
    , expandElements
    , expandItems
    , extractAmount
    , extractComplementsImpacts
    , extractImpacts
    , extractItems
    , extractMass
    , extractStage
    , findById
    , getAvailableDistributionProcesses
    , getEndOfLifeDetailedImpacts
    , getEndOfLifeImpacts
    , getEndOfLifeScopeCollectionRate
    , getFinalElementCountry
    , getResultedElement
    , getTotalImpacts
    , idFromString
    , idToString
    , isEmpty
    , itemToComponent
    , itemToString
    , itemsToString
    , loadEnergyMixes
    , mapItems
    , nonLocalizedExpandedProcess
    , nonLocalizedProcess
    , parseBase64Query
    , parseConfig
    , quantityFromInt
    , quantityToInt
    , removeConsumption
    , removeElement
    , removeElementTransform
    , setCustomScope
    , setElementMaterial
    , setQueryItems
    , setTransportByAir
    , setTransportCooling
    , stagesImpacts
    , sumLifeCycleImpacts
    , targetElementToString
    , toSearchableString
    , transformListToString
    , tryMapItems
    , updateConsumptionAmount
    , updateDistribution
    , updateDurability
    , updateElementAmount
    , updateElementMaterialCountry
    , updateElementTransformCountry
    , updateItem
    , updateItemCustomName
    , updateRecyclable
    , validateItem
    , validateQuery
    )

import Base64
import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Complement as Complement exposing (ComplementsImpacts, ComplementsResultsImpacts)
import Data.Component.Amount as Amount exposing (Amount)
import Data.Component.Config as Config exposing (EndOfLifeStrategies, EndOfLifeStrategy)
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions, Trigram)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category, MaterialDict)
import Data.Scope as Scope exposing (Scope)
import Data.Scoring as Scoring exposing (Scoring)
import Data.Split as Split exposing (Split)
import Data.Stages exposing (Stages)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit exposing (QuantityVariationRatio)
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
import Views.Format as Format
import Volume exposing (Volume)


type Id
    = Id Uuid


{-| A Component is a named collection of elements
-}
type alias Component =
    { comment : Maybe String
    , elements : List Element
    , id : Maybe Id
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
    , consumptions : List Consumption
    , distribution : Maybe Process.Id

    -- Note: component durability is experimental, future work may eventually be needed to
    -- reuse existing mechanics and handle holistic durability like it's implemented for textile,
    -- though it's still an ongoing discussion and we need to move forward and iterate.
    , durability : Maybe Unit.Ratio
    , items : List Item
    , packagings : List Packaging
    , recyclable : Bool
    , transportOptions : TransportOptions
    }


{-| Use stage consumption, a process and a quantity of its unit
-}
type alias Consumption =
    { amount : Amount
    , processId : Process.Id
    }


{-| Errors related to distribution process handling and availability
-}
type DistributionProcessError
    = DistributionGenericError String
    | DistributionNothingAvailable


{-| A compact reference to a component, a quantity of it, a production localization
and optional overrides, typically used for queries
-}
type alias Item =
    { custom : Maybe Custom
    , id : Maybe Id
    , quantity : Quantity
    }


type alias ExpandedItem =
    { component : Component
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
    , material : LocalizedProcess
    , transforms : List LocalizedProcess
    }


{-| A full representation of an amount of material and optional transformations of it

Note: the `country` field is propagated from the parent component item, for convenience

-}
type alias ExpandedElement =
    { amount : Amount
    , material : ExpandedLocalizedProcess
    , transforms : List ExpandedLocalizedProcess
    }


type alias Index =
    Int


{-| A process id with an optional country
-}
type alias LocalizedProcess =
    { country : Maybe Country.Code
    , id : Process.Id
    }


{-| A full process with an optional country
-}
type alias ExpandedLocalizedProcess =
    { country : Maybe Country
    , process : Process
    }


{-| Packaging process id and a quantity of its unit
-}
type Packaging
    = Packaging QuantifiedProcess


type ExpandedPackaging
    = ExpandedPackaging ExpandedQuantifiedProcess


type alias QuantifiedProcess =
    { amount : Amount
    , processId : Process.Id
    }


type alias ExpandedQuantifiedProcess =
    { amount : Amount
    , processId : Process
    }


{-| An expanded element and its results
-}
type alias ResultedElement =
    ( ExpandedElement, Results )


{-| Index of an item element and associated source component
-}
type alias TargetElement =
    ( TargetItem, Index )


{-| Index of an item and associated source component
-}
type alias TargetItem =
    ( Component, Index )


{-| A number of components
-}
type Quantity
    = Quantity Int


type alias TransportOptions =
    { byAir : Split
    , cooling : Bool
    }


{-| A data structure exposing detailed impacts at the end of life stage of the lifeCycle
-}
type alias DetailedEndOfLifeImpacts =
    MaterialDict EndOfLifeMaterialImpacts


type alias DistributionResults =
    { impacts : Impacts
    , process : Maybe Process
    , volume : Volume
    }


type alias EndOfLifeMaterialImpacts =
    { collected : ( Mass, EndOfLifeStrategies )
    , nonCollected : ( Mass, EndOfLifeStrategies )
    }


{-| Lifecycle impacts
-}
type alias LifeCycle =
    { distribution : DistributionResults
    , endOfLife : Impacts
    , packaging : Impacts
    , production : Results
    , transports : LifeCycleTransport
    , use : List Impacts
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
        , complementsImpacts : ComplementsResultsImpacts
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
    | TransportStage


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
                                ++ [ { amount = Amount.fromFloat 1
                                     , material = nonLocalizedProcess material.id
                                     , transforms = []
                                     }
                                   ]
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
                (\el -> { el | transforms = el.transforms ++ [ nonLocalizedProcess transform.id ] })
            |> Ok


addItem : Maybe Id -> List Item -> List Item
addItem maybeId items =
    items ++ [ createItem maybeId ]


addOrSetProcess : DataContainer db -> Category -> TargetItem -> Maybe Index -> Process -> List Item -> Result String (List Item)
addOrSetProcess db category targetItem maybeElementIndex process items =
    case ( category, maybeElementIndex ) of
        ( Category.Material, Just elementIndex ) ->
            items |> setElementMaterial db ( targetItem, elementIndex ) process

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
            | complementsImpacts = Complement.sumComplementsResultsImpacts [ results.complementsImpacts, acc.complementsImpacts ]
            , impacts = Impact.sumImpacts [ results.impacts, acc.impacts ]
            , items = Results results :: acc.items
            , mass = Quantity.sum [ results.mass, acc.mass ]
            , stage = Nothing
        }


applyComplementsResultsImpacts : Amount -> Impacts -> ComplementsImpacts -> ComplementsResultsImpacts
applyComplementsResultsImpacts amount impacts =
    Complement.mapComplements
        (Maybe.map
            (\complement ->
                impacts
                    |> Complement.applyComplementsToImpacts complement
                    |> Impact.multiplyBy (Amount.toFloat amount)
            )
        )


applyDurability : Maybe Unit.Ratio -> LifeCycle -> Impacts
applyDurability maybeDurability =
    sumLifeCycleImpacts
        >> (case maybeDurability of
                Just durability ->
                    Impact.divideBy (Unit.ratioToFloat durability)

                Nothing ->
                    identity
           )


applyTransform : Process -> EnergyMixes -> Results -> Results
applyTransform transform { elec, heat } (Results { amount, label, impacts, items, mass, complementsImpacts }) =
    let
        transformImpacts =
            [ transform.impacts
            , elec.impacts |> Impact.multiplyBy (Energy.inKilowattHours transform.elec)
            , heat.impacts |> Impact.multiplyBy (Energy.inMegajoules transform.heat)
            ]
                |> Impact.sumImpacts
                -- Note: impacts are always computed from input amount
                |> Impact.multiplyBy (Amount.toFloat amount)

        outputAmount =
            amount |> applyQtyVariationRatio transform.qtyVariationRatio

        outputMass =
            mass |> Unit.applyQtyVariationRatioToMass transform.qtyVariationRatio
    in
    Results
        { amount = outputAmount
        , complementsImpacts = complementsImpacts
        , impacts = Impact.sumImpacts [ transformImpacts, impacts ]
        , items =
            items
                ++ [ -- transform result
                     Results
                        { amount = outputAmount
                        , complementsImpacts = Complement.emptyComplementsResultsImpacts
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


{-| Sequencially apply transforms to existing Results (typically, from material ones).

Transported mass impacts and energy mixes use ones are computed at the transform step level: each step can optionally
specify a country to use its electricity/heat mixes, or fallback to config defaults when absent.

-}
applyTransforms : Requirements db -> TransportOptions -> Maybe Country -> Process.Unit -> List ExpandedLocalizedProcess -> Results -> Result String Results
applyTransforms requirements transportOptions initialCountry unit transforms materialResults =
    checkTransformsUnit unit transforms
        |> Result.andThen
            (RE.foldlWhileOk
                (\{ country, process } ( previousCountry, results ) ->
                    loadEnergyMixes requirements.config country
                        |> Result.andThen
                            (\mixes ->
                                results
                                    |> applyTransportedMassImpacts requirements
                                        -- no intermediary transport to transformation can ever feature air transport
                                        { transportOptions | byAir = Split.zero }
                                        (extractMass results)
                                        previousCountry
                                        country
                                    |> Result.map (\results_ -> ( country, applyTransform process mixes results_ ))
                            )
                )
                ( initialCountry, materialResults )
            )
        |> Result.map Tuple.second


{-| Add transport impacts for a mass and two optional countries to a results, falling back to transport config
defaults when both are unknown.
-}
applyTransportedMassImpacts : Requirements db -> TransportOptions -> Mass -> Maybe Country -> Maybe Country -> Results -> Result String Results
applyTransportedMassImpacts requirements transportOptions mass maybeFrom maybeTo (Results results) =
    computeTransportedMassImpacts requirements transportOptions maybeFrom maybeTo mass
        |> Result.map
            (\transport ->
                Results
                    { results
                        | impacts = Impact.sumImpacts [ results.impacts, transport.impacts ]
                        , items =
                            results.items
                                ++ [ Results
                                        { amount = results.amount
                                        , complementsImpacts = Complement.emptyComplementsResultsImpacts
                                        , impacts = transport.impacts
                                        , items = []
                                        , label = Just "Transport"
                                        , mass = mass
                                        , materialType = Nothing
                                        , quantity = 1
                                        , stage = Just TransportStage
                                        }
                                   ]
                    }
            )


applyQtyVariationRatio : QuantityVariationRatio -> Amount -> Amount
applyQtyVariationRatio qtyVariationRatio =
    Amount.map (\amount -> amount * Unit.qtyVariationRatioToFloat qtyVariationRatio)


checkTransformsUnit : Process.Unit -> List ExpandedLocalizedProcess -> Result String (List ExpandedLocalizedProcess)
checkTransformsUnit unit transforms =
    if not <| List.all (.process >> .unit >> (==) unit) transforms then
        "Les procédés de transformation ne partagent pas la même unité que la matière source ("
            ++ Process.unitToString unit
            ++ ")\u{00A0}: "
            ++ (transforms
                    |> List.filter (.process >> .unit >> (/=) unit)
                    |> List.map (\{ process } -> Process.getDisplayName process ++ " (" ++ Process.unitToString process.unit ++ ")")
                    |> String.join ", "
               )
            |> Err

    else
        Ok transforms


{-| Create a component from a custom definition
-}
componentFromCustom : Maybe Component -> Maybe Custom -> Component
componentFromCustom maybeComponent maybeCustom =
    let
        component =
            maybeComponent |> Maybe.withDefault emptyComponent
    in
    case maybeCustom of
        Just { elements, name, scope } ->
            { component
                | elements = elements
                , name = name |> Maybe.withDefault component.name
                , scope = scope |> Maybe.withDefault component.scope
            }

        Nothing ->
            component


{-| Computes impacts from a list of available components, processes and specified component items
-}
compute : Requirements db -> Query -> Result String LifeCycle
compute requirements query =
    query.items
        |> List.map (computeItemResults requirements query.transportOptions)
        |> RE.combine
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map (\(Results results) -> { emptyLifeCycle | production = Results { results | label = Just "Production" } })
        |> Result.andThen (computeDistributionImpacts requirements query)
        |> Result.map (computeEndOfLifeResults requirements query)
        |> Result.andThen (computeTransports requirements query)
        |> Result.andThen (computeUseImpacts requirements query)


computeVolumeFromMass : Mass -> Volume
computeVolumeFromMass =
    -- Note: for now, assume the volume in m3 is the same as the mass in kg/1000
    -- TODO: this is a temporary solution, we'll eventually need to get the proper volume per unit from the process
    Quantity.divideBy 1000
        >> Mass.inKilograms
        >> Volume.cubicMeters


computeDistributionImpacts : Requirements db -> Query -> LifeCycle -> Result String LifeCycle
computeDistributionImpacts ({ config } as requirements) query ({ distribution, production } as lifeCycle) =
    let
        finalProductVolume =
            computeVolumeFromMass <| extractMass production
    in
    case getDistributionProcess requirements query.distribution of
        Err (DistributionGenericError errorMessage) ->
            Err errorMessage

        Err DistributionNothingAvailable ->
            -- No distribution processes are available for this scope, so no added impacts
            Ok { lifeCycle | distribution = { distribution | volume = finalProductVolume } }

        Ok process ->
            Ok
                { lifeCycle
                    | distribution =
                        { impacts =
                            process
                                |> Process.impactsPerUnit config.distribution.country
                                |> Impact.multiplyBy (Volume.inCubicMeters finalProductVolume)
                        , process = Just process
                        , volume = finalProductVolume
                        }
                }


computeElementResults : Requirements db -> TransportOptions -> Element -> Result String Results
computeElementResults requirements transportOptions =
    expandElement requirements.db
        >> Result.andThen
            (\{ amount, material, transforms } ->
                amount
                    |> computeInitialAmount (List.map (.process >> .qtyVariationRatio) transforms)
                    |> Result.andThen
                        (\initialAmount ->
                            material.process
                                |> computeMaterialResults initialAmount
                                |> applyTransforms requirements transportOptions material.country material.process.unit transforms
                        )
            )


computeEndOfLifeResults : Requirements db -> Query -> LifeCycle -> LifeCycle
computeEndOfLifeResults requirements query lifeCycle =
    { lifeCycle
        | endOfLife =
            lifeCycle.production
                |> getEndOfLifeImpacts requirements query.recyclable
    }


{-| Compute an initially required amount from sequentially applied waste ratios
-}
computeInitialAmount : List QuantityVariationRatio -> Amount -> Result String Amount
computeInitialAmount qtyVariationRatios amount =
    if List.member 0 (qtyVariationRatios |> List.map Unit.qtyVariationRatioToFloat) then
        Err "Un ratio de variation de quantité ne peut pas être de 0"

    else
        qtyVariationRatios
            |> List.foldr
                (\qtyVariationRatio ->
                    Amount.map (\float -> float / Unit.qtyVariationRatioToFloat qtyVariationRatio)
                )
                amount
            |> Ok


{-| Compute a single component impact
-}
computeImpacts : Requirements db -> TransportOptions -> Component -> Result String Results
computeImpacts requirements transportOptions =
    .elements
        >> List.map (computeElementResults requirements transportOptions)
        >> RE.combine
        >> Result.map (List.foldr addResults emptyResults)


computeItemResults : Requirements db -> TransportOptions -> Item -> Result String Results
computeItemResults requirements transportOptions { custom, id, quantity } =
    let
        component_ =
            case id of
                Just id_ ->
                    findById id_ requirements.db.components

                Nothing ->
                    Ok emptyComponent
    in
    component_
        |> Result.andThen
            (\component ->
                custom
                    |> customElements component
                    |> List.map (computeElementResults requirements transportOptions)
                    |> RE.combine
            )
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map
            (\(Results { complementsImpacts, impacts, mass, materialType, items }) ->
                Results
                    { amount = Amount.fromFloat 0
                    , complementsImpacts =
                        complementsImpacts
                            |> List.repeat (quantityToInt quantity)
                            |> Complement.sumComplementsResultsImpacts
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
            -- Note: materials impacts embed energy ones
            process.impacts
                |> Impact.multiplyBy (Amount.toFloat amount)

        complementImpacts =
            process.metadata
                |> Maybe.andThen .complements
                |> Maybe.map (applyComplementsResultsImpacts amount Impact.empty)
                |> Maybe.withDefault Complement.emptyComplementsResultsImpacts

        mass =
            Mass.kilograms <|
                if process.unit == Process.Kilogram then
                    Amount.toFloat amount

                else
                    -- apply mass per unit
                    Amount.toFloat amount * Maybe.withDefault 1 process.massPerUnit

        materialType =
            Process.getMaterialTypes process
                |> List.head
                |> Maybe.withDefault Category.OtherMaterial
                |> Just
    in
    -- global result
    Results
        { amount = amount
        , complementsImpacts = complementImpacts
        , impacts = impacts
        , items =
            [ -- material result
              Results
                { amount = amount
                , complementsImpacts = complementImpacts
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


computeScoring : Definitions -> LifeCycle -> Scoring
computeScoring definitions { production } =
    let
        ( totalImpacts, totalMass, complementImpacts ) =
            ( extractImpacts production
            , extractMass production
              -- New metadata complements should always be added and not substracted as before, that’s why we negate it
              -- here to stay compatible with the current implementations for Ecosystemic Services
            , extractComplementsImpacts production
                |> Complement.mergeComplementsResultsImpacts
                |> Impact.getImpact Definition.Ecs
            )
    in
    totalImpacts
        |> Impact.divideBy (Mass.inKilograms totalMass)
        |> Scoring.compute definitions complementImpacts


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


{-| This function is used to configure default distances according to desired options, most notably
cooling and air transport ratio.
-}
computeTransportDefaultDistance : TransportOptions -> Transport -> Transport
computeTransportDefaultDistance { byAir } defaultDistance =
    let
        -- default road transport to hub must be doubled when no distance could be determined
        -- @see https://github.com/MTES-MCT/ecobalyse/issues/2345
        road =
            defaultDistance.road |> Quantity.multiplyBy 2

        -- Full air transport, or full boat, no in-between for now
        ( air, sea ) =
            if byAir == Split.full then
                ( defaultDistance.air, Quantity.zero )

            else
                ( Quantity.zero, defaultDistance.sea )
    in
    { defaultDistance
        | air = air
        , road = road
        , sea = sea
    }


{-| Computes the transport distance between two countries, including the road distance to hub for each country.
Fallbacks to default config distances in case a country is not defined.

Notes:

  - this only computes the transport distances, not the impacts (as a transported mass would be required)
  - the distance to hub computation logic should eventually be backported to non-generic scopes

-}
computeTransportDistance : Requirements db -> Split -> Maybe Country -> Maybe Country -> Result String (Maybe Transport)
computeTransportDistance { config, db } airTransportRatio maybeFrom maybeTo =
    let
        { defaultDistance } =
            config.transports

        -- When a single country is known (departure or destination), sum its distance to hub and default
        -- road transport
        handleSingleKnownCountry country =
            { defaultDistance
                | road = Quantity.sum [ defaultDistance.road, country.distanceToHub ]
            }
                -- then handle air vs. sea transport
                |> (\transport ->
                        -- When no air transport ratio specified, reset the default air distance entirely
                        if airTransportRatio == Split.zero then
                            { transport | air = Quantity.zero }

                        else
                            -- otherwise, remove sea transport entirely as we can't accumulate plane+boat on a trip
                            { transport | sea = Quantity.zero, seaCooled = Quantity.zero }
                   )
                |> Just
    in
    case ( maybeFrom, maybeTo ) of
        -- only departure country is known
        ( Just from, Nothing ) ->
            Ok <| handleSingleKnownCountry from

        -- only destination country is known
        ( Nothing, Just to ) ->
            Ok <| handleSingleKnownCountry to

        -- both countries are known
        ( Just from, Just to ) ->
            db.distances
                |> Transport.getTransportBetween from to
                |> Result.map (Transport.applyTransportRatios airTransportRatio)
                |> Result.map
                    (\transport ->
                        { transport
                            | road =
                                if from == to then
                                    -- same country, add transport to hub once, ignore distance from transports.json
                                    from.distanceToHub

                                else
                                    -- different countries, add distances to hub at both ends
                                    Quantity.sum
                                        [ from.distanceToHub
                                        , transport.road
                                        , to.distanceToHub
                                        ]
                        }
                    )
                |> Result.map Just

        -- no countries are known; no distances returned
        ( Nothing, Nothing ) ->
            Ok Nothing


{-| Computes the transport distances and impacts from a transported mass.
-}
computeTransportedMassImpacts : Requirements db -> TransportOptions -> Maybe Country -> Maybe Country -> Mass -> Result String Transport
computeTransportedMassImpacts ({ config } as requirements) ({ byAir, cooling } as transportOptions) maybeFrom maybeTo mass =
    computeTransportDistance requirements byAir maybeFrom maybeTo
        -- Unknow distance: fallback to using default distances, adapted to desired options
        |> Result.map
            (config.transports.defaultDistance
                |> computeTransportDefaultDistance transportOptions
                |> Maybe.withDefault
            )
        -- remap cooled transportation modes if needed
        |> Result.map
            (if cooling then
                Transport.makeCooled

             else
                identity
            )
        -- compute resulting impacts
        |> Result.map (Transport.computeImpacts config.transports.modeProcesses mass)


{-| Computes transports impacts:

  - for a single component product, the summed impacts of transporting its individual elements directly to distribution
  - for a multiple components product:
      - if we know the country of assembly, the summed impacts of transporting each component's elements to assembly,
        then the summed impacts of transporting the assembled product mass to distribution
      - if we don't know the country of assembly, the summed impacts of each component's elements transported using
        default unknown transport distances, then the assembled product mass to distribution

-}
computeTransports : Requirements db -> Query -> LifeCycle -> Result String LifeCycle
computeTransports ({ config, db } as requirements) ({ transportOptions } as query) lifeCycle =
    Result.map2
        (\resultedElements maybeAssemblyCountry ->
            let
                distributionCountry =
                    Just config.distribution.country

                totalProductMass =
                    extractMass lifeCycle.production

                transportElements fn =
                    resultedElements
                        |> List.map fn
                        |> RE.combine
                        |> Result.map Transport.sum

                transportImpacts =
                    computeTransportedMassImpacts requirements

                setLifeCycleTransports toAssembly toDistribution =
                    { lifeCycle | transports = LifeCycleTransport toAssembly toDistribution }
            in
            case ( List.length query.items, maybeAssemblyCountry ) of
                ( 0, Just _ ) ->
                    Err "Une liste de composants vide ne peut être assemblée"

                ( 1, Just _ ) ->
                    Err "Un composant unique ne peut pas être assemblé"

                -- Many components assembled; for all components, each elements are individually shipped to assembly,
                -- then the assembled product mass is transported to distribution
                ( _, Just assemblyCountry ) ->
                    Result.map2 setLifeCycleTransports
                        -- toAssembly
                        (transportElements
                            (\( expandedElement, elementResults ) ->
                                extractMass elementResults
                                    -- note: air transport is always disabled before assembly
                                    |> transportImpacts { transportOptions | byAir = Split.zero }
                                        (getFinalElementCountry expandedElement)
                                        (Just assemblyCountry)
                            )
                        )
                        -- toDistribution
                        (totalProductMass
                            |> transportImpacts transportOptions maybeAssemblyCountry distributionCountry
                        )

                -- Default state, empty transports
                ( 0, Nothing ) ->
                    Ok { lifeCycle | transports = emptyLifeCycleTransports }

                -- Single unique component; its elements are directly shipped to distribution individually,
                -- with no transport to assembly stage
                ( 1, Nothing ) ->
                    Result.map2 setLifeCycleTransports
                        -- toAssembly
                        (Ok Transport.noTransport)
                        -- toDistribution
                        (transportElements
                            (\( expandedElement, elementResults ) ->
                                extractMass elementResults
                                    |> transportImpacts transportOptions
                                        (getFinalElementCountry expandedElement)
                                        distributionCountry
                            )
                        )

                -- Many items with no assembly country specified; all item elements are individually shipped to
                -- the assembly stage unique default unknown transport distances,
                -- then the total mass of the assembled end product is transported to distribution country
                ( _, Nothing ) ->
                    Result.map2 setLifeCycleTransports
                        -- toAssembly
                        (transportElements
                            (\( _, elementResults ) ->
                                -- all item elements are individually shipped to the assembly stage using default unknown transport distances
                                extractMass elementResults
                                    -- note: air transport is always disabled before assembly
                                    |> transportImpacts { transportOptions | byAir = Split.zero } Nothing Nothing
                            )
                        )
                        -- toDistribution
                        (totalProductMass
                            |> transportImpacts transportOptions Nothing distributionCountry
                        )
        )
        (query.items |> expandItems db |> Result.andThen (getResultedElementList lifeCycle.production))
        (Country.resolveMaybe query.assemblyCountry db.countries)
        |> RE.join


computeUseImpacts : Requirements db -> Query -> LifeCycle -> Result String LifeCycle
computeUseImpacts { config, db } { consumptions } lifeCycle =
    consumptions
        |> expandConsumptions db.processes
        |> Result.map
            (\expandedConsumptions ->
                { lifeCycle
                    | use =
                        expandedConsumptions
                            |> List.map
                                (\( amount, process ) ->
                                    process
                                        |> Process.computeImpacts { elec = config.use.defaultElecProcess, heat = config.use.defaultHeatProcess }
                                        |> Impact.multiplyBy (Amount.toFloat amount)
                                )
                }
            )


createItem : Maybe Id -> Item
createItem maybeId =
    { custom = Nothing
    , id = maybeId
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
        |> DU.strictOptional "id" (Decode.map Id Uuid.decoder)
        |> Decode.required "name" Decode.string
        -- If there is no published field provided, we’re reading the values from
        -- static files and by default, all components in the static files should
        -- be considered as published
        |> Decode.optional "published" Decode.bool True
        |> Decode.required "scopes"
            -- Note: the backend exposes multiple scopes per component, though it's been decided
            -- a component should only allow one, so here we take the first declared scope.
            (Decode.list Scope.decode
                |> Decode.map (List.head >> Maybe.withDefault (Scope.Generic Scope.Object))
            )


decodeBase64Query : String -> Result String Query
decodeBase64Query =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decodeQuery
                >> Result.mapError Decode.errorToString
            )


decodeConsumption : Decoder Consumption
decodeConsumption =
    Decode.succeed Consumption
        |> Decode.required "amount" Amount.decode
        |> Decode.required "processId" Process.decodeId


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
        |> Decode.required "amount" Amount.decode
        |> Decode.required "material" decodeMaterial
        |> Decode.optional "transforms" decodeTransforms []


decodeLocalizedProcess : Decoder LocalizedProcess
decodeLocalizedProcess =
    Decode.succeed (\country id -> { country = country, id = id })
        |> DU.strictOptional "country" Country.decodeCode
        |> Decode.required "id" Process.decodeId


decodeMaterial : Decoder LocalizedProcess
decodeMaterial =
    Decode.oneOf
        [ decodeLocalizedProcess

        -- Backward-compatible decoder for materials when they were just process ids
        , Process.decodeId |> Decode.map nonLocalizedProcess
        ]


decodePackaging : Decoder Packaging
decodePackaging =
    decodeQuantifiedProcess
        |> Decode.map Packaging


decodeQuantifiedProcess : Decoder QuantifiedProcess
decodeQuantifiedProcess =
    Decode.succeed QuantifiedProcess
        |> Decode.required "amount" Amount.decode
        |> Decode.required "processId" Process.decodeId


decodeTransforms : Decoder (List LocalizedProcess)
decodeTransforms =
    Decode.oneOf
        [ Decode.list decodeLocalizedProcess

        -- Backward-compatible decoder for transforms when they were just process ids
        , Decode.list (Process.decodeId |> Decode.map nonLocalizedProcess)
        ]


decodeItem : Decoder Item
decodeItem =
    Decode.succeed Item
        |> DU.strictOptional "custom" decodeCustom
        |> DU.strictOptional "id" (Decode.map Id Uuid.decoder)
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
        |> Decode.optional "consumptions" (Decode.list decodeConsumption) []
        |> DU.strictOptional "distribution" Process.decodeId
        |> DU.strictOptional "durability" Unit.decodeRatio
        |> Decode.required "components" (Decode.list decodeItem)
        |> Decode.optional "packagings" (Decode.list decodePackaging) []
        |> Decode.optional "recyclable" Decode.bool True
        |> Decode.optional "transportOptions" decodeTransportOptions defaultTransportOptions


decodeTransportOptions : Decoder TransportOptions
decodeTransportOptions =
    Decode.succeed TransportOptions
        |> Decode.optional "byAir" Split.decodePercent Split.zero
        |> Decode.optional "cooling" Decode.bool False


{-| Proxified for convenience
-}
defaultConfig : DataContainer db -> Result String Config
defaultConfig =
    Config.default


defaultDurability : Unit.Ratio
defaultDurability =
    Unit.ratio 1


defaultTransportOptions : TransportOptions
defaultTransportOptions =
    { byAir = Split.zero
    , cooling = False
    }


elementToString : List Process -> Element -> Result String String
elementToString processes element =
    processes
        |> Process.findById element.material.id
        |> Result.map
            (\process ->
                Format.formatFloat 5 (Amount.toFloat element.amount)
                    ++ Process.unitToString process.unit
                    ++ " "
                    ++ Process.getDisplayName process
            )


elementTransforms : TargetElement -> List Item -> List Process.Id
elementTransforms ( targetItem, elementIndex ) =
    itemElements targetItem
        >> LE.getAt elementIndex
        >> Maybe.map .transforms
        >> Maybe.map (List.map .id)
        >> Maybe.withDefault []


elementsToString : DataContainer db -> Component -> Result String String
elementsToString db component =
    component.elements
        |> RE.combineMap (elementToString db.processes)
        |> Result.map (String.join " | ")


emptyDistributionResults : DistributionResults
emptyDistributionResults =
    { impacts = Impact.empty
    , process = Nothing
    , volume = Quantity.zero
    }


emptyLifeCycle : LifeCycle
emptyLifeCycle =
    { distribution = emptyDistributionResults
    , endOfLife = Impact.empty
    , packaging = Impact.empty
    , production = emptyResults
    , transports = emptyLifeCycleTransports
    , use = []
    }


emptyLifeCycleTransports : LifeCycleTransport
emptyLifeCycleTransports =
    { toAssembly = Transport.default Impact.empty
    , toDistribution = Transport.default Impact.empty
    }


emptyQuery : Query
emptyQuery =
    { assemblyCountry = Nothing
    , consumptions = []
    , distribution = Nothing
    , durability = Nothing
    , items = []
    , packagings = []
    , recyclable = True
    , transportOptions = defaultTransportOptions
    }


emptyResults : Results
emptyResults =
    Results
        { amount = Amount.fromFloat 0
        , complementsImpacts = Complement.emptyComplementsResultsImpacts
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
    EU.optionalPropertiesObject
        [ ( "comment", v.comment |> Maybe.map Encode.string )
        , ( "elements", v.elements |> Encode.list encodeElement |> Just )
        , ( "id", v.id |> Maybe.map encodeId )
        , ( "name", v.name |> Encode.string |> Just )
        , ( "published", v.published |> Encode.bool |> Just )
        , ( "scopes", [ v.scope ] |> Encode.list Scope.encode |> Just )
        ]


encodeBase64Query : Query -> String
encodeBase64Query =
    encodeQuery >> Encode.encode 0 >> Base64.encode


encodeConsumption : Consumption -> Encode.Value
encodeConsumption v =
    Encode.object
        [ ( "amount", v.amount |> Amount.toFloat |> Encode.float )
        , ( "processId", v.processId |> Process.encodeId )
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
        [ ( "amount", Amount.encode element.amount )
        , ( "material", encodeLocalizedProcess element.material )
        , ( "transforms", element.transforms |> Encode.list encodeTransform )
        ]


encodeLocalizedProcess : LocalizedProcess -> Encode.Value
encodeLocalizedProcess localizedProcess =
    EU.optionalPropertiesObject
        [ ( "country", localizedProcess.country |> Maybe.map Country.encodeCode )
        , ( "id", localizedProcess.id |> Process.encodeId |> Just )
        ]


encodePackaging : Packaging -> Encode.Value
encodePackaging (Packaging v) =
    encodeQuantifiedProcess v


encodeQuantifiedProcess : QuantifiedProcess -> Encode.Value
encodeQuantifiedProcess v =
    Encode.object
        [ ( "amount", v.amount |> Amount.toFloat |> Encode.float )
        , ( "processId", v.processId |> Process.encodeId )
        ]


encodeTransform : LocalizedProcess -> Encode.Value
encodeTransform transform =
    encodeLocalizedProcess transform


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


encodeItem : Item -> Encode.Value
encodeItem item =
    EU.optionalPropertiesObject
        [ ( "id", item.id |> Maybe.map (idToString >> Encode.string) )
        , ( "quantity", item.quantity |> quantityToInt |> Encode.int |> Just )
        , ( "custom", item.custom |> Maybe.map encodeCustom )
        ]


encodeLifeCycle : Maybe Trigram -> LifeCycle -> Encode.Value
encodeLifeCycle maybeTrigram lifeCycle =
    Encode.object
        [ ( "endOfLife"
          , case maybeTrigram of
                Just trigram ->
                    lifeCycle.endOfLife
                        |> Impact.getImpact trigram
                        |> Unit.encodeImpact

                Nothing ->
                    Impact.encode lifeCycle.endOfLife
          )
        , ( "distribution", encodeLifeCycleDistribution lifeCycle.distribution )
        , ( "production", encodeResults maybeTrigram lifeCycle.production )
        , ( "transport", encodeLifeCycleTransport lifeCycle.transports )
        , ( "use", Encode.list Impact.encode lifeCycle.use )
        ]


encodeLifeCycleDistribution : DistributionResults -> Encode.Value
encodeLifeCycleDistribution distribution =
    EU.optionalPropertiesObject
        [ ( "impacts", distribution.impacts |> Impact.encode |> Just )
        , ( "process", distribution.process |> Maybe.map (.id >> Process.encodeId) )
        , ( "volume", distribution.volume |> Volume.inCubicMeters |> Encode.float |> Just )
        ]


encodeLifeCycleTransport : LifeCycleTransport -> Encode.Value
encodeLifeCycleTransport v =
    Encode.object
        [ ( "toAssembly", Transport.encode v.toAssembly )
        , ( "toDistribution", Transport.encode v.toDistribution )
        ]


encodeQuery : Query -> Encode.Value
encodeQuery query =
    EU.optionalPropertiesObject
        [ ( "assemblyCountry", query.assemblyCountry |> Maybe.map Country.encodeCode )
        , ( "components", query.items |> Encode.list encodeItem |> Just )
        , ( "consumptions"
          , if List.isEmpty query.consumptions then
                Nothing

            else
                query.consumptions |> Encode.list encodeConsumption |> Just
          )
        , ( "distribution", query.distribution |> Maybe.map Process.encodeId )
        , ( "durability", query.durability |> Maybe.map Unit.encodeRatio )
        , ( "packagings"
          , if List.isEmpty query.packagings then
                Nothing

            else
                query.packagings |> Encode.list encodePackaging |> Just
          )
        , ( "recyclable", query.recyclable |> Encode.bool |> Just )
        , ( "transportOptions", encodeTransportOptions query.transportOptions )
        ]


encodeComplementsResultsImpacts : Maybe Trigram -> ComplementsResultsImpacts -> Encode.Value
encodeComplementsResultsImpacts maybeTrigram complementsResultsImpacts =
    let
        encodeComplement complement =
            case maybeTrigram of
                Just trigram ->
                    complement
                        |> Impact.getImpact trigram
                        |> Unit.encodeImpact

                Nothing ->
                    Impact.encode complement
    in
    EU.optionalPropertiesObject
        [ ( "cropDiversity", complementsResultsImpacts.cropDiversity |> Maybe.map encodeComplement )
        , ( "forest", complementsResultsImpacts.forest |> Maybe.map encodeComplement )
        , ( "hedges", complementsResultsImpacts.hedges |> Maybe.map encodeComplement )
        , ( "microfibers", complementsResultsImpacts.microfibers |> Maybe.map encodeComplement )
        , ( "outOfEuropeEOL", complementsResultsImpacts.outOfEuropeEOL |> Maybe.map encodeComplement )
        , ( "permanentPasture", complementsResultsImpacts.permanentPasture |> Maybe.map encodeComplement )
        , ( "plotSize", complementsResultsImpacts.plotSize |> Maybe.map encodeComplement )
        ]


encodeResults : Maybe Trigram -> Results -> Encode.Value
encodeResults maybeTrigram (Results results) =
    EU.optionalPropertiesObject
        [ ( "label", results.label |> Maybe.map Encode.string )
        , ( "stage", results.stage |> Maybe.map (stageToString >> Encode.string) )
        , ( "mass", results.mass |> Mass.inKilograms |> Encode.float |> Just )
        , ( "materialType", results.materialType |> Maybe.map (Category.materialTypeToString >> Encode.string) )
        , ( "quantity", results.quantity |> Encode.int |> Just )
        , ( "complementsImpacts"
          , results.complementsImpacts |> encodeComplementsResultsImpacts maybeTrigram |> Just
          )
        , ( "impacts"
          , Just <|
                case maybeTrigram of
                    Just trigram ->
                        results.impacts
                            |> Impact.getImpact trigram
                            |> Unit.encodeImpact

                    Nothing ->
                        Impact.encode results.impacts
          )
        , ( "items", results.items |> Encode.list (encodeResults maybeTrigram) |> Just )
        ]


encodeTransportOptions : TransportOptions -> Maybe Encode.Value
encodeTransportOptions { byAir, cooling } =
    -- Encode only JSON keys that are different from defaults
    case ( byAir == defaultTransportOptions.byAir, cooling == defaultTransportOptions.cooling ) of
        ( True, True ) ->
            Nothing

        ( False, True ) ->
            Just <| Encode.object [ ( "byAir", Split.encodePercent byAir ) ]

        ( True, False ) ->
            Just <| Encode.object [ ( "cooling", Encode.bool cooling ) ]

        ( False, False ) ->
            [ ( "byAir", Split.encodePercent byAir )
            , ( "cooling", Encode.bool cooling )
            ]
                |> Encode.object
                |> Just


{-| Common reusable error strings
-}
errors :
    { elementNotFound : String
    , itemNotFound : String
    }
errors =
    { elementNotFound = "Élément introuvable"
    , itemNotFound = "Item introuvable"
    }


{-| Resolve full use consumption processes linked to their respective ids
-}
expandConsumptions : List Process -> List Consumption -> Result String (List ( Amount, Process ))
expandConsumptions processes =
    List.map
        (\{ amount, processId } ->
            processes
                |> Process.findById processId
                |> Result.map (\process -> ( amount, process ))
        )
        >> RE.combine


{-| Turn an Element to an ExpandedElement
-}
expandElement : DataContainer db -> Element -> Result String ExpandedElement
expandElement ({ countries, processes } as db) { amount, material, transforms } =
    Ok (ExpandedElement amount)
        |> RE.andMap
            (Ok (\country process -> { country = country, process = process })
                |> RE.andMap (Country.resolveMaybe material.country countries)
                |> RE.andMap (Process.findById material.id processes)
            )
        |> RE.andMap (expandTransforms db transforms)


{-| Take a list of elements and resolve them with fully qualified processes
-}
expandElements : DataContainer db -> List Element -> Result String (List ExpandedElement)
expandElements db =
    RE.combineMap (expandElement db)


expandItem : DataContainer db -> Item -> Result String ExpandedItem
expandItem db { custom, id, quantity } =
    case id of
        Just id_ ->
            db.components
                |> findById id_
                |> Result.andThen (expandExistingItem db custom quantity)

        Nothing ->
            expandNewItem db custom quantity


expandExistingItem : DataContainer db -> Maybe Custom -> Quantity -> Component -> Result String ExpandedItem
expandExistingItem db custom quantity component =
    custom
        |> customElements component
        |> expandElements db
        |> Result.map
            (\expandedElements ->
                { component = custom |> componentFromCustom (Just component)
                , elements = expandedElements
                , quantity = quantity
                }
            )


expandNewItem : DataContainer db -> Maybe Custom -> Quantity -> Result String ExpandedItem
expandNewItem db custom quantity =
    let
        newComponent =
            custom |> componentFromCustom Nothing
    in
    Ok ExpandedItem
        |> RE.andMap (Ok newComponent)
        |> RE.andMap
            (custom
                |> customElements newComponent
                |> expandElements db
            )
        |> RE.andMap (Ok quantity)


{-| Take a list of component items and resolve them with actual components and processes
-}
expandItems : DataContainer a -> List Item -> Result String (List ExpandedItem)
expandItems db =
    List.map (expandItem db) >> RE.combine


{-| Turn a list of localized processes into expanded localized processes
-}
expandTransforms : DataContainer db -> List LocalizedProcess -> Result String (List ExpandedLocalizedProcess)
expandTransforms { countries, processes } =
    List.map
        (\{ country, id } ->
            Ok ExpandedLocalizedProcess
                |> RE.andMap (Country.resolveMaybe country countries)
                |> RE.andMap (Process.findById id processes)
        )
        >> RE.combine


extractAmount : Results -> Amount
extractAmount (Results { amount }) =
    amount


extractComplementsImpacts : Results -> ComplementsResultsImpacts
extractComplementsImpacts (Results { complementsImpacts }) =
    complementsImpacts


extractImpacts : Results -> Impacts
extractImpacts (Results { impacts }) =
    impacts


extractItems : Results -> List Results
extractItems (Results { items }) =
    items


extractMass : Results -> Mass
extractMass (Results { mass }) =
    mass


extractStage : Results -> Maybe Stage
extractStage (Results { stage }) =
    stage


{-| Lookup a Component from a provided Id
-}
findById : Id -> List Component -> Result String Component
findById id =
    List.filter (.id >> (==) (Just id))
        >> List.head
        >> Result.fromMaybe ("Aucun composant avec id=" ++ idToString id)


getAvailableDistributionProcesses : DataContainer db -> Scope -> List Process
getAvailableDistributionProcesses db scope =
    db.processes
        |> Scope.anyOf [ scope ]
        |> Process.listByCategory Category.Distribution
        |> List.filter (.unit >> (==) Process.CubicMeter)


{-| Retrieves a distribution process for a given scope from a provided distribution id, or a default
process from config if available.
-}
getDistributionProcess : Requirements db -> Maybe Process.Id -> Result DistributionProcessError Process
getDistributionProcess { config, db, scope } maybeDistribution =
    case maybeDistribution of
        Just processId ->
            getAvailableDistributionProcesses db scope
                |> Process.findById processId
                |> Result.mapError DistributionGenericError

        -- No distribution process specified, use the default scoped process if available
        Nothing ->
            config.distribution.defaultProcess
                |> Scope.dictGetMaybe scope
                |> Result.fromMaybe DistributionNothingAvailable


{-| Get an element's results at a given location in the results tree.
-}
getElementResult : ( Index, Index ) -> Results -> Result String Results
getElementResult ( itemIndex, elementIndex ) productionResults =
    extractItems productionResults
        |> LE.getAt itemIndex
        |> Result.fromMaybe errors.itemNotFound
        |> Result.andThen (extractItems >> LE.getAt elementIndex >> Result.fromMaybe errors.elementNotFound)


getEndOfLifeDetailedImpacts : Requirements db -> Bool -> Results -> DetailedEndOfLifeImpacts
getEndOfLifeDetailedImpacts { config, scope } recyclable =
    let
        collectionRatio =
            scope |> getEndOfLifeScopeCollectionRate config recyclable

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


getEndOfLifeImpacts : Requirements db -> Bool -> Results -> Impacts
getEndOfLifeImpacts ({ config, scope } as requirements) recyclable (Results results) =
    if config.endOfLife |> Config.scopeEnabled scope then
        Results results
            |> getEndOfLifeDetailedImpacts requirements recyclable
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

    else
        Impact.empty


getEndOfLifeScopeCollectionRate : Config -> Bool -> Scope -> Split
getEndOfLifeScopeCollectionRate { endOfLife } recyclable scope =
    if recyclable then
        endOfLife.scopeCollectionRates
            |> AnyDict.get scope
            -- Assume every material is fully collected by default
            |> Maybe.withDefault Split.full

    else
        Split.zero


{-| Get an element's country last transform if any, or the country of its material otherwise.
-}
getFinalElementCountry : ExpandedElement -> Maybe Country
getFinalElementCountry { material, transforms } =
    LE.last transforms
        |> Maybe.map .country
        |> Maybe.withDefault material.country


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


{-| Get the an expanded element and its results at a given location in the elements tree.
-}
getResultedElement : ( Index, Index ) -> Results -> List ExpandedItem -> Result String ResultedElement
getResultedElement ( itemIndex, elementIndex ) productionResults expandedItems =
    Result.map2 Tuple.pair
        -- Expanded element
        (expandedItems
            |> LE.getAt itemIndex
            |> Result.fromMaybe errors.itemNotFound
            |> Result.andThen (.elements >> LE.getAt elementIndex >> Result.fromMaybe errors.elementNotFound)
        )
        -- Element results
        (getElementResult ( itemIndex, elementIndex ) productionResults)


{-| Create a list of expanded elements with their associated results from a list of items and production results.
-}
getResultedElementList : Results -> List ExpandedItem -> Result String (List ResultedElement)
getResultedElementList productionResults =
    List.indexedMap
        (\itemIndex expandedItem ->
            expandedItem.elements
                |> List.indexedMap
                    (\elementIndex expandedElement ->
                        productionResults
                            |> getElementResult ( itemIndex, elementIndex )
                            |> Result.map (\results -> ( expandedElement, results ))
                    )
        )
        >> List.concat
        >> RE.combine


getTotalImpacts : Results -> Impacts
getTotalImpacts (Results { impacts, complementsImpacts }) =
    Impact.sumImpacts
        [ impacts
        , complementsImpacts |> Complement.mergeComplementsResultsImpacts
        ]


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
    case component.id of
        Just _ ->
            List.any identity
                [ custom.elements /= component.elements
                , custom.name /= Nothing && custom.name /= Just component.name
                , custom.scope /= Nothing && custom.scope /= Just component.scope
                ]

        -- New component are always customized
        Nothing ->
            True


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
    case id of
        Just id_ ->
            findById id_ components
                |> Result.map (\component -> custom |> componentFromCustom (Just component))

        Nothing ->
            custom |> componentFromCustom Nothing |> Ok


emptyComponent : Component
emptyComponent =
    { comment = Nothing
    , elements = []
    , id = Nothing
    , name = ""
    , published = False
    , scope = Scope.Generic Scope.Object
    }


itemToString : DataContainer db -> Item -> Result String String
itemToString db { custom, id, quantity } =
    let
        toString component =
            custom
                |> customElements component
                |> RE.combineMap (elementToString db.processes)
                |> Result.map (String.join " | ")
                |> Result.map
                    (\processesString ->
                        String.fromInt (quantityToInt quantity)
                            ++ " "
                            ++ (custom |> componentFromCustom (Just component) |> .name)
                            ++ " [ "
                            ++ processesString
                            ++ " ]"
                    )
    in
    case id of
        Just id_ ->
            findById id_ db.components
                |> Result.andThen toString

        Nothing ->
            custom
                |> componentFromCustom Nothing
                |> toString


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


mapItems : (List Item -> List Item) -> Query -> Query
mapItems fn query =
    setQueryItems (fn query.items) query


nonLocalizedExpandedProcess : Process -> ExpandedLocalizedProcess
nonLocalizedExpandedProcess process =
    { country = Nothing, process = process }


nonLocalizedProcess : Process.Id -> LocalizedProcess
nonLocalizedProcess id =
    { country = Nothing, id = id }


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        decodeBase64Query
            >> Result.toMaybe
            >> Just


{-| Proxified for convenience
-}
parseConfig : DataContainer db -> String -> Result String Config
parseConfig =
    Config.parse


quantityFromInt : Int -> Quantity
quantityFromInt int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int


removeConsumption : Index -> Query -> Query
removeConsumption index query =
    { query | consumptions = query.consumptions |> LE.removeAt index }


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


setElementMaterial : DataContainer db -> TargetElement -> Process -> List Item -> Result String (List Item)
setElementMaterial db targetElement material items =
    if not <| List.member Category.Material material.categories then
        Err "Seuls les procédés de catégorie `material` sont mobilisables comme matière"

    else
        items
            |> updateElement targetElement
                (\el ->
                    let
                        materialType =
                            List.head (Process.getMaterialTypes material)
                    in
                    { el
                      -- preserve initial material country
                        | material = { country = el.material.country, id = material.id }

                        -- preserve compatible transforms
                        , transforms =
                            el.transforms
                                |> List.map
                                    (\localizedProcess ->
                                        db.processes
                                            |> Process.findById localizedProcess.id
                                            |> Result.map (\fullProcess -> ( localizedProcess, fullProcess ))
                                    )
                                |> RE.combine
                                |> Result.map
                                    (List.filter
                                        (\( _, transform ) ->
                                            materialType /= Nothing && List.head (Process.getMaterialTypes transform) == materialType
                                        )
                                    )
                                |> Result.map (List.map Tuple.first)
                                |> Result.withDefault []
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


setTransportByAir : Split -> Query -> Query
setTransportByAir byAir ({ transportOptions } as query) =
    { query | transportOptions = { transportOptions | byAir = byAir } }


setTransportCooling : Bool -> Query -> Query
setTransportCooling cooling ({ transportOptions } as query) =
    { query | transportOptions = { transportOptions | cooling = cooling } }


stagesImpacts : LifeCycle -> Stages (Maybe Impacts)
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
                        { acc | materials = acc.materials |> Maybe.map (\i -> Impact.sumImpacts [ i, impacts ]) }

                    Just TransformStage ->
                        { acc | transform = acc.transform |> Maybe.map (\i -> Impact.sumImpacts [ i, impacts ]) }

                    Just TransportStage ->
                        { acc | transports = acc.transports |> Maybe.map (\i -> Impact.sumImpacts [ i, impacts ]) }

                    Nothing ->
                        acc
            )
            { distribution = lifeCycle.distribution.impacts |> Just
            , endOfLife = lifeCycle.endOfLife |> Just
            , materials = Just Impact.empty
            , packaging = Just lifeCycle.packaging
            , transform = Just Impact.empty
            , transports = getTotalTransportImpacts lifeCycle.transports |> Just
            , trims = Nothing
            , usage = lifeCycle.use |> Impact.sumImpacts |> Just
            }


stageToString : Stage -> String
stageToString stage =
    case stage of
        MaterialStage ->
            "material"

        TransformStage ->
            "transformation"

        TransportStage ->
            "transport"


sumLifeCycleImpacts : LifeCycle -> Impacts
sumLifeCycleImpacts lifeCycle =
    Impact.sumImpacts
        [ extractImpacts lifeCycle.production
        , extractComplementsImpacts lifeCycle.production |> Complement.mergeComplementsResultsImpacts
        , lifeCycle.distribution.impacts
        , lifeCycle.endOfLife
        , lifeCycle.packaging
        , lifeCycle.transports.toAssembly.impacts
        , lifeCycle.transports.toDistribution.impacts
        , lifeCycle.use |> Impact.sumImpacts
        ]


targetElementToString : TargetElement -> String
targetElementToString ( ( _, index ), elementIndex ) =
    String.join "-" [ String.fromInt index, String.fromInt elementIndex ]


toSearchableString : DataContainer db -> Component -> String
toSearchableString db component =
    String.join " "
        [ component.id |> Maybe.map idToString |> Maybe.withDefault ""
        , component.name
        , component.comment |> Maybe.withDefault ""
        , component |> elementsToString db |> Result.withDefault ""
        ]


transformListToString : List ExpandedLocalizedProcess -> String
transformListToString =
    List.map
        (\{ country, process } ->
            Process.getDisplayName process
                ++ (case country of
                        Just { name } ->
                            " (" ++ name ++ ")"

                        Nothing ->
                            ""
                   )
        )
        >> String.join ", "


{-| Update a list of component items that may fail
-}
tryMapItems : (List Item -> Result String (List Item)) -> Query -> Result String Query
tryMapItems fn query =
    fn query.items
        |> Result.map (\items -> setQueryItems items query)


updateConsumptionAmount : Index -> Amount -> Query -> Query
updateConsumptionAmount index amount query =
    { query
        | consumptions =
            query.consumptions
                |> LE.updateAt index (\uc -> { uc | amount = amount })
    }


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


updateDistribution : Maybe Process.Id -> Query -> Query
updateDistribution maybeProcessId query =
    { query | distribution = maybeProcessId }


updateDurability : Unit.Ratio -> Query -> Query
updateDurability durability query =
    { query
        | durability =
            if durability == defaultDurability then
                Nothing

            else
                Just durability
    }


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


updateElementMaterialCountry : TargetElement -> Maybe Country.Code -> List Item -> List Item
updateElementMaterialCountry targetElement maybeCountryCode =
    updateElement targetElement <|
        \({ material } as el) -> { el | material = { material | country = maybeCountryCode } }


updateElementTransformCountry : TargetElement -> Index -> Maybe Country.Code -> List Item -> List Item
updateElementTransformCountry targetElement transformIndex maybeCountryCode =
    updateElement targetElement <|
        \el ->
            { el
                | transforms =
                    el.transforms
                        |> LE.updateAt transformIndex (\step -> { step | country = maybeCountryCode })
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


updateRecyclable : Bool -> Query -> Query
updateRecyclable recyclable query =
    { query | recyclable = recyclable }


validateConsumption : Requirements db -> Consumption -> Result String Consumption
validateConsumption requirements consumption =
    Ok Consumption
        |> RE.andMap (Amount.validate consumption.amount)
        |> RE.andMap (validateProcessId requirements consumption.processId)


validateCountry : Requirements db -> Maybe Country.Code -> Result String (Maybe Country.Code)
validateCountry { db, scope } maybeCountryCode =
    case maybeCountryCode of
        Just countryCode ->
            countryCode
                |> Country.validateForScope scope db.countries
                |> Result.map Just

        Nothing ->
            Ok Nothing


validateDistribution : Requirements db -> Maybe Process.Id -> Result String (Maybe Process.Id)
validateDistribution { db, scope } maybeProcessId =
    case maybeProcessId of
        Just processId ->
            case Process.findById processId db.processes of
                Err err ->
                    Err err

                Ok process ->
                    if not <| List.member Category.Distribution process.categories then
                        Err "Le procédé n'est pas une distribution"

                    else if process.unit /= Process.CubicMeter then
                        Err "Le procédé de distribution doit accepter un volume"

                    else if not <| List.member scope process.scopes then
                        Err <| "Le procédé " ++ Process.idToString processId ++ " n'est pas disponible pour le périmètre " ++ Scope.toLabel scope

                    else
                        Ok (Just processId)

        Nothing ->
            Ok Nothing


validateDurability : Requirements db -> Maybe Unit.Ratio -> Result String (Maybe Unit.Ratio)
validateDurability { config, scope } durability =
    case ( config.durability |> Config.scopeEnabled scope, durability ) of
        ( False, Just _ ) ->
            Err <| "La durabilité n'est pas activée pour le périmètre " ++ Scope.toLabel scope

        _ ->
            Ok durability


validateItem : List Component -> Item -> Result String Item
validateItem components item =
    if quantityToInt item.quantity < 1 then
        Err "La quantité doit être un nombre entier positif"

    else
        case item.id of
            Just id ->
                case findById id components of
                    Err err ->
                        Err err

                    Ok _ ->
                        -- component exists
                        Ok item

            Nothing ->
                -- component is being created
                Ok item


validatePackaging : Requirements db -> Packaging -> Result String Packaging
validatePackaging requirements (Packaging quantifiedProcess) =
    quantifiedProcess
        |> validateQuantifiedProcess requirements
        |> Result.map Packaging


validateProcessId : Requirements db -> Process.Id -> Result String Process.Id
validateProcessId { db, scope } processId =
    db.processes
        |> Scope.anyOf [ scope ]
        |> Process.findById processId
        |> Result.map .id
        |> Result.mapError
            (always <|
                "Aucun procédé scopé "
                    ++ Scope.toLabel scope
                    ++ " avec cet id: "
                    ++ Process.idToString processId
            )


validateQuantifiedProcess : Requirements db -> QuantifiedProcess -> Result String QuantifiedProcess
validateQuantifiedProcess requirements quantifiedProcess =
    Ok QuantifiedProcess
        |> RE.andMap (Amount.validate quantifiedProcess.amount)
        |> RE.andMap (validateProcessId requirements quantifiedProcess.processId)


validateQuery : Requirements db -> Query -> Result String Query
validateQuery ({ db } as requirements) query =
    Ok Query
        |> RE.andMap (validateCountry requirements query.assemblyCountry)
        |> RE.andMap (query.consumptions |> RE.combineMap (validateConsumption requirements))
        |> RE.andMap (validateDistribution requirements query.distribution)
        |> RE.andMap (validateDurability requirements query.durability)
        |> RE.andMap (query.items |> RE.combineMap (validateItem db.components))
        |> RE.andMap (query.packagings |> RE.combineMap (validatePackaging requirements))
        |> RE.andMap (Ok query.recyclable)
        |> RE.andMap (Ok query.transportOptions)
        |> Result.mapError (\s -> "Requête invalide\u{202F}: " ++ s)
