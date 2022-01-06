module Page.Explore.Countries exposing (..)

import Data.Country as Country exposing (Country)
import Html exposing (..)
import Html.Attributes exposing (..)


view : List Country -> Html msg
view countries =
    text "countries"
