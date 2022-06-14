module Data.Ecobalyse.Product exposing
    ( Product
    , ProductName
    , Products
    , WeightRatio
    , decodeProducts
    , empty
    , findByName
    , getImpact
    , getTotalImpact
    , getTotalWeight
    , getWeightRatio
    , productNameToString
    , stringToProductName
    , updateAmount
    )

import Data.Ecobalyse.Process as Process
    exposing
        ( Amount
        , Impacts
        , ImpactsForProcesses
        , Process
        , ProcessName
        , isUnit
        , processNameToString
        , stringToProcessName
        )
import Data.Impact as Impact
import Data.Unit as Unit
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Result.Extra as RE


type alias Step =
    AnyDict String ProcessName Process


trigramsToImpact : Dict String (Process.Impacts -> Float)
trigramsToImpact =
    Dict.fromList
        [ ( "acd", .acd )
        , ( "ozd", .ozd )
        , ( "cch", .cch )
        , ( "ccb", .ccb )
        , ( "ccf", .ccf )
        , ( "ccl", .ccl )
        , ( "fwe", .fwe )
        , ( "swe", .swe )
        , ( "tre", .tre )
        , ( "pco", .pco )
        , ( "pma", .pma )
        , ( "ior", .ior )
        , ( "fru", .fru )
        , ( "mru", .mru )
        , ( "ldu", .ldu )
        , ( "wtu", .wtu )
        , ( "etf", .etf )
        , ( "htc", .htc )
        , ( "htn", .htn )
        ]


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


empty : Products
empty =
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
                        Process.findByName processName impactsForProcesses
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


findByName : ProductName -> Products -> Result String Product
findByName ((ProductName name) as productName) =
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


getTotalImpact : Impact.Trigram -> List Impact.Definition -> Step -> Float
getTotalImpact trigram definitions step =
    step
        |> AnyDict.foldl
            (\_ { amount, impacts } total ->
                let
                    impact =
                        getImpact trigram definitions impacts
                in
                total + (Unit.ratioToFloat amount * impact)
            )
            0


getImpact : Impact.Trigram -> List Impact.Definition -> Process.Impacts -> Float
getImpact (Impact.Trigram trigram) definitions impacts =
    case Dict.get trigram trigramsToImpact of
        Just impactGetter ->
            impactGetter impacts

        Nothing ->
            if trigram == "pef" then
                -- PEF is a computed impact
                Dict.keys trigramsToImpact
                    -- Get all the impacts we have, and normalize/weigh them
                    |> List.map Impact.trg
                    |> List.map
                        (\trig ->
                            case Impact.getDefinition trig definitions of
                                Ok { pefData } ->
                                    case pefData of
                                        Just { normalization, weighting } ->
                                            getImpact trig definitions impacts
                                                |> Unit.impact
                                                |> Unit.impactPefScore normalization weighting
                                                |> Unit.impactToFloat

                                        Nothing ->
                                            0.0

                                Err _ ->
                                    0.0
                        )
                    |> List.foldl (+) 0.0

            else
                0.0


getTotalWeight : Step -> Float
getTotalWeight step =
    step
        |> AnyDict.foldl
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
        |> List.filter (Tuple.first >> isUnit)
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount >> Unit.ratioToFloat)
        |> List.reverse
        -- Only keep the process names
        |> List.map Tuple.first
        -- Take the heaviest
        |> List.head
