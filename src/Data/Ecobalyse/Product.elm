module Data.Ecobalyse.Product exposing
    ( Product
    , ProductName
    , Products
    , WeightRatio
    , decodeProducts
    , empty
    , findByName
    , getTotalImpact
    , getTotalWeight
    , getWeightRatio
    , isUnit
    , updateAmount
    , updateWeight
    )

import Data.Ecobalyse.Process as Process
    exposing
        ( Amount
        , Impacts
        , Process
        , ProcessName
        , Processes
        )
import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Result.Extra as RE


type alias Step =
    Dict ProcessName Process


type alias Product =
    { consumer : Step
    , supermarket : Step
    , distribution : Step
    , packaging : Step
    , plant : Step
    }


type alias ProductName =
    String


type alias Products =
    Dict ProductName Product


empty : Products
empty =
    Dict.empty


type alias Ingredient =
    ( String, Unit.Ratio )


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
    Dict.insert processName (Process amount impacts) step


stepFromIngredients : List Ingredient -> Processes -> Result String Step
stepFromIngredients ingredients processes =
    ingredients
        |> List.foldl
            (\( processName, amount ) stepResult ->
                let
                    impactsResult : Result String Impacts
                    impactsResult =
                        Process.findByName processName processes
                in
                Result.map2 (insertProcess processName amount) impactsResult stepResult
            )
            (Ok Dict.empty)


productFromDefinition : Processes -> ProductDefinition -> Result String Product
productFromDefinition processes { consumer, supermarket, distribution, packaging, plant } =
    Ok Product
        |> RE.andMap (stepFromIngredients consumer processes)
        |> RE.andMap (stepFromIngredients supermarket processes)
        |> RE.andMap (stepFromIngredients distribution processes)
        |> RE.andMap (stepFromIngredients packaging processes)
        |> RE.andMap (stepFromIngredients plant processes)


updateAmount : Maybe WeightRatio -> ProcessName -> Amount -> Step -> Step
updateAmount maybeWeightRatio processName newAmount step =
    step
        |> Dict.update processName
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
                |> Dict.update processName
                    (Maybe.map
                        (\process ->
                            { process | amount = updatedWeight }
                        )
                    )


findByName : String -> Products -> Result String Product
findByName name =
    Dict.get name
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


decodeAmount : Decoder Amount
decodeAmount =
    Decode.float
        |> Decode.map Unit.ratio


decodeIngredients : Decoder (List Ingredient)
decodeIngredients =
    Decode.dict decodeAmount
        |> Decode.map Dict.toList


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
    Dict.insert productName product products


productsFromDefinitions : Processes -> Dict ProductName ProductDefinition -> Result String Products
productsFromDefinitions processes definitions =
    definitions
        |> Dict.foldl
            (\productName productDefinition productsResult ->
                let
                    productResult : Result String Product
                    productResult =
                        productFromDefinition processes productDefinition
                in
                Result.map2 (insertProduct productName) productResult productsResult
            )
            (Ok Dict.empty)


decodeProducts : Processes -> Decoder Products
decodeProducts processes =
    Decode.dict decodeProductDefinition
        |> Decode.andThen
            (\definitions ->
                definitions
                    |> productsFromDefinitions processes
                    |> (\result ->
                            case result of
                                Ok products ->
                                    Decode.succeed products

                                Err error ->
                                    Decode.fail error
                       )
            )



-- utilities


isUnit : ProcessName -> Bool
isUnit processName =
    String.endsWith "/ FR U" processName


getTotalImpact : Step -> Float
getTotalImpact step =
    step
        |> Dict.foldl
            (\_ { amount, impacts } total ->
                total + (Unit.ratioToFloat amount * impacts.cch)
            )
            0


getTotalWeight : Step -> Float
getTotalWeight step =
    step
        |> Dict.foldl
            (\processName { amount } total ->
                if isUnit processName then
                    total

                else
                    total + Unit.ratioToFloat amount
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
                    |> Dict.get processName
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
        |> Dict.toList
        -- Only keep processes ending with "/ FR U"
        |> List.filter (Tuple.first >> String.endsWith "/ FR U")
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount >> Unit.ratioToFloat)
        |> List.reverse
        -- Only keep the process names
        |> List.map Tuple.first
        -- Take the heaviest
        |> List.head
