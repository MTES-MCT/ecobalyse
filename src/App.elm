module App exposing
    ( Msg(..)
    , PageUpdate
    , apply
    , createUpdate
    , mapSession
    , toAppCmd
    , withAppMsg
    , withCmds
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


{-| Apply an update function to a PageUpdate.
-}
apply : (Session -> msg -> model -> PageUpdate model msg) -> msg -> PageUpdate model msg -> PageUpdate model msg
apply update msg { appMsgs, cmd, model, session } =
    model
        |> update session msg
        |> withAppMsgs appMsgs
        |> withCmds [ cmd ]


{-| Initialize a page update with the given session and model.
-}
createUpdate : Session -> model -> PageUpdate model msg
createUpdate session model =
    { appMsgs = []
    , cmd = Cmd.none
    , model = model
    , session = session
    }


{-| Map a function over the session of a PageUpdate.
-}
mapSession : (Session -> Session) -> PageUpdate model msg -> PageUpdate model msg
mapSession fn { appMsgs, cmd, model, session } =
    { appMsgs = appMsgs
    , cmd = cmd
    , model = model
    , session = fn session
    }


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


{-| Add an app message to a PageUpdate.
-}
withAppMsg : Msg -> PageUpdate model msg -> PageUpdate model msg
withAppMsg appMsg pageUpdate =
    { pageUpdate | appMsgs = pageUpdate.appMsgs ++ [ appMsg ] }


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
