port module Ports exposing
    ( appStarted
    , copyToClipboard
    , saveStore
    , scrollTo
    , storeChanged
    )

-- Outgoing


port appStarted : () -> Cmd msg


port saveStore : String -> Cmd msg


port copyToClipboard : String -> Cmd msg


port scrollTo : { x : Float, y : Float } -> Cmd msg



-- Incoming


port storeChanged : (String -> msg) -> Sub msg
