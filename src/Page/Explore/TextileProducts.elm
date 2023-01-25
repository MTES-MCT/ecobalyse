module Page.Explore.TextileProducts exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium as DyeingMedium
import Data.Textile.Process as Process
import Data.Textile.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


table : Db -> { detailed : Bool, scope : Scope } -> Table Product msg
table db { detailed, scope } =
    [ { label = "Identifiant"
      , toCell =
            \product ->
                if detailed then
                    code [] [ text (Product.idToString product.id) ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.TextileProducts (Just product.id))) ]
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
                    [ Format.m3 product.endOfLife.volume ]
      }
    , { label = "Perte (PCR)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.making.pcrWaste ]
      }
    , { label = "Type de procédé"
      , toCell =
            \product ->
                case product.fabric of
                    Product.Knitted _ ->
                        text "Tricotage"

                    Product.Weaved _ _ ->
                        text "Tissage"
      }
    , { label = "Pick-per-meter"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ case product.fabric of
                        Product.Knitted _ ->
                            text "N/A"

                        Product.Weaved _ picking ->
                            Format.picking picking
                    ]
      }
    , { label = "Grammage"
      , toCell =
            \{ surfaceMass } ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.surfaceMass surfaceMass
                    ]
      }
    , { label = "Procédé"
      , toCell = Product.getFabricProcess >> .name >> text
      }
    , { label = "Confection"
      , toCell = .making >> .process >> .name >> text
      }
    , { label = "Délavage"
      , toCell =
            \product ->
                if product.making.fadable then
                    db.processes
                        |> Process.loadWellKnown
                        |> Result.map (.fading >> .name >> text)
                        |> Result.withDefault (text "Erreur, procédé de délavage introuvable")

                else
                    text "N/A"
      }
    , { label = "Teinture"
      , toCell =
            \{ dyeing } ->
                text <| "sur " ++ DyeingMedium.toLabel dyeing.defaultMedium
      }
    , { label = "Nombre de jours porté"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.days product.use.daysOfWear ]
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ text <| String.fromInt product.use.wearsPerCycle ]
      }
    , { label = "Utilisations avant lavage"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ text <| String.fromInt product.use.defaultNbCycles ]
      }
    , { label = "Procédé de repassage"
      , toCell = .use >> .ironingProcess >> .name >> text
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = .use >> .nonIroningProcess >> .name >> text
      }
    , { label = "Séchage électrique"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.use.ratioDryer ]
      }
    , { label = "Repassage (part)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.ratio product.use.ratioIroning ]
      }
    , { label = "Repassage (temps)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.hours product.use.timeIroning ]
      }
    ]
