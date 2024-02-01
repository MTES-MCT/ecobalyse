port module ComputeAggregated exposing (..)

import Data.Food.Process as FoodProcess
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Process as TextileProcess
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Msg
    = NoOp


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
            (\processes ->
                processes
                    |> List.map
                        (\process ->
                            { process | impacts = Impact.updateAggregatedScores definitions process.impacts }
                        )
            )


init : Flags -> ( (), Cmd Msg )
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
                                Encode.object
                                    [ ( "textileProcesses", Encode.list TextileProcess.encode textileProcesses )
                                    , ( "foodProcesses", Encode.list FoodProcess.encode foodProcesses )
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
            let
                _ =
                    Debug.log "error while decoding" error
            in
            ( ()
            , Cmd.none
            )


update : Msg -> Cmd Msg
update msg =
    case msg of
        NoOp ->
            Cmd.none


main : Program Flags () Msg
main =
    Platform.worker
        { init = init
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = always Sub.none
        }


port export : Encode.Value -> Cmd msg
