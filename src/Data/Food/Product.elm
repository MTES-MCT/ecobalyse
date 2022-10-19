module Data.Food.Product exposing
    ( Item
    , Items
    , Product
    , ProductName
    , Products
    , Step
    , addIngredient
    , decodeProducts
    , defaultCountry
    , emptyProducts
    , filterItemByCategory
    , findByName
    , getAmountRatio
    , getItemsImpact
    , getStepTransports
    , getTotalImpact
    , getWeightAtPlant
    , listIngredients
    , listProcessingProcesses
    , nameFromString
    , nameToString
    , removeIngredient
    , updateIngredientMass
    , updatePlantTransport
    )

import Data.Country as Country
import Data.Food.Amount as Amount exposing (Amount)
import Data.Food.Process as Process exposing (Process, ProcessName)
import Data.Impact as Impact
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Distances)
import Data.Unit as Unit
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Length exposing (Length)
import List.Extra as LE
import Mass exposing (Mass)
import Quantity


defaultCountry : Country.Code
defaultCountry =
    Country.codeFromString "FR"


{-| Item
An item is one entry from one category (transport, material, processing...)
from one step (consumer, packaging, plant...)
from one product from public/data/products.json
It links a Process to an amount for this process (quantity of a vegetable, transport distance, ...)
-}
type alias Item =
    { amount : Amount
    , comment : String
    , process : Process
    }


type alias MainItem =
    { mass : Mass
    , comment : String
    , processName : ProcessName
    }


type alias Items =
    -- TODO : remove this type alias
    List Item


filterItemByCategory : Process.Category -> Items -> Items
filterItemByCategory category =
    List.filter (.process >> .category >> (==) category)


excludeItemByCategory : Process.Category -> Items -> Items
excludeItemByCategory category =
    List.filter (.process >> .category >> (/=) category)


{-| Step
A step (at consumer, at plant...) has several categories (material, transport...) containing several items
A Product is composed of several steps.
-}
type alias Step =
    { mainItem : MainItem
    , items : Items
    }


type alias Product =
    { consumer : Step
    , supermarket : Step
    , distribution : Step
    , packaging : Step
    , plant : Items
    }


type ProductName
    = ProductName String


nameToString : ProductName -> String
nameToString (ProductName name) =
    name


nameFromString : String -> ProductName
nameFromString str =
    ProductName str


type alias Products =
    AnyDict String ProductName Product


emptyProducts : Products
emptyProducts =
    AnyDict.empty nameToString


findByName : ProductName -> Products -> Result String Product
findByName ((ProductName name) as productName) =
    AnyDict.get productName
        >> Result.fromMaybe ("Produit introuvable par nom : " ++ name)


linkProcess : AnyDict String ProcessName Process -> Decoder Process
linkProcess processes =
    Decode.string
        |> Decode.andThen
            (Process.nameFromString
                >> (\processName ->
                        AnyDict.get processName processes
                            |> Result.fromMaybe ("Procédé introuvable par nom : " ++ Process.nameToString processName)
                   )
                >> DE.fromResult
            )


type alias TempItem =
    { amount : Float
    , comment : String
    , process : Process
    }


decodeItem : AnyDict String ProcessName Process -> Decoder Item
decodeItem processes =
    Decode.succeed TempItem
        |> Pipe.required "amount" Decode.float
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "processName" (linkProcess processes)
        |> Decode.andThen
            (\{ amount, comment, process } ->
                Amount.fromUnitAndFloat process.unit amount
                    |> Result.map
                        (\res ->
                            { amount = res
                            , comment = comment
                            , process = process
                            }
                        )
                    |> DE.fromResult
            )


decodeMainItem : Decoder MainItem
decodeMainItem =
    Decode.succeed MainItem
        |> Pipe.required "amount" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "processName" (Decode.map Process.nameFromString Decode.string)


decodeItems : AnyDict String ProcessName Process -> Decoder Items
decodeItems processes =
    Decode.list (decodeItem processes)


decodeStep : AnyDict String ProcessName Process -> Decoder Step
decodeStep processes =
    Decode.succeed Step
        |> Pipe.required "mainItem" decodeMainItem
        |> Pipe.required "items" (decodeItems processes)


decodeProduct : AnyDict String ProcessName Process -> Decoder Product
decodeProduct processes =
    Decode.succeed Product
        |> Pipe.required "consumer" (decodeStep processes)
        |> Pipe.required "supermarket" (decodeStep processes)
        |> Pipe.required "distribution" (decodeStep processes)
        |> Pipe.required "packaging" (decodeStep processes)
        |> Pipe.requiredAt [ "plant", "items" ] (decodeItems processes)


decodeProducts : List Process -> Decoder Products
decodeProducts processes =
    let
        processesDict =
            processes
                |> List.map (\process -> ( process.name, process ))
                |> AnyDict.fromList Process.nameToString
    in
    AnyDict.decode (\str _ -> ProductName str) nameToString (decodeProduct processesDict)



-- utilities


getItemsImpact : Impact.Trigram -> Items -> Float
getItemsImpact trigram items =
    items
        |> List.foldl
            (\item total ->
                let
                    impact =
                        Impact.getImpact trigram item.process.impacts
                            |> Unit.impactToFloat
                in
                total + (Amount.toStandardFloat item.amount * impact)
            )
            0


getTotalImpact : Impact.Trigram -> Product -> Float
getTotalImpact trigram product =
    getItemsImpact trigram product.consumer.items
        + getItemsImpact trigram product.supermarket.items
        + getItemsImpact trigram product.distribution.items
        + getItemsImpact trigram product.packaging.items
        + getItemsImpact trigram product.plant


transportModes : Dict String String
transportModes =
    -- Transport processes, categorized by mode (road, sea, air, train)
    Dict.fromList
        [ ( "Transport, freight, inland waterways, barge {RER}| processing | Cut-off, S - Copied from Ecoinvent", "sea" )
        , ( "Transport, freight, inland waterways, barge with reefer, cooling {GLO}| processing | Cut-off, S - Copied from Ecoinvent", "sea" )
        , ( "Transport, freight, lorry 16-32 metric ton, euro6 {RER}| market for transport, freight, lorry 16-32 metric ton, EURO6 | Cut-off, S - Copied from Ecoinvent", "road" )
        , ( "Transport, freight, lorry >32 metric ton, EURO4 {RER}| transport, freight, lorry >32 metric ton, EURO4 | Cut-off, S - Copied from Ecoinvent", "road" )
        , ( "Transport, freight, lorry 16-32 metric ton, EURO4 {RER}| transport, freight, lorry 16-32 metric ton, EURO4 | Cut-off, S - Copied from Ecoinvent", "road" )
        , ( "Transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling {GLO}| transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling | Cut-off, S - Copied from Ecoinvent", "road" )
        , ( "Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent", "road" )
        , ( "Transport, freight train {RER}| market group for transport, freight train | Cut-off, S - Copied from Ecoinvent", "rail" )
        , ( "Transport, freight, sea, transoceanic ship {GLO}| processing | Cut-off, S - Copied from Ecoinvent", "sea" )
        , ( "Transport, freight, sea, transoceanic ship {GLO}| market for | Cut-off, S - Copied from Ecoinvent", "sea" )
        , ( "Transport, freight, sea, transoceanic ship with reefer, cooling {GLO}| processing | Cut-off, S - Copied from Ecoinvent", "sea" )
        , ( "Transport, freight, aircraft {RER}| intercontinental | Cut-off, S - Copied from Ecoinvent", "air" )
        ]


getStepTransports : Step -> { air : Length, rail : Length, road : Length, sea : Length }
getStepTransports step =
    step.items
        |> filterItemByCategory Process.Transport
        |> List.foldl
            (\{ amount, process } acc ->
                case amount of
                    Amount.TonKilometer tonkm ->
                        let
                            distanceToAdd =
                                Amount.tonKilometerToKilometer step.mainItem.mass tonkm
                        in
                        case Dict.get (Process.nameToString process.name) transportModes of
                            Just "air" ->
                                { acc | air = acc.air |> Quantity.plus distanceToAdd }

                            Just "rail" ->
                                { acc | rail = acc.rail |> Quantity.plus distanceToAdd }

                            Just "road" ->
                                { acc | road = acc.road |> Quantity.plus distanceToAdd }

                            Just "sea" ->
                                { acc | sea = acc.sea |> Quantity.plus distanceToAdd }

                            _ ->
                                acc

                    _ ->
                        acc
            )
            { air = Quantity.zero
            , rail = Quantity.zero
            , road = Quantity.zero
            , sea = Quantity.zero
            }


getWeightAtPlant : Items -> Mass
getWeightAtPlant items =
    -- At plant we don't really have a main item that we could use for the weight, so instead
    -- sum the weight of all the materials.
    items
        |> filterItemByCategory Process.Ingredient
        -- FIXME: if there are no ingredients, take the weight of the processing or the main item at packaging
        |> List.map .amount
        |> List.map Amount.getMass
        |> Quantity.sum


listProcesses : (Product -> Items) -> Products -> List Process
listProcesses getStepItems products =
    products
        |> AnyDict.values
        |> List.concatMap (getStepItems >> List.map .process)
        |> LE.uniqueBy (.name >> Process.nameToString)
        |> List.sortBy (.name >> Process.nameToString)


listIngredients : Products -> List Process
listIngredients =
    -- List all the "material" entries from the "at plant" step
    listProcesses (.plant >> filterItemByCategory Process.Material)


listProcessingProcesses : Products -> List Process
listProcessingProcesses =
    -- List all the "processing" entries from the "at plant" step
    listProcesses (.plant >> filterItemByCategory Process.Processing)


addIngredient : Process -> Mass -> Product -> Product
addIngredient process mass ({ plant } as product) =
    let
        newItem =
            { amount = Amount.Mass mass
            , comment = ""
            , process = process
            }

        withAddedItem =
            newItem :: plant

        originalWeight =
            getWeightAtPlant plant
    in
    { product | plant = withAddedItem }
        |> updateProductAmounts originalWeight


updateIngredientMass : Item -> Mass -> Product -> Product
updateIngredientMass itemToUpdate mass ({ plant } as product) =
    let
        originalWeight =
            getWeightAtPlant plant
    in
    { product
        | plant =
            plant
                |> List.map
                    (\item ->
                        if item == itemToUpdate then
                            { item | amount = Amount.Mass mass }

                        else
                            item
                    )
    }
        |> updateProductAmounts originalWeight


removeIngredient : Item -> Product -> Product
removeIngredient itemToRemove ({ plant } as product) =
    let
        originalWeight =
            getWeightAtPlant plant
    in
    { product
        | plant = List.filter (\item -> item /= itemToRemove) plant
    }
        |> updateProductAmounts originalWeight


getAmountRatio : Mass -> Product -> Float
getAmountRatio originalWeight currentProduct =
    let
        updatedWeight =
            getWeightAtPlant currentProduct.plant
    in
    -- We need the new "ratio" between the original product and the updated one,
    -- to change the amount for all the other processes (but the plant materials).
    Quantity.ratio updatedWeight originalWeight


updateProductAmounts : Mass -> Product -> Product
updateProductAmounts originalWeight ({ consumer, supermarket, distribution, packaging, plant } as product) =
    let
        amountRatio =
            getAmountRatio originalWeight product
    in
    { product
        | consumer = updateStepAmounts amountRatio consumer
        , supermarket = updateStepAmounts amountRatio supermarket
        , distribution = updateStepAmounts amountRatio distribution
        , packaging = updateStepAmounts amountRatio packaging
        , plant = updatePlantAmounts amountRatio plant
    }


updateStepAmounts : Float -> Step -> Step
updateStepAmounts amountRatio ({ items } as step) =
    { step
        | items = updateItemsAmounts amountRatio items
    }


{-| updatePlantAmounts is specific to the plant where we don't want to automatically update the materials
as they are customised by the user.
-}
updatePlantAmounts : Float -> Items -> Items
updatePlantAmounts amountRatio items =
    let
        ingredientOrMaterial =
            filterItemByCategory Process.Material items
                ++ filterItemByCategory Process.Ingredient items
    in
    items
        |> List.map
            (\item ->
                -- We DON'T update the ingredient and material amounts, they are customised by the user
                if List.member item ingredientOrMaterial then
                    item

                else
                    { item | amount = Amount.multiplyBy amountRatio item.amount }
            )


updateItemsAmounts : Float -> Items -> Items
updateItemsAmounts amountRatio items =
    items
        |> List.map
            (\item ->
                { item | amount = Amount.multiplyBy amountRatio item.amount }
            )


updatePlantTransport : Product -> List Process -> List Impact.Definition -> Country.Code -> Distances -> Product -> Product
updatePlantTransport originalProduct processes impactDefinitions countryCode distances ({ plant } as product) =
    let
        defaultTransport =
            originalProduct.plant
                |> filterItemByCategory Process.Transport

        originalPlantWeight =
            getWeightAtPlant originalProduct.plant

        plantWeight =
            getWeightAtPlant product.plant

        amountRatio =
            Quantity.ratio plantWeight originalPlantWeight

        impacts =
            Impact.impactsFromDefinitons impactDefinitions

        transport =
            distances
                |> Transport.getTransportBetween impacts countryCode defaultCountry

        transportWithRatio =
            transport
                -- We want the transport ratio for the plane to be 0 for food (for now)
                -- Cf https://fabrique-numerique.gitbook.io/ecobalyse/textile/transport#part-du-transport-aerien
                |> Formula.transportRatio (Unit.Ratio 0)

        transports =
            Process.loadWellKnown processes
                |> Result.map
                    (\wellKnown ->
                        [ ( wellKnown.lorryTransport, transportWithRatio.road )
                        , ( wellKnown.boatTransport, transportWithRatio.sea )
                        , ( wellKnown.planeTransport, transportWithRatio.air )
                        ]
                            |> List.map
                                (\( process, distance ) ->
                                    { amount = Amount.kilometerToTonKilometer distance plantWeight |> Amount.Mass
                                    , comment = ""
                                    , process = process
                                    }
                                )
                    )
                |> Result.withDefault []

        updatedTransports =
            (if countryCode == defaultCountry then
                defaultTransport

             else
                transports
            )
                |> -- If we changed the recipe, we don't want the default transports, we want the default transports
                   -- with the updated amounts corresponding to the new recipe weight
                   updateItemsAmounts amountRatio
    in
    { product
        | plant =
            plant
                |> excludeItemByCategory Process.Transport
                |> (++) updatedTransports
    }
