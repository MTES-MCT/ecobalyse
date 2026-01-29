module App exposing
    ( Msg(..)
    , PageUpdate
    , apply
    , createUpdate
    , mapSession
    , mapToCmd
    , notifyError
    , notifyInfo
    , notifyInfoIf
    , notifySuccess
    , notifyWarning
    , toCmd
    , withAppMsgs
    , withCmds
    )

{-| This module defines general app messages that can be sent from pages to the Main module.
-}

import Data.Notification as Notification exposing (Notification)
import Data.Session as Session exposing (Session)
import Task
import Toast


{-| Global app messages.
-}
type Msg
    = AddToast Notification
    | CloseMobileNavigation
    | CloseNotification Session.Notification
    | LoadUrl String
    | OpenMobileNavigation
    | ReloadPage
    | ResetSessionStore
    | SwitchVersion
    | ToastMsg Toast.Msg


{-| A page module update result that may carry app messages.
-}
type alias PageUpdate model msg =
    { appMsgs : List Msg
    , cmd : Cmd msg
    , model : model
    , session : Session
    }


{-| Apply a page module update fn to a PageUpdate.
-}
apply : (Session -> msg -> model -> PageUpdate model msg) -> msg -> PageUpdate model msg -> PageUpdate model msg
apply update msg { appMsgs, cmd, model, session } =
    model
        |> update session msg
        |> withAppMsgs appMsgs
        |> withCmds [ cmd ]


{-| Initialize a PageUpdate from a session and a model.
-}
createUpdate : Session -> model -> PageUpdate model msg
createUpdate session model =
    { appMsgs = []
    , cmd = Cmd.none
    , model = model
    , session = session
    }


{-| Map a PageUpdate session.
-}
mapSession : (Session -> Session) -> PageUpdate model msg -> PageUpdate model msg
mapSession fn { appMsgs, cmd, model, session } =
    { appMsgs = appMsgs
    , cmd = cmd
    , model = model
    , session = fn session
    }


{-| Map PageUpdate app messages to a final single command. The mapper function is used to
map the app messages to a more general message type, eg. the root Msg from the Main module.
-}
mapToCmd : (Msg -> destMsg) -> PageUpdate model msg -> Cmd destMsg
mapToCmd mapper =
    .appMsgs >> List.map (toCmd mapper) >> Cmd.batch


notify : Notification -> PageUpdate model msg -> PageUpdate model msg
notify notification =
    withAppMsgs [ AddToast notification ]


notifyError : String -> String -> PageUpdate model msg -> PageUpdate model msg
notifyError title message =
    notify <| Notification.error title message


notifyInfo : String -> PageUpdate model msg -> PageUpdate model msg
notifyInfo message =
    notify <| Notification.info message


notifyInfoIf : Bool -> String -> PageUpdate model msg -> PageUpdate model msg
notifyInfoIf bool message =
    if bool then
        notifyInfo message

    else
        identity


notifySuccess : String -> PageUpdate model msg -> PageUpdate model msg
notifySuccess message =
    notify <| Notification.success message


notifyWarning : String -> PageUpdate model msg -> PageUpdate model msg
notifyWarning message =
    notify <| Notification.warning message


toCmd : (Msg -> destMsg) -> Msg -> Cmd destMsg
toCmd mapper appMsg =
    Task.perform (\_ -> mapper appMsg) (Task.succeed ())


{-| Add app messages to a PageUpdate.
-}
withAppMsgs : List Msg -> PageUpdate model msg -> PageUpdate model msg
withAppMsgs appMsgs pageUpdate =
    { pageUpdate | appMsgs = pageUpdate.appMsgs ++ appMsgs }


{-| Add commands to a PageUpdate.
-}
withCmds : List (Cmd msg) -> PageUpdate model msg -> PageUpdate model msg
withCmds commands pageUpdate =
    { pageUpdate | cmd = Cmd.batch [ pageUpdate.cmd, Cmd.batch commands ] }
