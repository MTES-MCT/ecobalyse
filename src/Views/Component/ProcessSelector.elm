module Views.Component.ProcessSelector exposing (..)

import Data.Food.Process as Process exposing (Process, ProcessName)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Views.Component.GramsInput as GramsInput


type alias Config msg =
    -- Process selector
    { processes : List Process
    , category : Process.Category
    , alreadyUsedProcesses : List Process.Process
    , selectedProcess : Maybe ProcessName
    , onProcessSelected : ProcessName -> msg

    -- Amount input
    , amount : Float
    , onNewAmount : Maybe Float -> msg

    -- Form
    , onSubmit : msg
    }


maybeToProcessName : String -> Maybe ProcessName
maybeToProcessName string =
    if string == "" then
        Nothing

    else
        Just (Process.nameFromString string)


processSelector :
    Maybe ProcessName
    -> (Maybe ProcessName -> msg)
    -> List ProcessName
    -> Html msg
processSelector maybeSelectedItem event =
    List.map
        (\processName ->
            let
                string =
                    Process.nameToString processName
            in
            ( string, option [ selected <| maybeSelectedItem == Just processName ] [ text string ] )
        )
        >> (++)
            [ ( "-- Sélectionner un ingrédient dans la liste --"
              , option [ selected <| maybeSelectedItem == Nothing ] [ text "-- Sélectionner un ingrédient dans la liste --" ]
              )
            ]
        -- We use Html.Keyed because when we add an item, we filter it out from the select box,
        -- which desynchronizes the DOM state and the virtual dom state
        >> Html.Keyed.node "select" [ class "form-select", onInput (maybeToProcessName >> event) ]


view : Config msg -> Html msg
view config =
    div [ class "row pt-3 gap-2 gap-md-0" ]
        [ div [ class "col-md-5" ]
            [ config.products
                |> Product.listIngredientNames
                |> List.filter
                    (\processName ->
                        -- Exclude already used ingredients
                        config.alreadyUsedProcesses
                            |> List.map .name
                            |> List.member processName
                            |> not
                    )
                |> processSelector config.selectedProcess config.onProcessSelected
            ]
        , div [ class "col-md-3" ]
            [ GramsInput.view "new-ingredient" config.mass config.onNewMass
            ]
        , div [ class "col-md-4" ]
            [ button
                [ class "btn btn-primary w-100 text-truncate"
                , onClick AddItem
                , disabled (selectedItem == Nothing)
                , title "Ajouter un ingrédient"
                ]
                [ text "Ajouter un ingrédient" ]
            ]
        ]
