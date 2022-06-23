module Data.Food.Product exposing
    ( Amount
    , ImpactsForProcesses
    , Process
    , ProcessName
    , Product
    , ProductName
    , Products
    , Step
    , WeightRatio
    , addIngredient
    , computePefImpact
    , decodeProcesses
    , decodeProducts
    , emptyImpactsForProcesses
    , emptyProducts
    , filterIngredients
    , findImpactsByName
    , findProductByName
    , getTotalImpact
    , getTotalWeight
    , getWeightRatio
    , isIngredient
    , isProcess
    , isTransport
    , isWaste
    , processNameToString
    , productNameToString
    , removeIngredient
    , stringToProcessName
    , stringToProductName
    , unusedDuration
    , updateAmount
    )

import Data.Impact as Impact exposing (Definition, Impacts, Trigram, grabImpactFloat)
import Data.Unit as Unit
import Dict.Any as AnyDict exposing (AnyDict)
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Result.Extra as RE
import Set


unusedFunctionalUnit : Unit.Functional
unusedFunctionalUnit =
    Unit.PerItem


unusedDuration : Duration
unusedDuration =
    Duration.days 1



---- Process


type alias Amount =
    Unit.Ratio


type ProcessName
    = ProcessName String


stringToProcessName : String -> ProcessName
stringToProcessName str =
    ProcessName str


processNameToString : ProcessName -> String
processNameToString (ProcessName name) =
    name


isProcess : ProcessName -> Bool
isProcess (ProcessName processName) =
    String.startsWith "Cooking, " processName
        || String.startsWith "Canning " processName
        || String.startsWith "Mixing, " processName
        || String.startsWith "Peeling, " processName
        || String.startsWith "Fish filleting, " processName
        || String.startsWith "Slaughtering" processName


isWaste : ProcessName -> Bool
isWaste (ProcessName processName) =
    String.startsWith "Biowaste " processName


isTransport : ProcessName -> Bool
isTransport (ProcessName processName) =
    String.startsWith "Transport, " processName


isIngredient : ProcessName -> Bool
isIngredient processName =
    (isProcess processName
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


computeProcessPefImpact : List Definition -> Process -> Process
computeProcessPefImpact definitions process =
    { process
        | impacts =
            Impact.updatePefImpact definitions process.impacts
    }


findImpactsByName : ProcessName -> ImpactsForProcesses -> Result String Impacts
findImpactsByName ((ProcessName name) as procName) =
    AnyDict.get procName
        >> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


decodeProcesses : List Definition -> Decoder ImpactsForProcesses
decodeProcesses definitions =
    AnyDict.decode (\str _ -> ProcessName str) processNameToString (Impact.decodeImpacts definitions)



---- Step


type alias Step =
    AnyDict String ProcessName Process


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


type alias Ingredient =
    ( ProcessName, Unit.Ratio )


type alias ProductDefinition =
    { consumer : List Ingredient
    , supermarket : List Ingredient
    , distribution : List Ingredient
    , packaging : List Ingredient
    , plant : List Ingredient
    }


type alias WeightRatio =
    { processName : ProcessName
    , weightRatio : Float
    }


insertProcess : ProcessName -> Amount -> Impacts -> Step -> Step
insertProcess processName amount impacts step =
    AnyDict.insert processName (Process amount impacts) step


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
                Result.map2 (insertProcess processName amount) impactsResult stepResult
            )
            (Ok (AnyDict.empty processNameToString))


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
    { product
        | plant =
            product.plant
                |> AnyDict.map
                    (\_ process ->
                        computeProcessPefImpact definitions process
                    )
    }


updateAmount : Maybe WeightRatio -> ProcessName -> Amount -> Step -> Step
updateAmount maybeWeightRatio processName newAmount step =
    step
        |> AnyDict.update processName
            (Maybe.map
                (\process ->
                    { process | amount = newAmount }
                )
            )
        |> updateWeight maybeWeightRatio


updateWeight : Maybe WeightRatio -> Step -> Step
updateWeight maybeWeightRatio step =
    case maybeWeightRatio of
        Nothing ->
            step

        Just { processName, weightRatio } ->
            let
                updatedRawWeight =
                    getTotalWeight step

                updatedWeight =
                    updatedRawWeight
                        * weightRatio
                        |> Unit.Ratio
            in
            step
                |> AnyDict.update processName
                    (Maybe.map
                        (\process ->
                            { process | amount = updatedWeight }
                        )
                    )


findProductByName : ProductName -> Products -> Result String Product
findProductByName ((ProductName name) as productName) =
    AnyDict.get productName
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


decodeAmount : Decoder Amount
decodeAmount =
    Decode.float
        |> Decode.map Unit.ratio


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


getTotalImpact : Trigram -> Step -> Float
getTotalImpact trigram step =
    step
        |> AnyDict.foldl
            (\_ process total ->
                let
                    impact =
                        grabImpactFloat unusedFunctionalUnit unusedDuration trigram process
                in
                total + (Unit.ratioToFloat process.amount * impact)
            )
            0


getTotalWeight : Step -> Float
getTotalWeight step =
    step
        |> AnyDict.foldl
            (\processName { amount } total ->
                if isIngredient processName then
                    total + Unit.ratioToFloat amount

                else
                    total
            )
            0


getWeightRatio : Product -> Maybe WeightRatio
getWeightRatio product =
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
                    |> AnyDict.get processName
                    |> Maybe.map
                        (\process ->
                            { processName = processName
                            , weightRatio =
                                Unit.ratioToFloat process.amount
                                    / totalIngredientsWeight
                            }
                        )
            )


getWeightLosingUnitProcessName : Step -> Maybe ProcessName
getWeightLosingUnitProcessName step =
    step
        |> AnyDict.toList
        -- Only keep processes with names ending with "/ FR U"
        |> List.filter (Tuple.first >> isProcess)
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount >> Unit.ratioToFloat)
        |> List.reverse
        -- Only keep the process names
        |> List.map Tuple.first
        -- Take the heaviest
        |> List.head


filterIngredients : Products -> List String
filterIngredients products =
    products
        |> AnyDict.values
        |> List.concatMap (.plant >> AnyDict.keys)
        |> List.filter isIngredient
        |> List.map processNameToString
        |> Set.fromList
        |> Set.toList
        |> List.sort


addIngredient : Maybe WeightRatio -> ImpactsForProcesses -> String -> Product -> Product
addIngredient maybeWeightRatio impactsForProcesses ingredientName product =
    let
        processName =
            stringToProcessName ingredientName
    in
    case findImpactsByName processName impactsForProcesses of
        Ok impacts ->
            let
                amount =
                    Unit.Ratio 1.0

                withAddedIngredient =
                    AnyDict.insert processName (Process amount impacts) product.plant
                        -- Update the total weight
                        |> updateAmount maybeWeightRatio processName amount
            in
            { product | plant = withAddedIngredient }

        Err _ ->
            product


removeIngredient : ProcessName -> Product -> Product
removeIngredient processName product =
    { product | plant = AnyDict.filter (\name _ -> name /= processName) product.plant }
