module Views.Sidebar exposing (Config, view)

import Data.Bookmark exposing (Bookmark)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definition, Definitions, Trigram)
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass exposing (Mass)
import Views.Bookmark as BookmarkView
import Views.Impact as ImpactView
import Views.ImpactTabs as ImpactTabs
import Views.Score as ScoreView


type alias Config msg =
    { session : Session
    , scope : Scope

    -- Impact selector
    , selectedImpact : Definition
    , switchImpact : Result String Trigram -> msg

    -- Score
    , customScoreInfo : Maybe (Html msg)
    , productMass : Mass
    , totalImpacts : Impacts

    -- Ecotox weighting customization
    , updateEcotoxWeighting : Maybe Unit.Ratio -> msg

    -- Impacts tabs
    , impactTabsConfig : ImpactTabs.Config msg

    -- Bookmarks
    , activeBookmarkTab : BookmarkView.ActiveTab
    , bookmarkName : String
    , copyToClipBoard : String -> msg
    , compareBookmarks : msg
    , deleteBookmark : Bookmark -> msg
    , saveBookmark : msg
    , updateBookmarkName : String -> msg
    , switchBookmarkTab : BookmarkView.ActiveTab -> msg
    }


view : Config msg -> Html msg
view config =
    let
        db =
            config.session.db
    in
    div
        [ class "d-flex flex-column gap-3 mb-3 sticky-md-top"
        , style "top" "7px"
        ]
        [ if Session.isAuthenticated config.session then
            ImpactView.selector
                db.definitions
                { selectedImpact = config.selectedImpact.trigram
                , switchImpact = config.switchImpact
                }

          else
            text ""
        , ScoreView.view
            { customInfo = config.customScoreInfo
            , impactDefinition = config.selectedImpact
            , score = config.totalImpacts
            , mass = config.productMass
            }
        , if config.selectedImpact.trigram == Definition.Ecs && Session.isAuthenticated config.session then
            db.definitions
                |> ecotoxWeightingField config.updateEcotoxWeighting

          else
            text ""
        , config.impactTabsConfig
            |> ImpactTabs.view db.definitions
        , BookmarkView.view
            { session = config.session
            , activeTab = config.activeBookmarkTab
            , bookmarkName = config.bookmarkName
            , impact = config.selectedImpact
            , scope = config.scope
            , copyToClipBoard = config.copyToClipBoard
            , compare = config.compareBookmarks
            , delete = config.deleteBookmark
            , save = config.saveBookmark
            , update = config.updateBookmarkName
            , switchTab = config.switchBookmarkTab
            }
        ]


ecotoxWeightingField : (Maybe Unit.Ratio -> msg) -> Definitions -> Html msg
ecotoxWeightingField updateEcotoxWeighting impactDefinitions =
    let
        etfCWeighting =
            impactDefinitions
                |> Definition.get Definition.EtfC
                |> .ecoscoreData
                |> Maybe.map (.weighting >> Unit.ratioToFloat)
                |> Maybe.withDefault 0

        fromPercentString =
            String.toFloat >> Maybe.map (Unit.ratio << (\x -> x / toFloat 100))

        toPercentString =
            Unit.ratioToFloat >> (*) 100 >> String.fromFloat

        round2 =
            (*) 100 >> round >> (\x -> toFloat x / toFloat 100)
    in
    -- FIXME: temporarily hidden for launch
    div [ class "d-none row d-flex align-items-center" ]
        [ div [ class "col-sm-6 d-flex align-items-center pt-1" ]
            [ label [ for "ecotox-weighting", class "form-label text-truncate" ]
                [ text "Pondération Ecotox" ]
            ]
        , div [ class "col-sm-6 d-flex align-items-center" ]
            [ div
                [ class "input-group" ]
                [ input
                    [ type_ "number"
                    , id "ecotox-weighting"
                    , class "form-control text-end"
                    , Attr.min (toPercentString Impact.minEcotoxWeighting)
                    , Attr.max (toPercentString Impact.maxEcotoxWeighting)

                    -- WARNING: be careful when reordering attributes: for obscure reasons,
                    -- the `value` one MUST be set AFTER the `step` one.
                    , step "0.01"
                    , round2 (etfCWeighting * 100) |> String.fromFloat |> value
                    , onInput (fromPercentString >> updateEcotoxWeighting)
                    ]
                    []
                , span [ class "input-group-text" ] [ text "%" ]
                ]
            ]
        ]
