module Page.Explore.Geozones exposing (table)

import Data.Dataset as Dataset
import Data.Geozone as Geozone exposing (Geozone)
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


table : Transport.Distances -> List Geozone.Geozone -> { detailed : Bool, scope : Scope } -> Table Geozone String msg
table distances geozones { detailed, scope } =
    { filename = "geozones"
    , toId = .code >> Geozone.codeToString
    , toRoute = .code >> Just >> Dataset.Geozones >> Route.Explore scope
    , legend = []
    , columns =
        List.filterMap identity
            [ Just
                { label = "Code"
                , toValue = Table.StringValue <| .code >> Geozone.codeToString
                , toCell =
                    \geozone ->
                        if detailed then
                            code [] [ text (Geozone.codeToString geozone.code) ]

                        else
                            a [ Route.href (Route.Explore scope (Dataset.Geozones (Just geozone.code))) ]
                                [ code [] [ text (Geozone.codeToString geozone.code) ] ]
                }
            , Just
                { label = "Nom"
                , toValue = Table.StringValue .name
                , toCell = .name >> text
                }
            , Just
                { label = "Mix électrique"
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
                    , toValue = Table.FloatValue (.aquaticPollutionScenario >> Geozone.getAquaticPollutionRatio >> Split.toPercent)
                    , toCell =
                        \geozone ->
                            div [ classList [ ( "text-end", not detailed ) ] ]
                                [ Format.splitAsPercentage 2 (Geozone.getAquaticPollutionRatio geozone.aquaticPollutionScenario)
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
                    , toCell = displayDistances geozones distances
                    }

              else
                Nothing
            ]
    }


displayDistances : List Geozone.Geozone -> Transport.Distances -> Geozone -> Html msg
displayDistances geozones distances geozone =
    case Dict.get geozone.code distances of
        Just geozoneDistances ->
            geozoneDistances
                |> Dict.foldl (distancesToRows geozones) []
                |> (\rows ->
                        Html.table [ class "table table-striped table-hover text-center w-100" ]
                            [ thead []
                                [ tr []
                                    [ th [] [ text "Zone" ]
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


distancesToRows : List Geozone.Geozone -> Geozone.Code -> Transport.Transport -> List (Html msg) -> List (Html msg)
distancesToRows geozones geozoneCode transport rows =
    rows
        |> (::) (transportToRow geozoneCode geozones transport)


transportToRow : Geozone.Code -> List Geozone.Geozone -> Transport.Transport -> Html msg
transportToRow geozoneCode geozones transport =
    let
        formatDistance length =
            if length == Quantity.zero then
                span [ title "Non-applicable" ] [ text "N/A" ]

            else
                Format.km length
    in
    tr []
        [ td
            [ Geozone.findByCode geozoneCode geozones
                |> Result.map .name
                |> Result.withDefault ""
                |> title
            ]
            [ text <| Geozone.codeToString geozoneCode ]
        , td [] [ formatDistance transport.air ]
        , td [] [ formatDistance transport.road ]
        , td [] [ formatDistance transport.sea ]
        ]
