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


exclamation : Html msg
exclamation =
    icon "exclamation"


info : Html msg
info =
    icon "info"


pencil : Html msg
pencil =
    icon "pencil"


plane : Html msg
plane =
    icon "plane"


search : Html msg
search =
    icon "search"
