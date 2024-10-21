port module ComputeAggregated exposing (main)

import Data.Food.Process as FoodProcess
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Process as TextileProcess
import Data.Object.Process as ObjectProcess
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity


type alias Flags =
    { definitionsString : String
    , foodProcessesString : String
    , textileProcessesString : String
    , objectProcessesString : String
    }


decodeProcesses : Decoder (List { a | impacts : Impacts }) -> Definitions -> String -> Result Decode.Error (List { a | impacts : Impacts })
decodeProcesses decoder definitions processesString =
    processesString
        |> Decode.decodeString decoder
        |> Result.map
            (List.map
                (\process ->
                    { process | impacts = Impact.updateAggregatedScores definitions process.impacts }
                )
            )


keepOnlyAggregated : List { a | impacts : Impacts } -> List { a | impacts : Impacts }
keepOnlyAggregated processes =
    processes
        |> List.map
            (\process ->
                { process
                    | impacts =
                        Impact.mapImpacts
                            (\def impact ->
                                if Definition.isAggregate def then
                                    impact

                                else
                                    Quantity.zero
                            )
                            process.impacts
                }
            )


toExport : Flags -> Result Decode.Error Encode.Value
toExport { definitionsString, foodProcessesString, textileProcessesString, objectProcessesString } =
    definitionsString
        |> Decode.decodeString Definition.decode
        |> Result.andThen
            (\definitions ->
                let
                    textileProcessesResult =
                        decodeProcesses (TextileProcess.decodeList Impact.decodeWithoutAggregated) definitions textileProcessesString

                    foodProcessesResult =
                        decodeProcesses (FoodProcess.decodeList Impact.decodeWithoutAggregated) definitions foodProcessesString

                    objectProcessesResult =
                        decodeProcesses (ObjectProcess.decodeList Impact.decodeWithoutAggregated) definitions objectProcessesString
                in
                Result.map3
                    (\textileProcesses foodProcesses objectProcesses ->
                        let
                            textileProcessesOnlyAggregated =
                                textileProcesses
                                    |> keepOnlyAggregated

                            foodProcessesOnlyAggregated =
                                foodProcesses
                                    |> keepOnlyAggregated

                            objectProcessesOnlyAggregated =
                                objectProcesses
                                    |> keepOnlyAggregated
                        in
                        Encode.object
                            [ ( "textileProcesses", Encode.list TextileProcess.encode textileProcesses )
                            , ( "foodProcesses", Encode.list FoodProcess.encode foodProcesses )
                            , ( "objectProcesses", Encode.list ObjectProcess.encode objectProcesses )
                            , ( "textileProcessesOnlyAggregated", Encode.list TextileProcess.encode textileProcessesOnlyAggregated )
                            , ( "foodProcessesOnlyAggregated", Encode.list FoodProcess.encode foodProcessesOnlyAggregated )
                            , ( "objectProcessesOnlyAggregated", Encode.list ObjectProcess.encode objectProcessesOnlyAggregated )
                            ]
                    )
                    textileProcessesResult
                    foodProcessesResult
                    objectProcessesResult
            )


init : Flags -> ( (), Cmd () )
init flags =
    case toExport flags of
        Err error ->
            ( ()
            , error
                |> Decode.errorToString
                |> Encode.string
                |> logError
            )

        Ok encodedValue ->
            ( ()
            , export encodedValue
            )


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port export : Encode.Value -> Cmd msg


port logError : Encode.Value -> Cmd msg
