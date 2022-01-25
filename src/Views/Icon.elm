module Views.Icon exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


icon : String -> Html msg
icon name =
    i [ attribute "aria-hidden" "true", class ("icon icon-" ++ name) ] []


boat : Html msg
boat =
    icon "ship"


build : Html msg
build =
    icon "build"


bus : Html msg
bus =
    icon "truck"


checkCircle : Html msg
checkCircle =
    icon "check-circle"


clipboard : Html msg
clipboard =
    icon "clipboard"


dialog : Html msg
dialog =
    icon "dialog"


document : Html msg
document =
    icon "document"


exclamation : Html msg
exclamation =
    icon "exclamation"


expand : Html msg
expand =
    icon "expand"


globe : Html msg
globe =
    icon "globe"


hammer : Html msg
hammer =
    icon "hammer"


info : Html msg
info =
    icon "info"


mail : Html msg
mail =
    icon "mail"


pencil : Html msg
pencil =
    icon "pencil"


plane : Html msg
plane =
    icon "plane"


question : Html msg
question =
    icon "question"


search : Html msg
search =
    icon "search"


shrink : Html msg
shrink =
    icon "shrink"


study : Html msg
study =
    icon "study"


warning : Html msg
warning =
    icon "warning"


zoomin : Html msg
zoomin =
    icon "zoomin"


zoomout : Html msg
zoomout =
    icon "zoomout"
