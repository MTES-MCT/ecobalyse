port module Ports exposing
    ( addBodyClass
    , appStarted
    , copyToClipboard
    , loadRapidoc
    , removeBodyClass
    , saveStore
    , scrollIntoView
    , scrollTo
    , sendPosthogEvent
    , storeChanged
    )

-- Outgoing


port addBodyClass : String -> Cmd msg


port appStarted : () -> Cmd msg


port copyToClipboard : String -> Cmd msg


port loadRapidoc : String -> Cmd msg


port removeBodyClass : String -> Cmd msg


port saveStore : String -> Cmd msg


port scrollIntoView : String -> Cmd msg


port scrollTo : { x : Float, y : Float } -> Cmd msg


port sendPosthogEvent : { name : String, properties : List ( String, String ) } -> Cmd msg



-- Incoming


port storeChanged : (String -> msg) -> Sub msg
