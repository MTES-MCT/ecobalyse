module Page.Explore.Countries exposing (table)

import Data.Country as Country exposing (Country)
import Data.Dataset as Dataset
import Data.Gitbook as Gitbook
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Common as Common
import Page.Explore.Table exposing (TableWithValue)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


table : { detailed : Bool, scope : Scope } -> TableWithValue Country String msg
table { detailed, scope } =
    [ { label = "Code"
      , toValue = .code >> Country.codeToString
      , toCell =
            \country ->
                if detailed then
                    code [] [ text (Country.codeToString country.code) ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.Countries (Just country.code))) ]
                        [ code [] [ text (Country.codeToString country.code) ] ]
      }
    , { label = "Nom"
      , toValue = .name
      , toCell = .name >> text
      }
    , { label = "Mix éléctrique"
      , toValue = .electricityProcess >> .name
      , toCell = .electricityProcess >> .name >> text
      }
    , { label = "Chaleur"
      , toValue = .heatProcess >> .name
      , toCell = .heatProcess >> .name >> text
      }
    , { label = "Part du transport aérien"
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
    , { label = "Domaines"
      , toValue = .scopes >> List.map Scope.toLabel >> String.join "/"
      , toCell = Common.scopesView
      }
    ]
