module Views.Icon exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


icon : String -> Html msg
icon name =
    i [ attribute "aria-hidden" "true", class ("icon icon-" ++ name) ] []


boat : Html msg
boat =
    icon "ship"


boatCooled : Html msg
boatCooled =
    i [ attribute "aria-hidden" "true", class "icon icon-ship" ]
        [ snow ]


build : Html msg
build =
    icon "build"


bus : Html msg
bus =
    icon "truck"


busCooled : Html msg
busCooled =
    i [ attribute "aria-hidden" "true", class "icon icon-truck" ]
        [ snow ]


check : Html msg
check =
    icon "check"


checkCircle : Html msg
checkCircle =
    icon "check-circle"


clipboard : Html msg
clipboard =
    icon "clipboard"


exclamation : Html msg
exclamation =
    icon "exclamation"


ham : Html msg
ham =
    icon "ham"


info : Html msg
info =
    icon "info"


lock : Html msg
lock =
    icon "lock"


plane : Html msg
plane =
    icon "plane"


plus : Html msg
plus =
    icon "plus"


question : Html msg
question =
    icon "question"


search : Html msg
search =
    icon "search"


snow : Html msg
snow =
    icon "snow"


stats : Html msg
stats =
    icon "stats"


trash : Html msg
trash =
    icon "trash"


warning : Html msg
warning =
    icon "warning"


zoomin : Html msg
zoomin =
    icon "zoomin"


zoomout : Html msg
zoomout =
    icon "zoomout"
