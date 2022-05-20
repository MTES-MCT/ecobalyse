module Data.Ecobalyse.Product exposing
    ( Product
    , ProductDefinition
    , ProductName
    , Products
    , Step
    , decodeProductDefinition
    , decodeProducts
    , empty
    , findByName
    , productFromDefinition
    , updateAmount
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


insertIngredient : ProcessName -> Amount -> Impacts -> Step -> Step
insertIngredient processName amount impacts step =
    Dict.insert processName (Process amount impacts) step


stepFromProcesses : List Ingredient -> Processes -> Result String Step
stepFromProcesses ingredients processes =
    ingredients
        |> List.foldl
            (\( processName, amount ) stepResult ->
                let
                    impactsResult : Result String Impacts
                    impactsResult =
                        Process.findByName processName processes
                in
                Result.map2 (insertIngredient processName amount) impactsResult stepResult
            )
            (Ok Dict.empty)


productFromDefinition : Processes -> ProductDefinition -> Result String Product
productFromDefinition processes { consumer, supermarket, distribution, packaging, plant } =
    Ok Product
        |> RE.andMap (stepFromProcesses consumer processes)
        |> RE.andMap (stepFromProcesses supermarket processes)
        |> RE.andMap (stepFromProcesses distribution processes)
        |> RE.andMap (stepFromProcesses packaging processes)
        |> RE.andMap (stepFromProcesses plant processes)


updateAmount : ProcessName -> Amount -> Step -> Step
updateAmount processName newAmount step =
    step
        |> Dict.update processName
            (Maybe.map
                (\process ->
                    { process | amount = newAmount }
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


decodeProducts : Processes -> Decoder Products
decodeProducts processes =
    loggingDecoder
        (Decode.dict decodeProductDefinition
            |> Decode.andThen
                (\dict ->
                    dict
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
                        |> (\result ->
                                case result of
                                    Ok products ->
                                        Decode.succeed products

                                    Err error ->
                                        Decode.fail error
                           )
                )
        )


loggingDecoder : Decoder a -> Decoder a
loggingDecoder realDecoder =
    Decode.value
        |> Decode.andThen
            (\value ->
                case Decode.decodeValue realDecoder value of
                    Ok decoded ->
                        Decode.succeed decoded

                    Err error ->
                        error
                            |> Decode.errorToString
                            |> Debug.log "decode error"
                            |> Decode.fail
            )
