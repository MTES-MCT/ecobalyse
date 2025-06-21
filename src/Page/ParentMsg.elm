module Page.ParentMsg exposing
    ( PageUpdate
    , ParentMsg(..)
    , addCmd
    , addParentMsg
    , init
    , toParentCmd
    )

{-| This module defines the messages that page modules can send to the parent Main module.
-}

import Data.Session as Session exposing (Session)
import Task


type ParentMsg
    = CloseNotification Session.Notification
    | LoadUrl String
    | ReloadPage
    | ResetSessionStore
    | SwitchVersion String


{-| Type alias for page update results that can include parent messages.
-}
type alias PageUpdate model msg =
    { model : model
    , session : Session
    , cmd : Cmd msg
    , parentMsgs : List ParentMsg
    }


{-| Initialize a page update with the given session and model.
-}
init : Session -> model -> PageUpdate model msg
init session model =
    { model = model
    , session = session
    , cmd = Cmd.none
    , parentMsgs = []
    }


{-| Add a command to the page update.
-}
addCmd : Cmd msg -> PageUpdate model msg -> PageUpdate model msg
addCmd command pageUpdate =
    { pageUpdate | cmd = Cmd.batch [ pageUpdate.cmd, command ] }


{-| Add a parent message to the page update.
-}
addParentMsg : ParentMsg -> PageUpdate model msg -> PageUpdate model msg
addParentMsg message pageUpdate =
    { pageUpdate | parentMsgs = message :: pageUpdate.parentMsgs }


{-| Convert the page update to a list of parent commands.
-}
toParentCmds : (ParentMsg -> parentMsg) -> PageUpdate model msg -> List (Cmd parentMsg)
toParentCmds mapper =
    .parentMsgs >> List.map (\parentMsg -> Task.perform (\_ -> mapper parentMsg) (Task.succeed ()))


toParentCmd : (ParentMsg -> parentMsg) -> PageUpdate model msg -> Cmd parentMsg
toParentCmd mapper =
    toParentCmds mapper >> Cmd.batch
