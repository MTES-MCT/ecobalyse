module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    , updateMaterialsFromNewProcesses
    , updateProductsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Textile.ExampleProduct as TextileExampleProduct exposing (ExampleProduct)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode


type alias Db =
    { processes : List Process
    , exampleProducts : List ExampleProduct
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> String -> Result String Db
buildFromJson exampleProductsJson materialsJson productsJson processesJson =
    processesJson
        |> Decode.decodeString Process.decodeList
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Result.map4 (Db processes)
                    (TextileExampleProduct.decodeListFromJsonString exampleProductsJson)
                    (Decode.decodeString (Material.decodeList processes) materialsJson |> Result.mapError Decode.errorToString)
                    (Decode.decodeString (Product.decodeList processes) productsJson |> Result.mapError Decode.errorToString)
                    (WellKnown.load processes)
            )


updateWellKnownFromNewProcesses : List Process -> WellKnown -> WellKnown
updateWellKnownFromNewProcesses processes =
    WellKnown.map
        (\({ uuid } as process) ->
            processes
                |> Process.findByUuid uuid
                |> Result.withDefault process
        )


updateMaterialsFromNewProcesses : List Process -> List Material -> List Material
updateMaterialsFromNewProcesses processes =
    List.map
        (\material ->
            Result.map2
                (\materialProcess maybeRecycledProcess ->
                    { material
                        | materialProcess = materialProcess
                        , recycledProcess = maybeRecycledProcess
                    }
                )
                (Process.findByUuid material.materialProcess.uuid processes)
                (material.recycledProcess
                    |> Maybe.map (\{ uuid } -> processes |> Process.findByUuid uuid |> Result.map Just)
                    |> Maybe.withDefault (Ok Nothing)
                )
                |> Result.withDefault material
        )


updateProductsFromNewProcesses : List Process -> List Product -> List Product
updateProductsFromNewProcesses processes =
    List.map
        (\({ use } as product) ->
            Result.map2
                (\ironingProcess nonIroningProcess ->
                    { product
                        | use =
                            { use
                                | ironingProcess = ironingProcess
                                , nonIroningProcess = nonIroningProcess
                            }
                    }
                )
                (Process.findByUuid product.use.ironingProcess.uuid processes)
                (Process.findByUuid product.use.nonIroningProcess.uuid processes)
                |> Result.withDefault product
        )
