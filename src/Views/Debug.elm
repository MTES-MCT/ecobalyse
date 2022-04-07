module Views.Debug exposing (view)

import DebugToJson
import Html exposing (..)


view : List (Attribute msg) -> a -> Html msg
view attrs =
    Debug.toString
        >> DebugToJson.pp
        >> text
        >> List.singleton
        >> pre attrs
