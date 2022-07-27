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
    , addMaterial
    , computePefImpact
    , decodeProcesses
    , decodeProducts
    , defaultCountry
    , emptyImpactsForProcesses
    , emptyProducts
    , findProductByName
    , getRawCookedRatioInfo
    , getTotalImpact
    , getTotalWeight
    , isTransport
    , isWaste
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


isWaste : ProcessName -> Bool
isWaste (ProcessName processName) =
    String.startsWith "Biowaste " processName


isTransport : ProcessName -> Bool
isTransport (ProcessName processName) =
    String.startsWith "Transport, " processName


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
    Decode.field "impacts" (Impact.decodeImpacts definitions)
        |> AnyDict.decode (\str _ -> ProcessName str) processNameToString



---- Step


type alias Step =
    { material : Processes
    , transport : Processes
    , wasteTreatment : Processes
    , energy : Processes
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
        | material = computeProcessPefImpact definitions step.material
        , transport = computeProcessPefImpact definitions step.transport
        , wasteTreatment = computeProcessPefImpact definitions step.wasteTreatment
        , energy = computeProcessPefImpact definitions step.energy
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
        | material = updateFunc step.material
        , transport = updateFunc step.transport
        , wasteTreatment = updateFunc step.wasteTreatment
        , energy = updateFunc step.energy
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


decodeCategory : ImpactsForProcesses -> Decoder Processes
decodeCategory impactsForProcesses =
    AnyDict.decode (\str _ -> stringToProcessName str) processNameToString decodeAmount
        |> Decode.andThen
            (\dict ->
                let
                    processesResult =
                        addImpactsToProcesses impactsForProcesses dict
                in
                case processesResult of
                    Ok processes ->
                        Decode.succeed processes

                    Err error ->
                        Decode.fail error
            )


addImpactsToProcesses : ImpactsForProcesses -> AnyDict String ProcessName Float -> Result String Processes
addImpactsToProcesses impactsForProcesses dict =
    dict
        |> AnyDict.foldl
            (\processName amount processesResult ->
                let
                    processResult =
                        findImpactsByName processName impactsForProcesses
                            |> Result.map (Process amount)
                in
                Result.map2
                    (AnyDict.insert processName)
                    processResult
                    processesResult
            )
            (Ok (AnyDict.empty processNameToString))


decodeStep : ImpactsForProcesses -> Decoder Step
decodeStep impactsForProcesses =
    Decode.succeed Step
        |> Pipe.optional "material" (decodeCategory impactsForProcesses) emptyProcesses
        |> Pipe.optional "transport" (decodeCategory impactsForProcesses) emptyProcesses
        |> Pipe.optional "waste treatment" (decodeCategory impactsForProcesses) emptyProcesses
        |> Pipe.optional "energy" (decodeCategory impactsForProcesses) emptyProcesses
        |> Pipe.optional "processing" (decodeCategory impactsForProcesses) emptyProcesses


decodeProduct : ImpactsForProcesses -> Decoder Product
decodeProduct impactsForProcesses =
    Decode.succeed Product
        |> Pipe.required "consumer" (decodeStep impactsForProcesses)
        |> Pipe.required "supermarket" (decodeStep impactsForProcesses)
        |> Pipe.required "distribution" (decodeStep impactsForProcesses)
        |> Pipe.required "packaging" (decodeStep impactsForProcesses)
        |> Pipe.required "plant" (decodeStep impactsForProcesses)


decodeProducts : ImpactsForProcesses -> Decoder Products
decodeProducts impactsForProcesses =
    AnyDict.decode (\str _ -> ProductName str) productNameToString (decodeProduct impactsForProcesses)



-- utilities


stepToProcesses : Step -> Processes
stepToProcesses step =
    -- We can use AnyDict.union here because we should never have keys clashing between dicts
    step.material
        |> AnyDict.union step.transport
        |> AnyDict.union step.wasteTreatment
        |> AnyDict.union step.energy
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
    step.processing
        |> AnyDict.toList
        -- Sort by heavier to lighter
        |> List.sortBy (Tuple.second >> .amount)
        |> List.reverse
        -- Only keep the process names
        |> List.map Tuple.first
        -- Take the heaviest
        |> List.head


listIngredients : Products -> List String
listIngredients products =
    products
        |> AnyDict.values
        |> List.concatMap (.plant >> .material >> AnyDict.keys)
        |> List.map processNameToString
        |> Set.fromList
        |> Set.toList
        |> List.sort


addMaterial : Maybe RawCookedRatioInfo -> ImpactsForProcesses -> String -> Product -> Result String Product
addMaterial maybeRawCookedRatioInfo impactsForProcesses ingredientName ({ plant } as product) =
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
                            | material = AnyDict.insert processName (Process amount impacts) plant.material
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
