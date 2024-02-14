module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    , updateMaterialsFromNewProcesses
    , updateProductsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Json.Decode as Decode exposing (Error(..))
import Json.Encode as Encode


type alias Db =
    { processes : List Process
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : Definitions -> String -> String -> String -> Result String Db
buildFromJson definitions materialsJson processesJson productsJson =
    Decode.decodeString (Process.decodeList definitions) processesJson
        |> Result.andThen
            (\processes ->
                Result.map3 (Db processes)
                    (Decode.decodeString (Material.decodeList processes) materialsJson)
                    (Decode.decodeString (Product.decodeList processes) productsJson)
                    (WellKnown.load processes
                        |> Result.mapError (\error -> Failure error (Encode.string processesJson))
                    )
            )
        |> Result.mapError Decode.errorToString


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
