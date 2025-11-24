module Page.Explore.GeoZones exposing (table)

import Data.Dataset as Dataset
import Data.GeoZone as GeoZone exposing (GeoZone)
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


table : Transport.Distances -> List GeoZone.GeoZone -> { detailed : Bool, scope : Scope } -> Table GeoZone String msg
table distances geoZones { detailed, scope } =
    { filename = "geo-zones"
    , toId = .code >> GeoZone.codeToString
    , toRoute = .code >> Just >> Dataset.GeoZones >> Route.Explore scope
    , legend = []
    , columns =
        List.filterMap identity
            [ Just
                { label = "Code"
                , toValue = Table.StringValue <| .code >> GeoZone.codeToString
                , toCell =
                    \geoZone ->
                        if detailed then
                            code [] [ text (GeoZone.codeToString geoZone.code) ]

                        else
                            a [ Route.href (Route.Explore scope (Dataset.GeoZones (Just geoZone.code))) ]
                                [ code [] [ text (GeoZone.codeToString geoZone.code) ] ]
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
                    , toValue = Table.FloatValue (.aquaticPollutionScenario >> GeoZone.getAquaticPollutionRatio >> Split.toPercent)
                    , toCell =
                        \geoZone ->
                            div [ classList [ ( "text-end", not detailed ) ] ]
                                [ Format.splitAsPercentage 2 (GeoZone.getAquaticPollutionRatio geoZone.aquaticPollutionScenario)
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
                    , toCell = displayDistances geoZones distances
                    }

              else
                Nothing
            ]
    }


displayDistances : List GeoZone.GeoZone -> Transport.Distances -> GeoZone -> Html msg
displayDistances geoZones distances geoZone =
    case Dict.get geoZone.code distances of
        Just geoZoneDistances ->
            geoZoneDistances
                |> Dict.foldl (distancesToRows geoZones) []
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


distancesToRows : List GeoZone.GeoZone -> GeoZone.Code -> Transport.Transport -> List (Html msg) -> List (Html msg)
distancesToRows geoZones geoZoneCode transport rows =
    rows
        |> (::) (transportToRow geoZoneCode geoZones transport)


transportToRow : GeoZone.Code -> List GeoZone.GeoZone -> Transport.Transport -> Html msg
transportToRow geoZoneCode geoZones transport =
    let
        formatDistance length =
            if length == Quantity.zero then
                span [ title "Non-applicable" ] [ text "N/A" ]

            else
                Format.km length
    in
    tr []
        [ td
            [ GeoZone.findByCode geoZoneCode geoZones
                |> Result.map .name
                |> Result.withDefault ""
                |> title
            ]
            [ text <| GeoZone.codeToString geoZoneCode ]
        , td [] [ formatDistance transport.air ]
        , td [] [ formatDistance transport.road ]
        , td [] [ formatDistance transport.sea ]
        ]
