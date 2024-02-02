port module ComputeAggregated exposing (main)

import Data.Food.Process as FoodProcess
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Process as TextileProcess
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity


type alias Flags =
    { definitionsString : String
    , textileProcessesString : String
    , foodProcessesString : String
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


init : Flags -> ( (), Cmd () )
init { definitionsString, textileProcessesString, foodProcessesString } =
    let
        toExport =
            definitionsString
                |> Decode.decodeString Definition.decode
                |> Result.andThen
                    (\definitions ->
                        let
                            textileProcessesResult =
                                decodeProcesses (TextileProcess.decodeList Impact.decodeWithoutAggregated) definitions textileProcessesString

                            foodProcessesResult =
                                decodeProcesses (FoodProcess.decodeList Impact.decodeWithoutAggregated) definitions foodProcessesString
                        in
                        Result.map2
                            (\textileProcesses foodProcesses ->
                                let
                                    textileProcessesOnlyAggregated =
                                        textileProcesses
                                            |> keepOnlyAggregated

                                    foodProcessesOnlyAggregated =
                                        foodProcesses
                                            |> keepOnlyAggregated
                                in
                                Encode.object
                                    [ ( "textileProcesses", Encode.list TextileProcess.encode textileProcesses )
                                    , ( "foodProcesses", Encode.list FoodProcess.encode foodProcesses )
                                    , ( "textileProcessesOnlyAggregated", Encode.list TextileProcess.encode textileProcessesOnlyAggregated )
                                    , ( "foodProcessesOnlyAggregated", Encode.list FoodProcess.encode foodProcessesOnlyAggregated )
                                    ]
                            )
                            textileProcessesResult
                            foodProcessesResult
                    )
    in
    case toExport of
        Ok encodedValue ->
            ( ()
            , export encodedValue
            )

        Err error ->
            ( ()
            , error
                |> Decode.errorToString
                |> Encode.string
                |> logError
            )


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = always Sub.none
        }


port export : Encode.Value -> Cmd msg


port logError : Encode.Value -> Cmd msg
