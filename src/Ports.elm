port module Ports exposing
    ( addBodyClass
    , appStarted
    , copyToClipboard
    , loadRapidoc
    , removeBodyClass
    , saveStore
    , scrollIntoView
    , scrollTo
    , sendPlausibleEvent
    , storeChanged
    )

import Json.Encode as Encode



-- Outgoingas


port addBodyClass : String -> Cmd msg


port appStarted : () -> Cmd msg


port copyToClipboard : String -> Cmd msg


port loadRapidoc : String -> Cmd msg


port removeBodyClass : String -> Cmd msg


port saveStore : String -> Cmd msg


port scrollIntoView : String -> Cmd msg


port scrollTo : { x : Float, y : Float } -> Cmd msg


port sendPlausibleEvent : { name : String, properties : List ( String, Encode.Value ) } -> Cmd msg



-- Incoming


port storeChanged : (String -> msg) -> Sub msg
