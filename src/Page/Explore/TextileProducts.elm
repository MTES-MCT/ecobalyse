module Page.Explore.TextileProducts exposing (table)

import Area
import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium as DyeingMedium
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
table _ { detailed, scope } =
    [ { label = "Identifiant"
      , toCell =
            \product ->
                if detailed then
                    code [] [ text (Product.idToString product.id) ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.TextileProducts (Just product.id))) ]
                        [ code [] [ text (Product.idToString product.id) ] ]
      }
    , { label = "Produit(s) concerné(s)"
      , toCell = .name >> text
      }
    , { label = "Poids"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.kg product.mass ]
      }
    , { label = "Titrage"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.yarnSize (Product.defaultYarnSize product.surfaceMass) ]
      }
    , { label = "Grammage"
      , toCell =
            \{ surfaceMass } ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.surfaceMass surfaceMass
                    ]
      }
    , { label = "Surface"
      , toCell =
            \{ mass, surfaceMass } ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Mass.inGrams mass
                        / toFloat (Unit.surfaceMassInGramsPerSquareMeters surfaceMass)
                        |> Area.squareMeters
                        |> Format.squareMetters
                    ]
      }
    , { label = "Volume"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.m3 product.endOfLife.volume ]
      }
    , { label = "Etoffe (type)"
      , toCell =
            \product ->
                case product.fabric of
                    Product.Knitted _ ->
                        text "Tricotée"

                    Product.Weaved _ ->
                        text "Tissée"
      }
    , { label = "Etoffe (procédé)"
      , toCell = Product.getFabricProcess >> .name >> withTitle
      }
    , { label = "Délavage"
      , toCell =
            \product ->
                if product.making.fadable then
                    text "oui"

                else
                    text "non"
      }
    , { label = "Type de teinture"
      , toCell =
            \{ dyeing } ->
                text <| DyeingMedium.toLabel dyeing.defaultMedium
      }
    , { label = "Confection (complexité)"
      , toCell = .making >> .complexity >> Product.makingComplexityAsString >> text
      }
    , { label = "Confection (# minutes)"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Product.getMakingDurationInMinutes product |> String.fromInt |> text ]
      }
    , { label = "Confection (taux de perte)"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.splitAsPercentage product.making.pcrWaste ]
      }
    , { label = "Nombre de jours porté"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.days product.use.daysOfWear ]
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ text <| String.fromInt product.use.wearsPerCycle ]
      }
    , { label = "Utilisations avant lavage"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
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
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.splitAsPercentage product.use.ratioDryer ]
      }
    , { label = "Repassage (part)"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.splitAsPercentage product.use.ratioIroning ]
      }
    , { label = "Repassage (temps)"
      , toCell =
            \product ->
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.hours product.use.timeIroning ]
      }
    ]
