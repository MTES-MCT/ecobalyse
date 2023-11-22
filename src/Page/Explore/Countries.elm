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


table : Transport.Distances -> { detailed : Bool, scope : Scope } -> Table Country String msg
table distances { detailed, scope } =
    { toId = .code >> Country.codeToString
    , toRoute = .code >> Just >> Dataset.Countries >> Route.Explore scope
    , rows =
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
            :: { label = "Nom"
               , toValue = .name
               , toCell = .name >> text
               }
            :: { label = "Mix éléctrique"
               , toValue = .electricityProcess >> .name
               , toCell = .electricityProcess >> .name >> text
               }
            :: { label = "Chaleur"
               , toValue = .heatProcess >> .name
               , toCell = .heatProcess >> .name >> text
               }
            :: { label = "Part du transport aérien"
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
            :: { label = "Domaines"
               , toValue = .scopes >> List.map Scope.toLabel >> String.join "/"
               , toCell = Common.scopesView
               }
            :: (if detailed then
                    [ { label = "Distances"
                      , toValue = always ""
                      , toCell = displayDistances distances
                      }
                    ]

                else
                    []
               )
    }


displayDistances : Transport.Distances -> Country -> Html msg
displayDistances distances country =
    case Dict.get country.code distances of
        Just countryDistances ->
            countryDistances
                |> Dict.foldl distancesToRows []
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


distancesToRows : Country.Code -> Transport.Transport -> List (Html msg) -> List (Html msg)
distancesToRows countryCode transport rows =
    rows
        |> (::) (transportToRow countryCode transport)


transportToRow : Country.Code -> Transport.Transport -> Html msg
transportToRow countryCode transport =
    tr []
        [ td [] [ text <| Country.codeToString countryCode ]
        , td [] [ Format.km transport.air ]
        , td [] [ Format.km transport.road ]
        , td [] [ Format.km transport.sea ]
        ]
