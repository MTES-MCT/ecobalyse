module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    , updateMaterialsFromNewProcesses
    , updateProductsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Example as Example exposing (Example)
import Data.Impact as Impact
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode


type alias Db =
    { processes : List Process
    , examples : List (Example Query)
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : String -> String -> String -> String -> Result String Db
buildFromJson exampleProductsJson materialsJson productsJson processesJson =
    processesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Result.map4 (Db processes)
                    (exampleProductsJson |> Example.decodeListFromJsonString Query.decode)
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
            processes
                |> Process.findByUuid product.use.nonIroningProcess.uuid
                |> Result.map (\p -> { product | use = { use | nonIroningProcess = p } })
                |> Result.withDefault product
        )
