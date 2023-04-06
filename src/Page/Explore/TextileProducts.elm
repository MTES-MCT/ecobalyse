module Page.Explore.TextileProducts exposing (table)

import Area
import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium as DyeingMedium
import Data.Textile.Process as Process
import Data.Textile.Product as Product exposing (Product)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


withTitle : String -> Html msg
withTitle str =
    span [ title str ] [ text str ]


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
    , { label = "Poids"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.kg product.mass ]
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
    , { label = "Surface"
      , toCell =
            \{ mass, surfaceMass } ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Mass.inGrams mass
                        / Unit.surfaceMassToFloat surfaceMass
                        |> Area.squareMeters
                        |> Format.squareMetters
                    ]
      }
    , { label = "Volume"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.m3 product.endOfLife.volume ]
      }
    , { label = "Etoffe (type)"
      , toCell =
            \product ->
                case product.fabric of
                    Product.Knitted _ ->
                        text "Tricotée"

                    Product.Weaved _ _ ->
                        text "Tissée"
      }
    , { label = "Etoffe (procédé)"
      , toCell = Product.getFabricProcess >> .name >> withTitle
      }
    , { label = "Délavage"
      , toCell =
            \product ->
                if product.making.fadable then
                    db.processes
                        |> Process.loadWellKnown
                        |> Result.map (.fading >> .name >> withTitle)
                        |> Result.withDefault (text "Erreur, procédé de délavage introuvable")

                else
                    text "N/A"
      }
    , { label = "Type de teinture"
      , toCell =
            \{ dyeing } ->
                text <| DyeingMedium.toLabel dyeing.defaultMedium
      }
    , { label = "Confection (taux de perte)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.splitAsPercentage product.making.pcrWaste ]
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
      , toCell = .use >> .ironingProcess >> .name >> withTitle
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = .use >> .nonIroningProcess >> .name >> withTitle
      }
    , { label = "Séchage électrique"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.splitAsPercentage product.use.ratioDryer ]
      }
    , { label = "Repassage (part)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.splitAsPercentage product.use.ratioIroning ]
      }
    , { label = "Repassage (temps)"
      , toCell =
            \product ->
                div [ classList [ ( "text-end", not detailed ) ] ]
                    [ Format.hours product.use.timeIroning ]
      }
    ]
