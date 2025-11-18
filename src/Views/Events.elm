module Views.Events exposing (onDragLeave, onDragOver, onDragStart, onDrop)

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Decode


onDragStart : msg -> Attribute msg
onDragStart msg =
    Events.on "dragstart" <|
        Decode.succeed msg


onDragOver : msg -> Attribute msg
onDragOver msg =
    Events.preventDefaultOn "dragover" <|
        Decode.succeed ( msg, True )


onDragLeave : msg -> Attribute msg
onDragLeave msg =
    Events.on "dragleave" <|
        Decode.succeed msg


onDrop : msg -> Attribute msg
onDrop msg =
    Events.preventDefaultOn "drop" <|
        Decode.succeed ( msg, True )
