module Page.Explore.Products exposing (table)

import Data.Db as Db exposing (Db)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


table : Db -> { detailed : Bool } -> Table Product msg
table db { detailed } =
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
    , { label = "Volume"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.m3 product.volume ]
      }
    , { label = "Perte (PCR)"
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
                        Format.picking product.picking
                    ]
      }
    , { label = "Grammage"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ if product.knitted then
                        text "N/A"

                      else
                        Format.surfaceMass product.surfaceMass
                    ]
      }
    , { label = "Procédé"
      , toCell = .fabricProcess >> .name >> text
      }
    , { label = "Confection"
      , toCell = .makingProcess >> .name >> text
      }
    , { label = "Délavage"
      , toCell =
            \product ->
                if product.faded then
                    db.processes
                        |> Process.loadWellKnown
                        |> Result.map (.fading >> .name >> text)
                        |> Result.withDefault (text "Erreur, procédé de délavage introuvable")

                else
                    text "N/A"
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
