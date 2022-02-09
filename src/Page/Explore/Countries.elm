module Page.Explore.Countries exposing (table)

import Data.Country as Country exposing (Country)
import Data.Db as Db
import Data.Gitbook as Gitbook
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link


hypothesisDocLink : Html msg
hypothesisDocLink =
    Link.smallPillExternal [ href (Gitbook.publicUrlFromPath Gitbook.CountryHypothesis) ]
        [ Icon.info ]


table : { detailed : Bool } -> Table Country msg
table { detailed } =
    [ { label = "Code"
      , toCell =
            \country ->
                if detailed then
                    code [] [ text (Country.codeToString country.code) ]

                else
                    a [ Route.href (Route.Explore (Db.Countries (Just country.code))) ]
                        [ code [] [ text (Country.codeToString country.code) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    , { label = "Mix éléctrique"
      , toCell = .electricityProcess >> .name >> text
      }
    , { label = "Chaleur"
      , toCell = .heatProcess >> .name >> text
      }
    , { label = "Majoration de teinture"
      , toCell =
            \country ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio country.dyeingWeighting
                    , hypothesisDocLink
                    ]
      }
    , { label = "Part du transport aérien"
      , toCell =
            \country ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio country.airTransportRatio
                    , hypothesisDocLink
                    ]
      }
    ]
