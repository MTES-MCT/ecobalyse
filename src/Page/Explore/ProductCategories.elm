module Page.Explore.ProductCategories exposing (table)

import Data.Component.ProductCategory as ProductCategory exposing (ProductCategory)
import Data.Dataset as Dataset
import Data.Process as Process
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Text as Text
import Html exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route


table : Session -> { detailed : Bool, scope : Scope } -> Table ProductCategory String msg
table { db } { scope } =
    let
        genericScope =
            scope
                |> Scope.toGenericScope
                |> Maybe.withDefault Scope.Object
    in
    { filename = Scope.toString scope ++ "-product-categories"
    , toId = .id >> ProductCategory.idToString
    , toRoute = \{ id } -> Route.Explore scope (Dataset.ProductCategory genericScope (Just id))
    , toSearchableWords = ProductCategory.toSearchableString >> Text.toWords
    , facets =
        [ { key = "Transport réfrigéré"
          , toValues =
                \{ cooling } ->
                    [ Text.yesNo cooling ]
          }
        , { key = "Distribution"
          , toValues = distributionLabel db.processes >> List.singleton
          }
        ]
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> ProductCategory.idToString
          , toCell =
                \product ->
                    code [] [ text (ProductCategory.idToString product.id) ]
          }
        , { label = "Catégorie de produit"
          , toValue = Table.StringValue .label
          , toCell = .label >> text
          }
        , { label = "Transport réfrigéré"
          , toValue = Table.StringValue <| .cooling >> Text.yesNo
          , toCell = .cooling >> Text.yesNo >> text
          }
        , { label = "Distribution"
          , toValue = Table.StringValue <| distributionLabel db.processes
          , toCell = distributionLabel db.processes >> text
          }
        ]
    }


distributionLabel : List Process.Process -> ProductCategory -> String
distributionLabel processes product =
    case product.distribution of
        Just processId ->
            case processes |> Process.findById processId |> Result.map Process.getDisplayName of
                Err err ->
                    "Erreur\u{00A0}: " ++ err

                Ok displayName ->
                    displayName

        Nothing ->
            "—"
