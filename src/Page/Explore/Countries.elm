module Page.Explore.Countries exposing (table)

import Data.Country as Country exposing (Country)
import Data.Dataset as Dataset
import Data.Gitbook as Gitbook
import Data.Process as Process
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split
import Data.Transport as Transport
import Dict.Any as Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Quantity
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


table : Transport.Distances -> List Country.Country -> { detailed : Bool, scope : Scope } -> Table Country String msg
table distances countries { detailed, scope } =
    { filename = "countries"
    , toId = .code >> Country.codeToString
    , toRoute = .code >> Just >> Dataset.Countries >> Route.Explore scope
    , toSearchableString = Country.toSearchableString
    , legend = []
    , columns =
        List.filterMap identity
            [ Just
                { label = "Code"
                , toValue = Table.StringValue <| .code >> Country.codeToString
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
                , toValue = Table.StringValue .name
                , toCell = .name >> text
                }
            , Just
                { label = "Mix éléctrique"
                , toValue = Table.StringValue <| .electricityProcess >> Process.getDisplayName
                , toCell = .electricityProcess >> Process.getDisplayName >> text
                }
            , Just
                { label = "Chaleur"
                , toValue = Table.StringValue <| .heatProcess >> Process.getDisplayName
                , toCell = .heatProcess >> Process.getDisplayName >> text
                }
            , if scope == Scope.Textile then
                Just
                    { label = "Taux de pollution aquatique"
                    , toValue = Table.FloatValue (.aquaticPollutionScenario >> Country.getAquaticPollutionRatio >> Split.toPercent)
                    , toCell =
                        \country ->
                            div [ classList [ ( "text-end", not detailed ) ] ]
                                [ Format.splitAsPercentage 2 (Country.getAquaticPollutionRatio country.aquaticPollutionScenario)
                                , Link.smallPillExternal
                                    [ href (Gitbook.publicUrlFromPath Gitbook.TextileEnnoblingCountriesAquaticPollution) ]
                                    [ Icon.info ]
                                ]
                    }

              else
                Nothing
            , if detailed then
                Just
                    { label = "Distances"
                    , toValue = Table.StringValue <| always ""
                    , toCell = displayDistances countries distances
                    }

              else
                Nothing
            ]
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
    let
        formatDistance length =
            if length == Quantity.zero then
                span [ title "Non-applicable" ] [ text "N/A" ]

            else
                Format.km length
    in
    tr []
        [ td
            [ Country.findByCode countryCode countries
                |> Result.map .name
                |> Result.withDefault ""
                |> title
            ]
            [ text <| Country.codeToString countryCode ]
        , td [] [ formatDistance transport.air ]
        , td [] [ formatDistance transport.road ]
        , td [] [ formatDistance transport.sea ]
        ]
