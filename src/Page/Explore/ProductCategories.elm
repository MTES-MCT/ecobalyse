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


table : Session -> Scope.GenericScope -> { detailed : Bool, scope : Scope } -> Table ProductCategory String msg
table { db } genericScope _ =
    { filename = Scope.toStringGeneric genericScope ++ "-product-categories"
    , toId = .id >> ProductCategory.idToString
    , toRoute = \{ id } -> Route.Explore (Scope.Generic genericScope) (Dataset.ProductCategory genericScope (Just id))
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
        , { key = "Consommations"
          , toValues = consumptionsFacetValues db.processes
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
        , { label = "Consommations"
          , toValue = Table.StringValue <| consumptionsLabel db.processes
          , toCell = consumptionsLabel db.processes >> text
          }
        ]
    }


emptyLabel : String
emptyLabel =
    "—"


consumptionProcessName : List Process.Process -> ProductCategory.DefaultConsumption -> String
consumptionProcessName processes { processId } =
    case processes |> Process.findById processId |> Result.map Process.getDisplayName of
        Err err ->
            "Erreur\u{00A0}: " ++ err

        Ok displayName ->
            displayName


consumptionsFacetValues : List Process.Process -> ProductCategory -> List String
consumptionsFacetValues processes product =
    if List.isEmpty product.consumptions then
        [ emptyLabel ]

    else
        product.consumptions
            |> List.map (consumptionProcessName processes)


consumptionsLabel : List Process.Process -> ProductCategory -> String
consumptionsLabel processes product =
    if List.isEmpty product.consumptions then
        emptyLabel

    else
        product.consumptions
            |> List.map (consumptionProcessName processes)
            |> String.join ", "


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
            emptyLabel
