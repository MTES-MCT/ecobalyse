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
import Json.Decode.Extra as DE
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
    { name : ProcessName
    , impacts : Impacts
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
    { name = stringToProcessName "empty process"
    , impacts = Impact.noImpacts
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
        |> Pipe.hardcoded (stringToProcessName "to be defined")
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
        |> Decode.map
            (AnyDict.map
                (\processName process ->
                    { process | name = processName }
                )
            )


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
    , comment : String
    , process : Process
    }


type alias Ingredients =
    List Ingredient


emptyIngredients : Ingredients
emptyIngredients =
    []


updateIngredientAmount : Amount -> Ingredient -> Ingredient
updateIngredientAmount amount ingredient =
    { ingredient | amount = amount }


updateIngredient : Ingredient -> (Ingredient -> Ingredient) -> Ingredients -> Ingredients
updateIngredient ingredientToUpdate updateFunc ingredients =
    ingredients
        |> List.map
            (\ingredient ->
                if ingredient == ingredientToUpdate then
                    updateFunc ingredient

                else
                    ingredient
            )


computeIngredientPefImpact : List Definition -> Ingredients -> Ingredients
computeIngredientPefImpact definitions ingredients =
    ingredients
        |> List.map
            (\({ process } as ingredient) ->
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
    { weightLossProcess : Ingredient
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


updateAmount : Maybe RawCookedRatioInfo -> Ingredient -> Amount -> Step -> Step
updateAmount maybeRawCookedRatioInfo ingredient newAmount step =
    step
        |> updateStep (updateIngredient ingredient (updateIngredientAmount newAmount))
        |> updateWeight maybeRawCookedRatioInfo


updateWeight : Maybe RawCookedRatioInfo -> Step -> Step
updateWeight maybeRawCookedRatioInfo step =
    case maybeRawCookedRatioInfo of
        Nothing ->
            step

        Just { weightLossProcess, rawCookedRatio } ->
            let
                updatedRawWeight =
                    getTotalWeight step

                updatedWeight =
                    rawCookedRatio
                        |> Unit.ratioToFloat
                        |> (*) updatedRawWeight
            in
            updateStep
                (updateIngredient weightLossProcess (updateIngredientAmount updatedWeight))
                step


findProductByName : ProductName -> Products -> Result String Product
findProductByName ((ProductName name) as productName) =
    AnyDict.get productName
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


decodeAmount : Decoder Amount
decodeAmount =
    Decode.float


linkProcess : Processes -> Decoder Process
linkProcess processes =
    Decode.string
        |> Decode.andThen
            (\name ->
                name
                    |> stringToProcessName
                    |> (\processName -> findProcessByName processName processes)
                    |> DE.fromResult
            )


decodeIngredient : Processes -> Decoder Ingredient
decodeIngredient processes =
    Decode.succeed Ingredient
        |> Pipe.required "amount" decodeAmount
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "processName" (linkProcess processes)


decodeCategory : Processes -> Decoder Ingredients
decodeCategory processes =
    Decode.list (decodeIngredient processes)


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
    -- Return a "flat" list of ingredients
    [ .transport, .wasteTreatment, .energy, .processing, .material ]
        |> List.concatMap (\accessor -> accessor step)


getTotalImpact : Trigram -> Step -> Float
getTotalImpact trigram step =
    step
        |> stepToIngredients
        |> List.foldl
            (\ingredient total ->
                let
                    impact =
                        grabImpactFloat unusedFunctionalUnit unusedDuration trigram ingredient.process
                in
                total + (ingredient.amount * impact)
            )
            0


getTotalWeight : Step -> Float
getTotalWeight step =
    let
        totalWeight =
            step.material
                |> List.foldl
                    (\{ amount } total ->
                        total + amount
                    )
                    0
    in
    if totalWeight == 0 then
        -- There may be no materials (for some products, there's only a processing step)
        -- in which case fall back to taking the "heaviest" processing step
        getWeightLosingUnitProcess step
            |> Maybe.map .amount
            |> Maybe.withDefault 0

    else
        totalWeight


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
            (\({ amount } as ingredient) ->
                { weightLossProcess = ingredient
                , rawCookedRatio =
                    (amount / totalIngredientsWeight)
                        |> Unit.Ratio
                }
            )


getWeightLosingUnitProcess : Step -> Maybe Ingredient
getWeightLosingUnitProcess step =
    step.processing
        -- Sort by heavier to lighter
        |> List.sortBy .amount
        |> List.reverse
        -- Take the heaviest
        |> List.head


listIngredients : Products -> List String
listIngredients products =
    -- List all the "material" entries from the "at plant" step
    products
        |> AnyDict.values
        |> List.concatMap (.plant >> .material >> List.map (.process >> .name))
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
                            | material = Ingredient amount "" process :: plant.material
                        }
                            -- Update the total weight
                            |> updateWeight maybeRawCookedRatioInfo
                in
                { product | plant = withAddedIngredient }
            )


removeMaterial : Maybe RawCookedRatioInfo -> Ingredient -> Product -> Product
removeMaterial maybeRawCookedRatioInfo ingredientToRemove ({ plant } as product) =
    let
        withRemovedIngredient =
            { plant
                | material = List.filter (\ingredient -> ingredient /= ingredientToRemove) plant.material
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
                        findProcess name
                            |> Ingredient (toTonKm (prop transportWithRatio)) ""
                    )
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
