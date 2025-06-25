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


clipboard : Html msg
clipboard =
    icon "clipboard"


copy : Html msg
copy =
    icon "copy"


fileExport : Html msg
fileExport =
    icon "file-export"


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


material : Html msg
material =
    icon "material"


pencil : Html msg
pencil =
    icon "pencil"


plane : Html msg
plane =
    icon "plane"


plus : Html msg
plus =
    icon "plus"


puzzle : Html msg
puzzle =
    icon "puzzle"


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


transform : Html msg
transform =
    icon "transform"


warning : Html msg
warning =
    icon "warning"
