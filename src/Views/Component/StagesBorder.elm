module Views.Component.StagesBorder exposing (style)

import Html
import Html.Attributes as Attrs


style : String -> Html.Attribute msg
style color =
    Attrs.style "border-left" ("5px " ++ color ++ " solid")
