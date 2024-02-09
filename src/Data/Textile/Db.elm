module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    , updateImpactDefinitions
    )

import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process, WellKnown)
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { impactDefinitions : Definitions
    , processes : List Process
    , countries : List Country
    , materials : List Material
    , products : List Product
    , transports : Distances
    , wellKnown : WellKnown
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decode json
        |> Result.mapError Decode.errorToString


decode : Decoder Db
decode =
    Decode.field "impacts" Definition.decode
        |> Decode.andThen
            (\definitions ->
                Decode.field "processes" (Process.decodeList definitions)
                    |> Decode.andThen
                        (\processes ->
                            Decode.map4 (Db definitions processes)
                                (Decode.field "countries" (Country.decodeList processes))
                                (Decode.field "materials" (Material.decodeList processes))
                                (Decode.field "products" (Product.decodeList processes))
                                (Decode.field "transports" Transport.decodeDistances)
                                |> Decode.andThen
                                    (\partiallyLoaded ->
                                        Process.loadWellKnown processes
                                            |> Result.map partiallyLoaded
                                            |> DE.fromResult
                                    )
                        )
            )


{-| Update database with new definitions and recompute processes aggregated impacts accordingly.
-}
updateImpactDefinitions : Definitions -> Db -> Db
updateImpactDefinitions definitions db =
    let
        updatedProcesses =
            db.processes
                |> updateProcessesFromNewDefinitions definitions
    in
    { db
        | impactDefinitions = definitions
        , processes = updatedProcesses
        , countries = db.countries |> updateCountriesFromNewProcesses updatedProcesses
        , materials = db.materials |> updateMaterialsFromNewProcesses updatedProcesses
        , products = db.products |> updateProductsFromNewProcesses updatedProcesses
        , wellKnown = db.wellKnown |> updateWellKnownFromNewProcesses updatedProcesses
    }


{-| Update processes with new impact definitions, ensuring recomputing aggregated impacts.
-}
updateProcessesFromNewDefinitions : Definitions -> List Process -> List Process
updateProcessesFromNewDefinitions definitions =
    List.map
        (\({ impacts } as process) ->
            { process
                | impacts =
                    impacts
                        |> Impact.updateAggregatedScores definitions
            }
        )


updateCountriesFromNewProcesses : List Process -> List Country -> List Country
updateCountriesFromNewProcesses processes =
    List.map
        (\country ->
            Result.map2
                (\electricityProcess heatProcess ->
                    { country
                        | electricityProcess = electricityProcess
                        , heatProcess = heatProcess
                    }
                )
                (Process.findByUuid country.electricityProcess.uuid processes)
                (Process.findByUuid country.heatProcess.uuid processes)
                |> Result.withDefault country
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


updateWellKnownFromNewProcesses : List Process -> WellKnown -> WellKnown
updateWellKnownFromNewProcesses processes =
    Process.mapWellKnown
        (\({ uuid } as process) ->
            processes
                |> Process.findByUuid uuid
                |> Result.withDefault process
        )
