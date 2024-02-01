module ComputeAggregated exposing (..)

import Data.Food.Process as FoodProcess
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Process as TextileProcess
import Json.Decode as Decode


type Msg
    = NoOp


type alias Flags =
    { definitionsString : String
    , textileProcessesString : String
    , foodProcessesString : String
    }


init : Flags -> ( (), Cmd Msg )
init { definitionsString, textileProcessesString, foodProcessesString } =
    case Decode.decodeString Definition.decode definitionsString of
        Ok definitions ->
            let
                _ =
                    textileProcessesString
                        |> Decode.decodeString (TextileProcess.decodeList Impact.decodeWithoutAggregated)
                        |> Result.map
                            (\processes ->
                                processes
                                    |> List.map
                                        (\process ->
                                            { process | impacts = Impact.updateAggregatedScores definitions process.impacts }
                                        )
                            )
                        |> Debug.log "textile processes"

                _ =
                    foodProcessesString
                        |> Decode.decodeString (FoodProcess.decodeList Impact.decodeWithoutAggregated)
                        |> Result.map
                            (\processes ->
                                processes
                                    |> List.map
                                        (\process ->
                                            { process | impacts = Impact.updateAggregatedScores definitions process.impacts }
                                        )
                            )
                        |> Debug.log "food processes"
            in
            ( ()
            , Cmd.none
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
