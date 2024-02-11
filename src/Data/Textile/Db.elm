module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    , updateMaterialsFromNewProcesses
    , updateProductsFromNewProcesses
    , updateWellKnownFromNewProcesses
    )

import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process, WellKnown)
import Data.Textile.Product as Product exposing (Product)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { processes : List Process
    , materials : List Material
    , products : List Product
    , wellKnown : WellKnown
    }


buildFromJson : Definitions -> String -> Result String Db
buildFromJson definitions json =
    Decode.decodeString (decode definitions) json
        |> Result.mapError Decode.errorToString


decode : Definitions -> Decoder Db
decode definitions =
    Decode.field "processes" (Process.decodeList definitions)
        |> Decode.andThen
            (\processes ->
                Decode.map2 (Db processes)
                    (Decode.field "materials" (Material.decodeList processes))
                    (Decode.field "products" (Product.decodeList processes))
                    |> Decode.andThen
                        (\partiallyLoaded ->
                            Process.loadWellKnown processes
                                |> Result.map partiallyLoaded
                                |> DE.fromResult
                        )
            )


updateWellKnownFromNewProcesses : List Process -> WellKnown -> WellKnown
updateWellKnownFromNewProcesses processes =
    Process.mapWellKnown
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
