module Views.Comparator exposing
    ( ComparisonType(..)
    , chartSeries
    , comparisonTypeToString
    , view
    )

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Complement as Complement
import Data.Component as Component
import Data.Db exposing (Db)
import Data.Food.Recipe as Recipe
import Data.Generic.Simulator as GenericSimulator
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition, Definitions)
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Textile.Simulator as TextileSimulator
import Data.Unit as Unit
import Dict
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Result.Extra as RE
import Set
import Views.Alert as Alert
import Views.Container as Container
import Views.Events as Events


type alias Config msg =
    { bookmarkBeingOvered : Maybe Bookmark
    , comparisonType : ComparisonType
    , impact : Definition
    , onDragLeaveBookmark : msg
    , onDragOverBookmark : Bookmark -> msg
    , onDragStartBookmark : Bookmark -> msg
    , onDropBookmark : Bookmark -> msg
    , selectAll : msg
    , selectNone : msg
    , session : Session
    , switchComparisonType : ComparisonType -> msg
    , toggle : Bookmark -> (Bool -> msg)
    }


type ComparisonType
    = IndividualImpacts
    | Stages
    | Subscores
    | Total


type alias ChartsData =
    { complementsImpact : Complement.ComplementsImpacts
    , impacts : Impact.Impacts
    , label : String
    , stagesImpacts : Impact.StagesImpacts
    }


type alias Requirements =
    { componentConfig : Component.Config
    , db : Db
    }


view : Config msg -> Html msg
view config =
    Container.fluid []
        [ div [ class "row" ]
            [ sidebarView config
                |> div [ class "col-lg-4 border-end fs-7 p-0" ]
            , comparatorView config
                |> div [ class "col-lg-8 px-4 py-2 overflow-auto", style "min-height" "500px" ]
            ]
        ]


sidebarView : Config msg -> List (Html msg)
sidebarView config =
    [ div [ class "p-2 ps-3 mb-0 text-muted" ]
        [ text "Sélectionnez des simulations pour les comparer"
        ]
    , div [ class "text-center" ]
        [ button [ class "btn btn-sm btn-link pt-0", onClick config.selectAll ] [ text "tout sélectionner" ]
        , button [ class "btn btn-sm btn-link pt-0", onClick config.selectNone ] [ text "tout désélectionner" ]
        ]
    , config.session.store.bookmarks
        |> List.map
            (\bookmark ->
                let
                    ( description, isCompared ) =
                        ( bookmark
                            |> Bookmark.toQueryDescription config.session.db
                        , config.session.store.comparedSimulations
                            |> Set.member (Bookmark.toId bookmark)
                        )
                in
                label
                    [ class "form-check-label list-group-item text-nowrap ps-3 ms-1"
                    , classList [ ( "over", config.bookmarkBeingOvered == Just bookmark ) ]
                    , title description
                    , draggable "true"
                    , Events.onDragStart (config.onDragStartBookmark bookmark)
                    , Events.onDragLeave config.onDragLeaveBookmark
                    , Events.onDragOver (config.onDragOverBookmark bookmark)
                    , Events.onDrop (config.onDropBookmark bookmark)
                    ]
                    [ input
                        [ type_ "checkbox"
                        , class "form-check-input"
                        , onCheck (config.toggle bookmark)
                        , checked isCompared
                        ]
                        []
                    , span [ class "d-inline-flex align-middle gap-2 ps-2" ]
                        [ span [ class "me-2 fw-500" ] [ text bookmark.name ]
                        , if description /= bookmark.name then
                            span [ class "text-muted fs-7" ] [ text description ]

                          else
                            text ""
                        ]
                    ]
            )
        |> div [ class "list-group list-group-flush overflow-x-hidden ComparatorList" ]
    ]


addToComparison : Requirements -> Bookmark -> Result String ChartsData
addToComparison { componentConfig, db } { name, query } =
    case query of
        Bookmark.Food foodQuery ->
            foodQuery
                |> Recipe.compute db
                |> Result.map
                    (\( _, { recipe, total } as results ) ->
                        { complementsImpact = recipe.totalComplementsImpact
                        , impacts = total
                        , label = name
                        , stagesImpacts =
                            results
                                |> Recipe.toStagesImpacts Definition.Ecs
                        }
                    )

        Bookmark.Generic genericScope genericQuery ->
            genericQuery
                |> GenericSimulator.compute
                    { config = componentConfig
                    , db = db
                    , scope = Scope.Generic genericScope
                    }
                |> Result.map
                    (\lifeCycle ->
                        { complementsImpact =
                            lifeCycle.production
                                |> Component.extractComplementsImpacts
                                |> Complement.mapComplements (Maybe.map (Impact.getImpact Definition.Ecs))
                        , impacts = Component.sumLifeCycleImpacts lifeCycle
                        , label = name
                        , stagesImpacts =
                            lifeCycle
                                |> GenericSimulator.toStagesImpacts Definition.Ecs
                        }
                    )

        Bookmark.Textile textileQuery ->
            textileQuery
                |> TextileSimulator.compute db componentConfig
                |> Result.map
                    (\simulator ->
                        { complementsImpact = simulator.complementsImpacts
                        , impacts = simulator.impacts
                        , label = name
                        , stagesImpacts =
                            simulator
                                |> TextileSimulator.toStagesImpacts Definition.Ecs
                        }
                    )


chartSeries : Requirements -> ComparisonType -> Bookmark -> Result String (List { name : String, value : Float })
chartSeries ({ db } as reqs) comparisonType bookmark =
    bookmark
        |> addToComparison reqs
        |> Result.map
            (\chartsData ->
                let
                    entries =
                        case comparisonType of
                            IndividualImpacts ->
                                entriesForIndividualImpacts db.definitions chartsData

                            Stages ->
                                entriesForStages chartsData

                            Subscores ->
                                entriesForSubscores db.definitions chartsData

                            Total ->
                                entriesForTotal chartsData
                in
                entries
                    |> List.map (\{ name, value } -> { name = name, value = value })
            )


comparatorView : Config msg -> List (Html msg)
comparatorView ({ session } as config) =
    let
        charts =
            session.store.bookmarks
                |> List.filterMap
                    (\bookmark ->
                        if Set.member (Bookmark.toId bookmark) session.store.comparedSimulations then
                            Just (addToComparison { componentConfig = session.componentConfig, db = session.db } bookmark)

                        else
                            Nothing
                    )
                |> RE.combine
    in
    [ ((if Session.isAuthenticated session then
            [ ( "Sous-scores", Subscores )
            , ( "Impacts", IndividualImpacts )
            ]

        else
            []
       )
        ++ [ ( "Étapes", Stages )
           , ( "Total", Total )
           ]
      )
        |> List.map
            (\( label, toComparisonType ) ->
                li [ class "TabsTab nav-item", classList [ ( "active", config.comparisonType == toComparisonType ) ] ]
                    [ button
                        [ class "nav-link no-outline border-top-0 py-1"
                        , classList [ ( "active", config.comparisonType == toComparisonType ) ]
                        , onClick (config.switchComparisonType toComparisonType)
                        ]
                        [ text label ]
                    ]
            )
        |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-3 mt-2 px-2" ]
    , case charts of
        Err error ->
            Alert.simple
                { attributes = []
                , close = Nothing
                , content = [ text error ]
                , level = Alert.Danger
                , title = Just "Erreur"
                }

        Ok [] ->
            p [ class "d-flex h-100 justify-content-center align-items-center pb-5" ]
                [ text "Sélectionnez une ou plusieurs simulations pour les comparer" ]

        Ok chartsData ->
            let
                ( class, data ) =
                    case config.comparisonType of
                        IndividualImpacts ->
                            ( "individual-impacts", dataForIndividualImpacts session.db.definitions chartsData )

                        Stages ->
                            ( "stages-impacts", dataForStages chartsData )

                        Subscores ->
                            ( "grouped-impacts", dataForSubscoresImpacts session.db.definitions chartsData )

                        Total ->
                            ( "total-impacts", dataForTotalImpacts chartsData )
            in
            div [ Attr.class <| "h-100 " ++ class ]
                [ node "chart-food-comparator" [ attribute "data" data ] [] ]
    ]


dataForIndividualImpacts : Definitions -> List ChartsData -> String
dataForIndividualImpacts definitions =
    encodeChartSeries <|
        entriesForIndividualImpacts definitions
            >> Encode.list Impact.encodeAggregatedScoreChartEntry


dataForStages : List ChartsData -> String
dataForStages =
    encodeChartSeries <|
        entriesForStages
            >> Encode.list Impact.encodeAggregatedScoreChartEntry


dataForSubscoresImpacts : Definitions -> List ChartsData -> String
dataForSubscoresImpacts definitions =
    encodeChartSeries <|
        entriesForSubscores definitions
            >> Encode.list Impact.encodeAggregatedScoreChartEntry


dataForTotalImpacts : List ChartsData -> String
dataForTotalImpacts =
    encodeChartSeries <|
        entriesForTotal
            >> Encode.list Impact.encodeAggregatedScoreChartEntry


encodeChartSeries : (ChartsData -> Encode.Value) -> List ChartsData -> String
encodeChartSeries encodeChartsData =
    Encode.list
        (\chartsDatum ->
            Encode.object
                [ ( "label", Encode.string chartsDatum.label )
                , ( "data", encodeChartsData chartsDatum )
                ]
        )
        >> Encode.encode 0


entriesForIndividualImpacts : Definitions -> ChartsData -> List { color : String, name : String, value : Float }
entriesForIndividualImpacts definitions { complementsImpact, impacts } =
    let
        labelToOrder =
            [ "Changement climatique"
            , "Biodiversité locale"
            , "Acidification"
            , "Eutrophisation terrestre"
            , "Eutrophisation eaux douces"
            , "Eutrophisation marine"
            , "Écotoxicité de l'eau douce, corrigée"
            , "Utilisation des sols"
            , "Appauvrissement de la couche d'ozone"
            , "Radiations ionisantes"
            , "Formation d'ozone photochimique"
            , "Toxicité humaine - non-cancer, corrigée"
            , "Toxicité humaine - cancer, corrigée"
            , "Particules"
            , "Utilisation de ressources en eau"
            , "Utilisation de ressources fossiles"
            , "Utilisation de ressources minérales et métalliques"
            ]
                |> List.indexedMap (\index label -> ( label, index ))
                |> Dict.fromList

        labelComparison entry1 entry2 =
            let
                getOrder entry =
                    Dict.get entry.name labelToOrder

                label1Order =
                    getOrder entry1

                label2Order =
                    getOrder entry2
            in
            case ( label1Order, label2Order ) of
                ( Just index1, Just index2 ) ->
                    if index1 > index2 then
                        GT

                    else
                        LT

                _ ->
                    EQ
    in
    Complement.complementsImpactAsChartEntries complementsImpact
        ++ (impacts
                |> Impact.getAggregatedScoreData definitions .ecoscoreData
                |> List.sortWith labelComparison
           )
        |> List.reverse


entriesForStages : ChartsData -> List { color : String, name : String, value : Float }
entriesForStages { stagesImpacts } =
    stagesImpacts
        |> Impact.stagesImpactsAsChartEntries
        |> List.reverse


entriesForSubscores : Definitions -> ChartsData -> List { color : String, name : String, value : Float }
entriesForSubscores definitions { complementsImpact, impacts } =
    impacts
        |> Impact.toProtectionAreas definitions
        |> (\{ biodiversity, climate, health, resources } ->
                List.reverse
                    [ Complement.totalComplementsImpactAsChartEntry complementsImpact
                    , { color = "#9025be", name = "Climat", value = Unit.impactToFloat climate }
                    , { color = "#00b050", name = "Biodiversité", value = Unit.impactToFloat biodiversity }
                    , { color = "#ffc000", name = "Santé environnementale", value = Unit.impactToFloat health }
                    , { color = "#0070c0", name = "Ressource", value = Unit.impactToFloat resources }
                    ]
           )


entriesForTotal : ChartsData -> List { color : String, name : String, value : Float }
entriesForTotal { impacts } =
    [ { color = "#333333"
      , name = "Impact total"
      , value =
            impacts
                |> Impact.getImpact Definition.Ecs
                |> Unit.impactToFloat
      }
    ]


comparisonTypeToString : ComparisonType -> String
comparisonTypeToString comparisonType =
    case comparisonType of
        IndividualImpacts ->
            "Impacts"

        Stages ->
            "Étapes"

        Subscores ->
            "Sous-scores"

        Total ->
            "Total"
