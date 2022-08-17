module Data.Food.Product exposing
    ( Amount
    , Ingredient
    , Process
    , ProcessName
    , Processes
    , Product
    , ProductName
    , Products
    , RawCookedRatioInfo
    , Step
    , addMaterial
    , computePefImpact
    , decodeProcesses
    , decodeProducts
    , defaultCountry
    , emptyProcesses
    , emptyProducts
    , findProductByName
    , getRawCookedRatioInfo
    , getTotalImpact
    , getTotalWeight
    , listIngredients
    , processNameToString
    , productNameToString
    , removeMaterial
    , stringToProductName
    , unusedDuration
    , updateAmount
    , updateTransport
    )

import Data.Country as Country
import Data.Impact as Impact exposing (Definition, Impacts, Trigram, grabImpactFloat)
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Distances)
import Data.Unit as Unit
import Dict.Any as AnyDict exposing (AnyDict)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Length
import Set


unusedFunctionalUnit : Unit.Functional
unusedFunctionalUnit =
    Unit.PerItem


unusedDuration : Duration
unusedDuration =
    Duration.days 1


defaultCountry : Country.Code
defaultCountry =
    Country.codeFromString "FR"


lorryTransportName : ProcessName
lorryTransportName =
    ProcessName "Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent"


boatTransportName : ProcessName
boatTransportName =
    ProcessName "Transport, freight, sea, transoceanic ship {GLO}| processing | Cut-off, S - Copied from Ecoinvent"


planeTransportName : ProcessName
planeTransportName =
    ProcessName "Transport, freight, aircraft {RER}| intercontinental | Cut-off, S - Copied from Ecoinvent"


{-| Process
A process is an entry from public/data/food/processes.json. It has impacts and
various other data like categories, code, unit...
-}
type ProcessName
    = ProcessName String


stringToProcessName : String -> ProcessName
stringToProcessName str =
    ProcessName str


processNameToString : ProcessName -> String
processNameToString (ProcessName name) =
    name


type alias Process =
    { impacts : Impacts
    , ciqualCode : Maybe Int
    , step : Maybe String
    , dqr : Maybe Float
    , emptyProcess : Bool
    , unit : String
    , code : String
    , simaproCategory : String
    , systemDescription : String
    , categoryTags : List String
    }


emptyProcess : Process
emptyProcess =
    { impacts = Impact.noImpacts
    , ciqualCode = Nothing
    , step = Nothing
    , dqr = Nothing
    , emptyProcess = True
    , unit = ""
    , code = ""
    , simaproCategory = ""
    , systemDescription = ""
    , categoryTags = []
    }


type alias Processes =
    AnyDict String ProcessName Process


emptyProcesses : Processes
emptyProcesses =
    AnyDict.empty processNameToString


findProcessByName : ProcessName -> Processes -> Result String Process
findProcessByName ((ProcessName name) as procName) =
    AnyDict.get procName
        >> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


decodeProcess : List Definition -> Decoder Process
decodeProcess definitions =
    Decode.succeed Process
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)
        |> Pipe.required "ciqual_code" (Decode.nullable Decode.int)
        |> Pipe.required "step" (Decode.nullable Decode.string)
        |> Pipe.required "dqr" (Decode.nullable Decode.float)
        |> Pipe.required "empty_process" Decode.bool
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "code" Decode.string
        |> Pipe.required "simapro_category" Decode.string
        |> Pipe.required "system_description" Decode.string
        |> Pipe.required "category_tags" (Decode.list Decode.string)


decodeProcesses : List Definition -> Decoder Processes
decodeProcesses definitions =
    AnyDict.decode (\str _ -> ProcessName str) processNameToString (decodeProcess definitions)


{-| Ingredient
An ingredient is one entry from one category (transport, material, processing...)
from one step (consumer, packaging, plant...)
from one product from public/data/products.json
It links a Process to an amount for this process (quantity of a vegetable, transport distance, ...)
-}
type alias Amount =
    Float


type alias Ingredient =
    { amount : Amount
    , process : Process
    }


type alias Ingredients =
    AnyDict String ProcessName Ingredient


emptyIngredients : Ingredients
emptyIngredients =
    AnyDict.empty processNameToString


updateIngredientAmount : Amount -> Ingredient -> Ingredient
updateIngredientAmount amount ingredient =
    { ingredient | amount = amount }


updateIngredient : ProcessName -> (Ingredient -> Ingredient) -> Ingredients -> Ingredients
updateIngredient processName updateFunc ingredients =
    ingredients
        |> AnyDict.update processName (Maybe.map updateFunc)


computeIngredientPefImpact : List Definition -> Ingredients -> Ingredients
computeIngredientPefImpact definitions ingredients =
    ingredients
        |> AnyDict.map
            (\_ ({ process } as ingredient) ->
                { ingredient
                    | process =
                        { process
                            | impacts =
                                Impact.updatePefImpact definitions process.impacts
                        }
                }
            )


{-| Step
A step (at consumer, at plant...) has several categories (material, transport...) containing several ingredients
A Product is composed of several steps.
-}
type alias Step =
    { material : Ingredients
    , transport : Ingredients
    , wasteTreatment : Ingredients
    , energy : Ingredients
    , processing : Ingredients
    }


type alias Product =
    { consumer : Step
    , supermarket : Step
    , distribution : Step
    , packaging : Step
    , plant : Step
    }


type ProductName
    = ProductName String


productNameToString : ProductName -> String
productNameToString (ProductName name) =
    name


stringToProductName : String -> ProductName
stringToProductName str =
    ProductName str


type alias Products =
    AnyDict String ProductName Product


emptyProducts : Products
emptyProducts =
    AnyDict.empty productNameToString


type alias RawCookedRatioInfo =
    { weightLossProcessName : ProcessName
    , rawCookedRatio : Unit.Ratio
    }


computePefImpact : List Definition -> Product -> Product
computePefImpact definitions product =
    { product | plant = computeStepPefImpact definitions product.plant }


computeStepPefImpact : List Definition -> Step -> Step
computeStepPefImpact definitions step =
    { step
        | material = computeIngredientPefImpact definitions step.material
        , transport = computeIngredientPefImpact definitions step.transport
        , wasteTreatment = computeIngredientPefImpact definitions step.wasteTreatment
        , energy = computeIngredientPefImpact definitions step.energy
        , processing = computeIngredientPefImpact definitions step.processing
    }


updateStep : (Ingredients -> Ingredients) -> Step -> Step
updateStep updateFunc step =
    { step
        | material = updateFunc step.material
        , transport = updateFunc step.transport
        , wasteTreatment = updateFunc step.wasteTreatment
        , energy = updateFunc step.energy
        , processing = updateFunc step.processing
    }


updateAmount : Maybe RawCookedRatioInfo -> ProcessName -> Amount -> Step -> Step
updateAmount maybeRawCookedRatioInfo processName newAmount step =
    step
        |> updateStep (updateIngredient processName (updateIngredientAmount newAmount))
        |> updateWeight maybeRawCookedRatioInfo


updateWeight : Maybe RawCookedRatioInfo -> Step -> Step
updateWeight maybeRawCookedRatioInfo step =
    case maybeRawCookedRatioInfo of
        Nothing ->
            step

        Just { weightLossProcessName, rawCookedRatio } ->
            let
                updatedRawWeight =
                    getTotalWeight step

                updatedWeight =
                    rawCookedRatio
                        |> Unit.ratioToFloat
                        |> (*) updatedRawWeight
            in
            updateStep
                (updateIngredient weightLossProcessName (updateIngredientAmount updatedWeight))
                step


findProductByName : ProductName -> Products -> Result String Product
findProductByName ((ProductName name) as productName) =
    AnyDict.get productName
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


decodeAmount : Decoder Amount
decodeAmount =
    Decode.float


decodeCategory : Processes -> Decoder Ingredients
decodeCategory processes =
    AnyDict.decode (\str _ -> stringToProcessName str) processNameToString decodeAmount
        |> Decode.andThen
            (\dict ->
                let
                    ingredientsResult =
                        toIngredients processes dict
                in
                case ingredientsResult of
                    Ok ingredients ->
                        Decode.succeed ingredients

                    Err error ->
                        Decode.fail error
            )


toIngredients : Processes -> AnyDict String ProcessName Float -> Result String Ingredients
toIngredients processes dict =
    dict
        |> AnyDict.foldl
            (\processName amount processesResult ->
                let
                    processResult =
                        processes
                            |> findProcessByName processName
                            |> Result.map (Ingredient amount)
                in
                Result.map2
                    (AnyDict.insert processName)
                    processResult
                    processesResult
            )
            (Ok (AnyDict.empty processNameToString))


decodeStep : Processes -> Decoder Step
decodeStep processes =
    Decode.succeed Step
        |> Pipe.optional "material" (decodeCategory processes) emptyIngredients
        |> Pipe.optional "transport" (decodeCategory processes) emptyIngredients
        |> Pipe.optional "waste treatment" (decodeCategory processes) emptyIngredients
        |> Pipe.optional "energy" (decodeCategory processes) emptyIngredients
        |> Pipe.optional "processing" (decodeCategory processes) emptyIngredients


decodeProduct : Processes -> Decoder Product
decodeProduct processes =
    Decode.succeed Product
        |> Pipe.required "consumer" (decodeStep processes)
        |> Pipe.required "supermarket" (decodeStep processes)
        |> Pipe.required "distribution" (decodeStep processes)
        |> Pipe.required "packaging" (decodeStep processes)
        |> Pipe.required "plant" (decodeStep processes)


decodeProducts : Processes -> Decoder Products
decodeProducts processes =
    AnyDict.decode (\str _ -> ProductName str) productNameToString (decodeProduct processes)



-- utilities


stepToIngredients : Step -> Ingredients
stepToIngredients step =
    -- Return a "flat" dict of ingredients
    -- We can use AnyDict.union here because we should never have keys clashing between dicts
    step.material
        |> AnyDict.union step.transport
        |> AnyDict.union step.wasteTreatment
        |> AnyDict.union step.energy
        |> AnyDict.union step.processing


getTotalImpact : Trigram -> Step -> Float
getTotalImpact trigram step =
    step
        |> stepToIngredients
        |> AnyDict.foldl
            (\_ ingredient total ->
                let
                    impact =
                        grabImpactFloat unusedFunctionalUnit unusedDuration trigram ingredient.process
                in
                total + (ingredient.amount * impact)
            )
            0


getTotalWeight : Step -> Float
getTotalWeight step =
    step.material
        |> AnyDict.foldl
            (\_ { amount } total ->
                total + amount
            )
            0


getRawCookedRatioInfo : Product -> Maybe RawCookedRatioInfo
getRawCookedRatioInfo product =
    -- TODO: HACK, we assume that the process "at plant" that is the heavier is the total
    -- "final" weight, versus the total weight of the raw ingredients. We only need this
    -- if there's some kind of process that "looses weight" in the process, and we assume this
    -- process is in the "processing" category.
    let
        totalIngredientsWeight =
            getTotalWeight product.plant
    in
    getWeightLosingUnitProcess product.plant
        |> Maybe.map
            (\( processName, { amount } ) ->
                { weightLossProcessName = processName
                , rawCookedRatio =
                    (amount / totalIngredientsWeight)
                        |> Unit.Ratio
                }
            )


getWeightLosingUnitProcess : Step -> Maybe ( ProcessName, Ingredient )
getWeightLosingUnitProcess step =
    step.processing
        |> AnyDict.toList
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount)
        |> List.reverse
        -- Take the heaviest
        |> List.head


listIngredients : Products -> List String
listIngredients products =
    -- List all the "material" entries from the "at plant" step
    products
        |> AnyDict.values
        |> List.concatMap (.plant >> .material >> AnyDict.keys)
        |> List.map processNameToString
        |> Set.fromList
        |> Set.toList
        |> List.sort


addMaterial : Maybe RawCookedRatioInfo -> Processes -> String -> Product -> Result String Product
addMaterial maybeRawCookedRatioInfo processes ingredientName ({ plant } as product) =
    let
        processName =
            stringToProcessName ingredientName
    in
    findProcessByName processName processes
        |> Result.map
            (\process ->
                let
                    amount =
                        1.0

                    withAddedIngredient =
                        { plant
                            | material = AnyDict.insert processName (Ingredient amount process) plant.material
                        }
                            -- Update the total weight
                            |> updateWeight maybeRawCookedRatioInfo
                in
                { product | plant = withAddedIngredient }
            )


removeMaterial : Maybe RawCookedRatioInfo -> ProcessName -> Product -> Product
removeMaterial maybeRawCookedRatioInfo processName ({ plant } as product) =
    let
        withRemovedIngredient =
            { plant
                | material = AnyDict.filter (\name _ -> name /= processName) plant.material
            }
                -- Update the total weight
                |> updateWeight maybeRawCookedRatioInfo
    in
    { product
        | plant = withRemovedIngredient
    }


updateTransport : Ingredients -> Processes -> List Impact.Definition -> Country.Code -> Distances -> Product -> Product
updateTransport defaultTransport processes impactDefinitions countryCode distances ({ plant } as product) =
    let
        totalWeight =
            getTotalWeight plant

        impacts =
            Impact.impactsFromDefinitons impactDefinitions

        transport =
            distances
                |> Transport.getTransportBetween impacts countryCode defaultCountry

        transportWithRatio =
            transport
                |> Formula.transportRatio (Unit.Ratio 0.33)

        toTonKm km =
            Length.inKilometers km * totalWeight / 1000

        findProcess processName =
            processes
                |> AnyDict.get processName
                |> Maybe.withDefault emptyProcess

        transports =
            [ ( lorryTransportName, .road )
            , ( boatTransportName, .sea )
            , ( planeTransportName, .air )
            ]
                |> List.map
                    (\( name, prop ) ->
                        ( name
                        , findProcess name
                            |> Ingredient (toTonKm (prop transportWithRatio))
                        )
                    )
                |> AnyDict.fromList processNameToString
    in
    { product
        | plant =
            { plant
                | transport =
                    if countryCode == defaultCountry then
                        defaultTransport

                    else
                        transports
            }
    }
