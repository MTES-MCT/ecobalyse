module Page.Explore.Products exposing (details, view)

import Data.Db as Db exposing (Db)
import Data.Product as Product exposing (Product)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


table : { detailed : Bool } -> List { label : String, toCell : Product -> Html msg }
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \product ->
                td []
                    [ if detailed then
                        code [] [ text (Product.idToString product.id) ]

                      else
                        a [ Route.href (Route.Explore (Db.Products (Just product.id))) ]
                            [ code [] [ text (Product.idToString product.id) ] ]
                    ]
      }
    , { label = "Nom"
      , toCell = \product -> td [] [ text product.name ]
      }
    , { label = "Masse par défaut"
      , toCell = \product -> td [] [ Format.kg product.mass ]
      }
    , { label = "Taux de perte (PCR)"
      , toCell = \product -> td [] [ Format.ratio product.pcrWaste ]
      }
    , { label = "Type de procédé"
      , toCell =
            \product ->
                td []
                    [ if product.knitted then
                        text "Tricotage"

                      else
                        text "Tissage"
                    ]
      }
    , { label = "Pick-per-meter"
      , toCell =
            \product ->
                td []
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "picks/m" product.ppm
                    ]
      }
    , { label = "Grammage"
      , toCell =
            \product ->
                td []
                    [ if product.knitted then
                        text "N/A"

                      else
                        text <| Format.formatInt "gr/kg" product.grammage
                    ]
      }
    , { label = "Procédé"
      , toCell = \product -> td [] [ text product.fabricProcess.name ]
      }
    , { label = "Confection"
      , toCell = \product -> td [] [ text product.makingProcess.name ]
      }
    , { label = "Nombre de jours porté"
      , toCell = \product -> td [] [ Format.days product.daysOfWear ]
      }
    , { label = "Cycles d'entretien (par défaut)"
      , toCell = \product -> td [] [ product.wearsPerCycle |> String.fromInt |> text ]
      }
    , { label = "Utilisations avant lavage"
      , toCell = \product -> td [] [ text (String.fromInt product.useDefaultNbCycles) ]
      }
    , { label = "Procédé de repassage"
      , toCell = \product -> td [] [ text product.useIroningProcess.name ]
      }
    , { label = "Procédé d'utilisation hors-repassage"
      , toCell = \product -> td [] [ text product.useNonIroningProcess.name ]
      }
    , { label = "Séchage électrique"
      , toCell = \product -> td [] [ Format.ratio product.useRatioDryer ]
      }
    , { label = "Repassage (part)"
      , toCell = \product -> td [] [ Format.ratio product.useRatioIroning ]
      }
    , { label = "Repassage (temps)"
      , toCell = \product -> td [] [ Format.hours product.useTimeIroning ]
      }
    ]


details : Db -> Product -> Html msg
details _ product =
    Table.responsiveDefault [ class "view-details" ]
        [ table { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , toCell product
                        ]
                )
            |> tbody []
        ]


view : List Product -> Html msg
view products =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ table { detailed = False }
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , products
            |> List.map
                (\product ->
                    table { detailed = False }
                        |> List.map (\{ toCell } -> toCell product)
                        |> tr []
                )
            |> tbody []
        ]
