port module Ports exposing (saveStore, storeChanged)


port saveStore : String -> Cmd msg


port storeChanged : (String -> msg) -> Sub msg
