module Page.Explore.Products exposing (table)

import Data.Db as Db
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


table : { detailed : Bool } -> Table Product msg
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \product ->
                if detailed then
                    code [] [ text (Product.idToString product.id) ]

                else
                    a [ Route.href (Route.Explore (Db.Products (Just product.id))) ]
                        [ code [] [ text (Product.idToString product.id) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    , { label = "Masse par défaut"
      , toCell = .mass >> Format.kg
      }
    , { label = "Taux de perte (PCR)"
      , toCell = .pcrWaste >> Format.ratio
      }
    , { label = "Type de procédé"
      , toCell =
            \product ->
                if product.knitted then
                    text "Tricotage"

                else
                    text "Tissage"
      }
    , { label = "Pick-per-meter"
      , toCell =
            \product ->
                if product.knitted then
                    text "N/A"

                else
                    text <| Format.formatInt "picks/m" product.ppm
      }
    , { label = "Grammage"
      , toCell =
            \product ->
                if product.knitted then
                    text "N/A"

                else
                    text <| Format.formatInt "gr/kg" product.grammage
      }
    , { label = "Procédé"
      , toCell = .fabricProcess >> .name >> text
      }
    , { label = "Confection"
      , toCell = .makingProcess >> .name >> text
      }
    , { label = "Nombre de jours porté"
      , toCell = .daysOfWear >> Format.days
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell = .wearsPerCycle >> String.fromInt >> text
      }
    , { label = "Utilisations avant lavage"
      , toCell = .useDefaultNbCycles >> String.fromInt >> text
      }
    , { label = "Procédé de repassage"
      , toCell = .useIroningProcess >> .name >> text
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = .useNonIroningProcess >> .name >> text
      }
    , { label = "Séchage électrique"
      , toCell = .useRatioDryer >> Format.ratio
      }
    , { label = "Repassage (part)"
      , toCell = .useRatioIroning >> Format.ratio
      }
    , { label = "Repassage (temps)"
      , toCell = .useTimeIroning >> Format.hours
      }
    ]
