port module Ports exposing (..)

-- Outgoing


port saveStore : String -> Cmd msg


port copyToClipboard : String -> Cmd msg



-- Incoming


port storeChanged : (String -> msg) -> Sub msg
