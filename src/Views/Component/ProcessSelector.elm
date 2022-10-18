module Views.Component.ProcessSelector exposing (view)

import Data.Food.Process as Process exposing (Process, ProcessName)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Views.Component.AmountInput as AmountInput


type alias Config msg =
    -- Process selector
    { processes : List Process
    , category : Process.Category
    , alreadyUsedProcesses : List Process.Process
    , selectedProcess : Maybe Process
    , onProcessSelected : Maybe Process -> msg

    -- Amount input
    , amount : Float
    , onAmountChanged : Maybe Float -> msg

    -- Form
    , onSubmit : msg
    }


toMaybeProcessName : String -> Maybe ProcessName
toMaybeProcessName string =
    if string == "" then
        Nothing

    else
        Just (Process.nameFromString string)


processSelector : Maybe Process -> (Maybe Process -> msg) -> List Process -> Html msg
processSelector maybeSelectedProcess event processes =
    processes
        |> List.map
            (\process ->
                let
                    string =
                        Process.nameToString process.name
                in
                ( string, option [ selected <| maybeSelectedProcess == Just process ] [ text string ] )
            )
        |> List.sortBy Tuple.first
        |> (++)
            [ ( "-- Sélectionner un ingrédient dans la liste --"
              , option [ selected <| maybeSelectedProcess == Nothing ]
                    [ text "-- Sélectionner un ingrédient dans la liste --" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        |> Html.Keyed.node "select"
            [ class "form-select"
            , onInput
                (toMaybeProcessName
                    >> Maybe.andThen (Process.findByName processes >> Result.toMaybe)
                    >> event
                )
            ]


view : Config msg -> Html msg
view config =
    Html.form
        [ class "row pt-3 gap-2 gap-md-0"
        , onSubmit config.onSubmit
        ]
        [ div [ class "col-md-6" ]
            [ config.processes
                |> Process.listByCategory config.category
                |> List.filter
                    (\processName ->
                        -- Exclude already used ingredients
                        config.alreadyUsedProcesses
                            |> List.member processName
                            |> not
                    )
                |> processSelector config.selectedProcess config.onProcessSelected
            ]
        , div [ class "col-md-3" ]
            [ case config.selectedProcess of
                Just selectedProcess ->
                    AmountInput.view
                        { amount = config.amount
                        , onAmountChanged = config.onAmountChanged
                        , unit = selectedProcess.unit
                        }

                Nothing ->
                    text ""
            ]
        , div [ class "col-md-3" ]
            [ button
                [ type_ "submit"
                , class "btn btn-primary w-100 text-truncate"
                , disabled (config.selectedProcess == Nothing)
                , title "Ajouter un ingrédient"
                ]
                [ text "Ajouter un ingrédient" ]
            ]
        ]
