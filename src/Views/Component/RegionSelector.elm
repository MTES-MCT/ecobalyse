module Views.Component.RegionSelector exposing
    ( Config
    , view
    )

import Data.Country exposing (Country)
import Data.Country.Code as CountryCode
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attrs : List (Attribute msg)
    , classes : String
    , countries : List Country
    , disabled : Bool
    , domId : String
    , emptyLabel : String
    , hideLabel : Bool
    , label : Maybe String
    , scope : Scope
    , select : Maybe CountryCode.Code -> msg
    , selected : Maybe CountryCode.Code
    , showCode : Bool
    }


optionLabel : Bool -> String -> Maybe CountryCode.Code -> String
optionLabel showCode name maybeCode =
    case ( showCode, maybeCode ) of
        ( True, Just code ) ->
            name ++ " (" ++ CountryCode.toString code ++ ")"

        _ ->
            name


selectElement : Config msg -> Html msg
selectElement config =
    config.countries
        |> Scope.anyOf [ config.scope ]
        |> List.sortBy .name
        |> List.map (\{ code, name } -> ( name, Just code ))
        |> (::) ( config.emptyLabel, Nothing )
        |> List.map
            (\( name, maybeCode ) ->
                option
                    [ maybeCode
                        |> Maybe.map CountryCode.toString
                        |> Maybe.withDefault ""
                        |> value
                    , selected <| config.selected == maybeCode
                    ]
                    [ text <| optionLabel config.showCode name maybeCode ]
            )
        |> select
            ([ class <| String.trim <| "form-select " ++ config.classes
             , id config.domId
             , autocomplete False
             , disabled config.disabled
             , onInput <|
                \str ->
                    config.select <|
                        if String.isEmpty str then
                            Nothing

                        else
                            Just <| CountryCode.fromString str
             ]
                ++ config.attrs
            )


view : Config msg -> Html msg
view config =
    case config.label of
        Just labelText ->
            div []
                [ label
                    (if config.hideLabel then
                        [ class "visually-hidden", for config.domId ]

                     else
                        [ for config.domId ]
                    )
                    [ text labelText ]
                , selectElement config
                ]

        Nothing ->
            selectElement config
