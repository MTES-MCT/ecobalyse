port module Ports exposing
    ( appStarted
    , copyToClipboard
    , saveStore
    , scrollTo
    , selectInputText
    , storeChanged
    )

-- Outgoing


port appStarted : () -> Cmd msg


port saveStore : String -> Cmd msg


port copyToClipboard : String -> Cmd msg


port scrollTo : { x : Float, y : Float } -> Cmd msg


port selectInputText : String -> Cmd msg



-- Incoming


port storeChanged : (String -> msg) -> Sub msg
