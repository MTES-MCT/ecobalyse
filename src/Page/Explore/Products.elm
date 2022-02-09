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
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.kg product.mass ]
      }
    , { label = "Taux de perte (PCR)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.pcrWaste ]
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
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "picks/m" product.ppm
                    ]
      }
    , { label = "Grammage"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "gr/kg" product.grammage
                    ]
      }
    , { label = "Procédé"
      , toCell = .fabricProcess >> .name >> text
      }
    , { label = "Confection"
      , toCell = .makingProcess >> .name >> text
      }
    , { label = "Nombre de jours porté"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.days product.daysOfWear ]
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ text <| String.fromInt product.wearsPerCycle ]
      }
    , { label = "Utilisations avant lavage"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ text <| String.fromInt product.useDefaultNbCycles ]
      }
    , { label = "Procédé de repassage"
      , toCell = .useIroningProcess >> .name >> text
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = .useNonIroningProcess >> .name >> text
      }
    , { label = "Séchage électrique"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.useRatioDryer ]
      }
    , { label = "Repassage (part)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.useRatioIroning ]
      }
    , { label = "Repassage (temps)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.hours product.useTimeIroning ]
      }
    ]
