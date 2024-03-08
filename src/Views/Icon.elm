module Views.Icon exposing
    ( boat
    , boatCooled
    , build
    , bus
    , busCooled
    , cancel
    , check
    , checkCircle
    , clipboard
    , copy
    , exclamation
    , ham
    , info
    , list
    , lock
    , pencil
    , plane
    , plus
    , question
    , search
    , stats
    , trash
    , warning
    , zoomin
    , zoomout
    )

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


cancel : Html msg
cancel =
    icon "cancel"


check : Html msg
check =
    icon "check"


checkCircle : Html msg
checkCircle =
    icon "check-circle"


clipboard : Html msg
clipboard =
    icon "clipboard"


copy : Html msg
copy =
    icon "copy"


exclamation : Html msg
exclamation =
    icon "exclamation"


ham : Html msg
ham =
    icon "ham"


info : Html msg
info =
    icon "info"


list : Html msg
list =
    icon "list"


lock : Html msg
lock =
    icon "lock"


pencil : Html msg
pencil =
    icon "pencil"


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
