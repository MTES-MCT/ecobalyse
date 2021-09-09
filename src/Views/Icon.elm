module Views.Icon exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


icon : String -> Html msg
icon name =
    i [ attribute "aria-hidden" "true", class ("icon icon-" ++ name) ] []


boat : Html msg
boat =
    icon "ship"


bus : Html msg
bus =
    icon "truck"


clipboard : Html msg
clipboard =
    icon "clipboard"


info : Html msg
info =
    icon "info"


exclamation : Html msg
exclamation =
    icon "exclamation"


plane : Html msg
plane =
    icon "plane"
