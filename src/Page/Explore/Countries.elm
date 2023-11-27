module Page.Explore.Countries exposing (table)

import Data.Country as Country exposing (Country)
import Data.Dataset as Dataset
import Data.Gitbook as Gitbook
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split
import Data.Transport as Transport
import Dict.Any as Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


table : Transport.Distances -> List Country.Country -> { detailed : Bool, scope : Scope } -> Table Country String msg
table distances countries { detailed, scope } =
    { toId = .code >> Country.codeToString
    , toRoute = .code >> Just >> Dataset.Countries >> Route.Explore scope
    , rows =
        [ Just
            { label = "Code"
            , toValue = .code >> Country.codeToString
            , toCell =
                \country ->
                    if detailed then
                        code [] [ text (Country.codeToString country.code) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.Countries (Just country.code))) ]
                            [ code [] [ text (Country.codeToString country.code) ] ]
            }
        , Just
            { label = "Nom"
            , toValue = .name
            , toCell = .name >> text
            }
        , Just
            { label = "Mix éléctrique"
            , toValue = .electricityProcess >> .name
            , toCell = .electricityProcess >> .name >> text
            }
        , Just
            { label = "Chaleur"
            , toValue = .heatProcess >> .name
            , toCell = .heatProcess >> .name >> text
            }
        , if scope == Scope.Textile then
            Just
                { label = "Taux de pollution aquatique"
                , toValue = .aquaticPollutionScenario >> Country.getAquaticPollutionRatio >> Split.toPercentString
                , toCell =
                    \country ->
                        div [ classList [ ( "text-end", not detailed ) ] ]
                            [ Format.splitAsPercentage (Country.getAquaticPollutionRatio country.aquaticPollutionScenario)
                            , Link.smallPillExternal
                                [ href (Gitbook.publicUrlFromPath Gitbook.TextileEnnoblingCountriesAquaticPollution) ]
                                [ Icon.info ]
                            ]
                }

          else
            Nothing
        , Just
            { label = "Part du transport aérien"
            , toValue = .airTransportRatio >> Split.toPercentString
            , toCell =
                \country ->
                    div [ classList [ ( "text-end", not detailed ) ] ]
                        [ Format.splitAsPercentage country.airTransportRatio
                        , Link.smallPillExternal
                            [ href (Gitbook.publicUrlFromPath Gitbook.TextileAerialTransport) ]
                            [ Icon.info ]
                        ]
            }
        , Just
            { label = "Domaines"
            , toValue = .scopes >> List.map Scope.toLabel >> String.join "/"
            , toCell = Common.scopesView
            }
        , if detailed then
            Just
                { label = "Distances"
                , toValue = always ""
                , toCell = displayDistances countries distances
                }

          else
            Nothing
        ]
            |> List.filterMap identity
    }


displayDistances : List Country.Country -> Transport.Distances -> Country -> Html msg
displayDistances countries distances country =
    case Dict.get country.code distances of
        Just countryDistances ->
            countryDistances
                |> Dict.foldl (distancesToRows countries) []
                |> (\rows ->
                        Html.table [ class "table table-striped table-hover text-center w-100" ]
                            [ thead []
                                [ tr []
                                    [ th [] [ text "Code pays" ]
                                    , th [] [ text "Aérien" ]
                                    , th [] [ text "Routier" ]
                                    , th [] [ text "Maritime" ]
                                    ]
                                ]
                            , tbody []
                                (List.reverse rows)
                            ]
                   )

        Nothing ->
            text ""


distancesToRows : List Country.Country -> Country.Code -> Transport.Transport -> List (Html msg) -> List (Html msg)
distancesToRows countries countryCode transport rows =
    rows
        |> (::) (transportToRow countryCode countries transport)


transportToRow : Country.Code -> List Country.Country -> Transport.Transport -> Html msg
transportToRow countryCode countries transport =
    tr []
        [ td
            [ Country.findByCode countryCode countries
                |> Result.map .name
                |> Result.withDefault ""
                |> title
            ]
            [ text <| Country.codeToString countryCode ]
        , td [] [ Format.km transport.air ]
        , td [] [ Format.km transport.road ]
        , td [] [ Format.km transport.sea ]
        ]
