module Views.Icon exposing
    ( boat
    , boatCooled
    , bus
    , busCooled
    , cancel
    , check
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
    , save
    , search
    , stats
    , trash
    , undo
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


save : Html msg
save =
    icon "save"


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


undo : Html msg
undo =
    icon "undo"


warning : Html msg
warning =
    icon "warning"


zoomin : Html msg
zoomin =
    icon "zoomin"


zoomout : Html msg
zoomout =
    icon "zoomout"
