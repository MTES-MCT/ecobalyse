module Data.Notification exposing
    ( Level(..)
    , Notification
    , error
    , info
    , success
    , toAlertLevel
    , warning
    )

import Views.Alert as Alert


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


error : String -> String -> Notification
error title message =
    { level = Error
    , message = message
    , persistent = True
    , title = Just title
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


toAlertLevel : Level -> Alert.Level
toAlertLevel level =
    case level of
        Error ->
            Alert.Danger

        Info ->
            Alert.Info

        Success ->
            Alert.Success

        Warning ->
            Alert.Warning
