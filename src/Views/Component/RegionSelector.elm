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
    { countries : List Country
    , domId : String
    , scope : Scope
    , select : Maybe CountryCode.Code -> msg
    , selected : Maybe CountryCode.Code
    }


view : Config msg -> Html msg
view config =
    let
        scopedCountries =
            config.countries
                |> Scope.anyOf [ config.scope ]
                |> List.sortBy .name
    in
    div []
        [ label [ class "visually-hidden", for config.domId ] [ text "Région" ]
        , scopedCountries
            |> List.map (\{ code, name } -> ( name, Just code ))
            |> (::) ( "Par défaut", Nothing )
            |> List.map
                (\( name, maybeCode ) ->
                    option
                        [ maybeCode
                            |> Maybe.map CountryCode.toString
                            |> Maybe.withDefault ""
                            |> value
                        , selected <| config.selected == maybeCode
                        ]
                        [ text <|
                            case maybeCode of
                                Just code ->
                                    name ++ " (" ++ CountryCode.toString code ++ ")"

                                Nothing ->
                                    "---"
                        ]
                )
            |> select
                [ class "RegionSelector form-select form-select-sm w-100"
                , id config.domId
                , autocomplete False
                , onInput <|
                    \str ->
                        config.select <|
                            if String.isEmpty str || str == "---" then
                                Nothing

                            else
                                Just <| CountryCode.fromString str
                ]
        ]
