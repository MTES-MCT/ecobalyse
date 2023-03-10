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
    span [ class "icon composed-icon" ]
        [ boat
        , i [ attribute "aria-hidden" "true", class "icon icon-snow" ] []
        ]


build : Html msg
build =
    icon "build"


bus : Html msg
bus =
    icon "truck"


busCooled : Html msg
busCooled =
    span [ class "icon composed-icon" ]
        [ bus
        , i [ attribute "aria-hidden" "true", class "icon icon-snow" ] []
        ]


check : Html msg
check =
    icon "check"


clock : Html msg
clock =
    icon "clock"


checkCircle : Html msg
checkCircle =
    icon "check-circle"


clipboard : Html msg
clipboard =
    icon "clipboard"


day : Html msg
day =
    icon "day"


dialog : Html msg
dialog =
    icon "dialog"


document : Html msg
document =
    icon "document"


dyeing : Html msg
dyeing =
    icon "dyeing"


exclamation : Html msg
exclamation =
    icon "exclamation"


expand : Html msg
expand =
    icon "expand"


fabric : Html msg
fabric =
    icon "fabric"


globe : Html msg
globe =
    icon "globe"


hammer : Html msg
hammer =
    icon "hammer"


info : Html msg
info =
    icon "info"


lab : Html msg
lab =
    icon "lab"


lock : Html msg
lock =
    icon "lock"


mail : Html msg
mail =
    icon "mail"


making : Html msg
making =
    icon "making"


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


question : Html msg
question =
    icon "question"


rail : Html msg
rail =
    icon "rail"


recycle : Html msg
recycle =
    icon "recycle"


search : Html msg
search =
    icon "search"


shrink : Html msg
shrink =
    icon "shrink"


slice : Html msg
slice =
    icon "slice"


stats : Html msg
stats =
    icon "stats"


study : Html msg
study =
    icon "study"


thread : Html msg
thread =
    icon "thread"


times : Html msg
times =
    icon "times"


trash : Html msg
trash =
    icon "trash"


tShirt : Html msg
tShirt =
    icon "tshirt"


use : Html msg
use =
    icon "use"


verticalDots : Html msg
verticalDots =
    icon "dots-vertical"


warning : Html msg
warning =
    icon "warning"


zoomin : Html msg
zoomin =
    icon "zoomin"


zoomout : Html msg
zoomout =
    icon "zoomout"
