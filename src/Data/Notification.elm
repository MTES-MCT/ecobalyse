module Data.Notification exposing
    ( Level(..)
    , Notification
    , error
    , info
    , success
    , warning
    )


type alias Notification =
    { level : Level
    , message : String
    , persistent : Bool
    , title : Maybe String
    }


type Level
    = Error
    | Info
    | Success
    | Warning


error : String -> Notification
error message =
    { level = Error
    , message = message
    , persistent = True
    , title = Nothing
    }


info : String -> Notification
info message =
    { level = Info
    , message = message
    , persistent = False
    , title = Nothing
    }


success : String -> Notification
success message =
    { level = Success
    , message = message
    , persistent = False
    , title = Nothing
    }


warning : String -> Notification
warning message =
    { level = Warning
    , message = message
    , persistent = False
    , title = Nothing
    }
