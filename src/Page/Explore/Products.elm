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
      , toCell = \product -> text product.name
      }
    , { label = "Masse par défaut"
      , toCell = \product -> Format.kg product.mass
      }
    , { label = "Taux de perte (PCR)"
      , toCell = \product -> Format.ratio product.pcrWaste
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
      , toCell = \product -> text product.fabricProcess.name
      }
    , { label = "Confection"
      , toCell = \product -> text product.makingProcess.name
      }
    , { label = "Nombre de jours porté"
      , toCell = \product -> Format.days product.daysOfWear
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell = \product -> product.wearsPerCycle |> String.fromInt |> text
      }
    , { label = "Utilisations avant lavage"
      , toCell = \product -> text (String.fromInt product.useDefaultNbCycles)
      }
    , { label = "Procédé de repassage"
      , toCell = \product -> text product.useIroningProcess.name
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = \product -> text product.useNonIroningProcess.name
      }
    , { label = "Séchage électrique"
      , toCell = \product -> Format.ratio product.useRatioDryer
      }
    , { label = "Repassage (part)"
      , toCell = \product -> Format.ratio product.useRatioIroning
      }
    , { label = "Repassage (temps)"
      , toCell = \product -> Format.hours product.useTimeIroning
      }
    ]
