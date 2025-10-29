module Views.Sidebar exposing (Config, view)

import Data.Bookmark exposing (Bookmark)
import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition, Trigram)
import Data.Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)
import Views.Bookmark as BookmarkView
import Views.Impact as ImpactView
import Views.ImpactTabs as ImpactTabs
import Views.Score as ScoreView


type alias Config msg =
    { activeBookmarkTab : BookmarkView.ActiveTab
    , bookmarkBeingRenamed : Maybe Bookmark
    , bookmarkName : String
    , compareBookmarks : msg
    , copyToClipBoard : String -> msg
    , customScoreInfo : Maybe (Html msg)
    , deleteBookmark : Bookmark -> msg
    , impactTabsConfig : Maybe (ImpactTabs.Config msg)
    , productMass : Mass
    , saveBookmark : msg
    , scope : Scope
    , selectedImpact : Definition
    , session : Session
    , switchBookmarkTab : BookmarkView.ActiveTab -> msg
    , switchImpact : Result String Trigram -> msg
    , totalImpacts : Impacts
    , totalImpactsWithoutDurability : Maybe Impacts
    , updateBookmarkName : String -> msg
    , updateRenamedBookmarkName : Bookmark -> String -> msg
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
            , mass = config.productMass
            , score = config.totalImpacts
            , scoreWithoutDurability = config.totalImpactsWithoutDurability
            }
        , case config.impactTabsConfig of
            Just impactTabsConfig ->
                ImpactTabs.view db.definitions impactTabsConfig

            Nothing ->
                text ""
        , BookmarkView.view
            { activeTab = config.activeBookmarkTab
            , bookmarkBeingRenamed = config.bookmarkBeingRenamed
            , bookmarkName = config.bookmarkName
            , compare = config.compareBookmarks
            , copyToClipBoard = config.copyToClipBoard
            , delete = config.deleteBookmark
            , impact = config.selectedImpact
            , save = config.saveBookmark
            , scope = config.scope
            , session = config.session
            , switchTab = config.switchBookmarkTab
            , update = config.updateBookmarkName
            , updateRenamedBookmarkName = config.updateRenamedBookmarkName
            }
        ]
