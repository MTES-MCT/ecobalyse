module Views.Version exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Request.Version exposing (VersionData)


view : Maybe VersionData -> Html msg
view maybeVersion =
    let
        ( label, caption, level ) =
            case maybeVersion of
                Just { hash, tag } ->
                    case tag of
                        Just t ->
                            ( t, "Version " ++ t, "info" )

                        Nothing ->
                            ( hash, "Commit hash: " ++ hash, "warning" )

                Nothing ->
                    ( "N/A", "Version inconnue", "light" )
    in
    small
        [ class <| "badge text-truncate px-1 text-bg-" ++ level
        , style "width" "55px"
        , style "min-width" "55px"
        , style "max-width" "55px"
        , title caption
        ]
        [ text label ]
