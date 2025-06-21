module App exposing
    ( Msg(..)
    , PageUpdate
    , addAppMsg
    , addCmd
    , initPageUpdate
    , toAppCmd
    )

{-| This module defines general app messages that can be sent from pages to the Main module.
-}

import Data.Session as Session exposing (Session)
import Task


type Msg
    = CloseMobileNavigation
    | CloseNotification Session.Notification
    | LoadUrl String
    | OpenMobileNavigation
    | ReloadPage
    | ResetSessionStore
    | SwitchVersion String


{-| Type for page update results that can include app messages.
-}
type alias PageUpdate model msg =
    { appMsgs : List Msg
    , cmd : Cmd msg
    , model : model
    , session : Session
    }


{-| Initialize a page update with the given session and model.
-}
initPageUpdate : Session -> model -> PageUpdate model msg
initPageUpdate session model =
    { appMsgs = []
    , cmd = Cmd.none
    , model = model
    , session = session
    }


{-| Add a command to the page update.
-}
addCmd : Cmd msg -> PageUpdate model msg -> PageUpdate model msg
addCmd command pageUpdate =
    { pageUpdate | cmd = Cmd.batch [ pageUpdate.cmd, command ] }


{-| Add an app message to the page update.
-}
addAppMsg : Msg -> PageUpdate model msg -> PageUpdate model msg
addAppMsg message pageUpdate =
    { pageUpdate | appMsgs = pageUpdate.appMsgs ++ [ message ] }


{-| Convert page update app messages to a list of app commands.
-}
toAppCmds : (Msg -> appMsg) -> PageUpdate model msg -> List (Cmd appMsg)
toAppCmds mapper { appMsgs } =
    appMsgs |> List.map (\appMsg -> Task.perform (\_ -> mapper appMsg) (Task.succeed ()))


{-| Convert page update app messages to a single app command.
-}
toAppCmd : (Msg -> appMsg) -> PageUpdate model msg -> Cmd appMsg
toAppCmd mapper =
    toAppCmds mapper >> Cmd.batch
