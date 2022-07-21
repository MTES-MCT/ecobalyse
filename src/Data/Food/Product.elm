module Data.Food.Product exposing
    ( Amount
    , ImpactsForProcesses
    , Process
    , ProcessName
    , Product
    , ProductName
    , Products
    , RawCookedRatioInfo
    , Step
    , addIngredient
    , computePefImpact
    , decodeProcesses
    , decodeProducts
    , defaultCountry
    , emptyImpactsForProcesses
    , emptyProducts
    , filterIngredients
    , findProductByName
    , getRawCookedRatioInfo
    , getTotalImpact
    , getTotalWeight
    , isIngredient
    , isProcessing
    , isTransport
    , isWaste
    , processNameToString
    , productNameToString
    , removeIngredient
    , stringToProductName
    , unusedDuration
    , updateAmount
    , updateTransport
    )

import Codec
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
import Result.Extra as RE
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



---- Process


type alias Amount =
    Float


type ProcessName
    = ProcessName String


stringToProcessName : String -> ProcessName
stringToProcessName str =
    ProcessName str


processNameToString : ProcessName -> String
processNameToString (ProcessName name) =
    name


isProcessing : ProcessName -> Bool
isProcessing (ProcessName processName) =
    List.any (\name -> String.startsWith name processName)
        [ "Cooking"
        , "Canning"
        , "Mixing"
        , "Peeling"
        , "Fish filleting"
        , "Slaughtering"
        ]


isWaste : ProcessName -> Bool
isWaste (ProcessName processName) =
    String.startsWith "Biowaste " processName


isTransport : ProcessName -> Bool
isTransport (ProcessName processName) =
    String.startsWith "Transport, " processName


isIngredient : ProcessName -> Bool
isIngredient processName =
    (isProcessing processName
        || isWaste processName
        || isTransport processName
    )
        |> not


type alias Process =
    { amount : Amount
    , impacts : Impacts
    }


type alias ImpactsForProcesses =
    AnyDict String ProcessName Impacts


emptyImpactsForProcesses : ImpactsForProcesses
emptyImpactsForProcesses =
    AnyDict.empty processNameToString


type alias Processes =
    AnyDict String ProcessName Process


emptyProcesses : Processes
emptyProcesses =
    AnyDict.empty processNameToString


insertProcess : ProcessName -> Process -> Processes -> Processes
insertProcess name process processes =
    AnyDict.insert name process processes


computeProcessPefImpact : List Definition -> Processes -> Processes
computeProcessPefImpact definitions processes =
    processes
        |> AnyDict.map
            (\_ process ->
                { process
                    | impacts =
                        Impact.updatePefImpact definitions process.impacts
                }
            )


findImpactsByName : ProcessName -> ImpactsForProcesses -> Result String Impacts
findImpactsByName ((ProcessName name) as procName) =
    AnyDict.get procName
        >> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


decodeProcesses : List Definition -> Decoder ImpactsForProcesses
decodeProcesses definitions =
    Codec.decoder (Impact.impactsCodec definitions)
        |> AnyDict.decode (\str _ -> ProcessName str) processNameToString



---- Step


type alias Step =
    { ingredients : Processes
    , transport : Processes
    , waste : Processes
    , processing : Processes
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


emptyStep : Step
emptyStep =
    { ingredients = emptyProcesses
    , transport = emptyProcesses
    , waste = emptyProcesses
    , processing = emptyProcesses
    }


type alias Ingredient =
    ( ProcessName, Amount )


type alias ProductDefinition =
    { consumer : List Ingredient
    , supermarket : List Ingredient
    , distribution : List Ingredient
    , packaging : List Ingredient
    , plant : List Ingredient
    }


type alias RawCookedRatioInfo =
    { weightLossProcessName : ProcessName
    , rawCookedRatio : Unit.Ratio
    }


type ProcessCategory
    = Processing
    | Waste
    | Transport
    | Ingredient


kindOf : ProcessName -> ProcessCategory
kindOf processName =
    if isProcessing processName then
        Processing

    else if isWaste processName then
        Waste

    else if isTransport processName then
        Transport

    else
        Ingredient


insertProcessToStep : ProcessName -> Amount -> Impacts -> Step -> Step
insertProcessToStep processName amount impacts step =
    let
        newProcess =
            Process amount impacts
    in
    case kindOf processName of
        Processing ->
            { step | processing = insertProcess processName newProcess step.processing }

        Waste ->
            { step | waste = insertProcess processName newProcess step.waste }

        Transport ->
            { step | transport = insertProcess processName newProcess step.transport }

        Ingredient ->
            { step | ingredients = insertProcess processName newProcess step.ingredients }


stepFromIngredients : List Ingredient -> ImpactsForProcesses -> Result String Step
stepFromIngredients ingredients impactsForProcesses =
    ingredients
        |> List.foldl
            (\( processName, amount ) stepResult ->
                let
                    impactsResult : Result String Impacts
                    impactsResult =
                        findImpactsByName processName impactsForProcesses
                in
                Result.map2 (insertProcessToStep processName amount) impactsResult stepResult
            )
            (Ok emptyStep)


productFromDefinition : ImpactsForProcesses -> ProductDefinition -> Result String Product
productFromDefinition impactsForProcesses { consumer, supermarket, distribution, packaging, plant } =
    Ok Product
        |> RE.andMap (stepFromIngredients consumer impactsForProcesses)
        |> RE.andMap (stepFromIngredients supermarket impactsForProcesses)
        |> RE.andMap (stepFromIngredients distribution impactsForProcesses)
        |> RE.andMap (stepFromIngredients packaging impactsForProcesses)
        |> RE.andMap (stepFromIngredients plant impactsForProcesses)


computePefImpact : List Definition -> Product -> Product
computePefImpact definitions product =
    { product | plant = computeStepPefImpact definitions product.plant }


computeStepPefImpact : List Definition -> Step -> Step
computeStepPefImpact definitions step =
    { step
        | ingredients = computeProcessPefImpact definitions step.ingredients
        , transport = computeProcessPefImpact definitions step.transport
        , waste = computeProcessPefImpact definitions step.waste
        , processing = computeProcessPefImpact definitions step.processing
    }


updateProcess : ProcessName -> (Process -> Process) -> Processes -> Processes
updateProcess processName updateFunc process =
    process
        |> AnyDict.update processName
            (Maybe.map updateFunc)


updateStep : (Processes -> Processes) -> Step -> Step
updateStep updateFunc step =
    { step
        | ingredients = updateFunc step.ingredients
        , transport = updateFunc step.transport
        , waste = updateFunc step.waste
        , processing = updateFunc step.processing
    }


updateAmount : Maybe RawCookedRatioInfo -> ProcessName -> Amount -> Step -> Step
updateAmount maybeRawCookedRatioInfo processName newAmount step =
    step
        |> updateStep (updateProcess processName (\process -> { process | amount = newAmount }))
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
                (updateProcess weightLossProcessName (\process -> { process | amount = updatedWeight }))
                step


findProductByName : ProductName -> Products -> Result String Product
findProductByName ((ProductName name) as productName) =
    AnyDict.get productName
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


decodeAmount : Decoder Amount
decodeAmount =
    Decode.float


decodeIngredients : Decoder (List Ingredient)
decodeIngredients =
    AnyDict.decode (\str _ -> stringToProcessName str) processNameToString decodeAmount
        |> Decode.map AnyDict.toList


decodeProductDefinition : Decoder ProductDefinition
decodeProductDefinition =
    Decode.succeed ProductDefinition
        |> Pipe.required "consumer" decodeIngredients
        |> Pipe.required "supermarket" decodeIngredients
        |> Pipe.required "distribution" decodeIngredients
        |> Pipe.required "packaging" decodeIngredients
        |> Pipe.required "plant" decodeIngredients


insertProduct : ProductName -> Product -> Products -> Products
insertProduct productName product products =
    AnyDict.insert productName product products


productsFromDefinitions : ImpactsForProcesses -> AnyDict String ProductName ProductDefinition -> Result String Products
productsFromDefinitions impactsForProcesses definitions =
    definitions
        |> AnyDict.foldl
            (\productName productDefinition productsResult ->
                let
                    productResult : Result String Product
                    productResult =
                        productFromDefinition impactsForProcesses productDefinition
                in
                Result.map2 (insertProduct productName) productResult productsResult
            )
            (Ok (AnyDict.empty productNameToString))


decodeProducts : ImpactsForProcesses -> Decoder Products
decodeProducts impactsForProcesses =
    AnyDict.decode (\str _ -> ProductName str) productNameToString decodeProductDefinition
        |> Decode.andThen
            (\definitions ->
                definitions
                    |> productsFromDefinitions impactsForProcesses
                    |> (\result ->
                            case result of
                                Ok products ->
                                    Decode.succeed products

                                Err error ->
                                    Decode.fail error
                       )
            )



-- utilities


stepToProcesses : Step -> Processes
stepToProcesses step =
    -- We can use AnyDict.union here because we should never have keys clashing between dicts
    step.ingredients
        |> AnyDict.union step.transport
        |> AnyDict.union step.waste
        |> AnyDict.union step.processing


getTotalImpact : Trigram -> Step -> Float
getTotalImpact trigram step =
    step
        |> stepToProcesses
        |> AnyDict.foldl
            (\_ process total ->
                let
                    impact =
                        grabImpactFloat unusedFunctionalUnit unusedDuration trigram process
                in
                total + (process.amount * impact)
            )
            0


getTotalWeight : Step -> Float
getTotalWeight step =
    step
        |> stepToProcesses
        |> AnyDict.foldl
            (\processName { amount } total ->
                if isIngredient processName then
                    total + amount

                else
                    total
            )
            0


getRawCookedRatioInfo : Product -> Maybe RawCookedRatioInfo
getRawCookedRatioInfo product =
    -- TODO: HACK, we assume that the process "at plant" that is the heavier is the total
    -- "final" weight, versus the total weight of the raw ingredients. We only need this
    -- if there's some kind of process that "looses weight" in the process, and we assume this
    -- process should be named ".... / FR U" (eg "Cooking, industrial, 1kg of cooked product/ FR U")
    let
        maybeProcessName =
            getWeightLosingUnitProcessName product.plant

        totalIngredientsWeight =
            getTotalWeight product.plant
    in
    maybeProcessName
        |> Maybe.andThen
            (\processName ->
                product.plant
                    |> stepToProcesses
                    |> AnyDict.get processName
                    |> Maybe.map
                        (\process ->
                            { weightLossProcessName = processName
                            , rawCookedRatio =
                                (process.amount / totalIngredientsWeight)
                                    |> Unit.Ratio
                            }
                        )
            )


getWeightLosingUnitProcessName : Step -> Maybe ProcessName
getWeightLosingUnitProcessName step =
    step
        |> stepToProcesses
        |> AnyDict.toList
        -- Only keep processes with names ending with "/ FR U"
        |> List.filter (Tuple.first >> isProcessing)
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount)
        |> List.reverse
        -- Only keep the process names
        |> List.map Tuple.first
        -- Take the heaviest
        |> List.head


filterIngredients : Products -> List String
filterIngredients products =
    products
        |> AnyDict.values
        |> List.concatMap (.plant >> stepToProcesses >> AnyDict.keys)
        |> List.filter isIngredient
        |> List.map processNameToString
        |> Set.fromList
        |> Set.toList
        |> List.sort


addIngredient : Maybe RawCookedRatioInfo -> ImpactsForProcesses -> String -> Product -> Result String Product
addIngredient maybeRawCookedRatioInfo impactsForProcesses ingredientName ({ plant } as product) =
    let
        processName =
            stringToProcessName ingredientName
    in
    findImpactsByName processName impactsForProcesses
        |> Result.map
            (\impacts ->
                let
                    amount =
                        1.0

                    withAddedIngredient =
                        { plant
                            | ingredients = AnyDict.insert processName (Process amount impacts) plant.ingredients
                        }
                            -- Update the total weight
                            |> updateWeight maybeRawCookedRatioInfo
                in
                { product | plant = withAddedIngredient }
            )


removeIngredient : Maybe RawCookedRatioInfo -> ProcessName -> Product -> Product
removeIngredient maybeRawCookedRatioInfo processName ({ plant } as product) =
    let
        withRemovedIngredient =
            { plant
                | ingredients = AnyDict.filter (\name _ -> name /= processName) plant.ingredients
            }
                -- Update the total weight
                |> updateWeight maybeRawCookedRatioInfo
    in
    { product
        | plant = withRemovedIngredient
    }


updateTransport : Processes -> ImpactsForProcesses -> List Impact.Definition -> Country.Code -> Distances -> Product -> Product
updateTransport defaultTransport impactsForProcesses impactDefinitions countryCode distances ({ plant } as product) =
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

        findImpacts name =
            impactsForProcesses
                |> findImpactsByName name
                |> Result.withDefault Impact.noImpacts

        transports =
            [ ( lorryTransportName, .road )
            , ( boatTransportName, .sea )
            , ( planeTransportName, .air )
            ]
                |> List.map
                    (\( name, prop ) ->
                        ( name
                        , findImpacts name
                            |> Process (toTonKm (prop transportWithRatio))
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
