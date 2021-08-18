module Views.Page exposing (ActivePage(..), Config, frame)

import Browser exposing (Document)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route


type ActivePage
    = Home
    | Simulator
    | Editorial String
    | Other


type alias Config =
    { session : Session
    , activePage : ActivePage
    }


frame : Config -> ( String, List (Html msg) ) -> Document msg
frame config ( title, content ) =
    { title = title ++ " | wikicarbone"
    , body =
        [ div []
            [ navbar config
            , main_ [ class "container mt-5" ] content
            ]
        ]
    }


navbar : Config -> Html msg
navbar { activePage } =
    let
        linkIf page route caption =
            if page == activePage then
                text caption

            else
                a [ class "text-light", Route.href route ] [ text caption ]
    in
    header [ class "navbar navbar-dark bg-dark text-light shadow-sm" ]
        [ div [ class "container" ]
            [ h1 [ class "display-5 fw-bold" ] [ a [ class "text-light", Route.href Route.Home ] [ text "wikicarbone" ] ]
            , [ linkIf Home Route.Home "Home"
              , linkIf Simulator Route.Simulator "Simulator"
              , linkIf (Editorial "methodology") (Route.Editorial "methodology") "Methodology"
              , a [ class "text-light", href "https://github.com/MTES-MCT/wikicarbone/" ] [ text "Source" ]
              ]
                |> List.intersperse (text " | ")
                |> nav []
            ]
        ]
