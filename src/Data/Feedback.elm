module Data.Feedback exposing
    ( Persist
    , decode
    , default
    , encode
    , registerAction
    )

{-| Usage counter for the "Je donne mon avis" feedback prompt.

Shared by every simulator and stored in the session store, so it survives navigation between simulators
and browser restarts. Once the prompt has been shown, it's not proposed again.

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


{-| Persisted state of the feedback counter
-}
type alias Persist =
    { actionCount : Int
    , shown : Bool
    }


{-| Number of simulator actions after which the feedback modal is shown.
-}
actionThreshold : Int
actionThreshold =
    30


decode : Decoder Persist
decode =
    Decode.succeed Persist
        |> JDP.optional "actionCount" Decode.int 0
        |> JDP.optional "shown" Decode.bool False


default : Persist
default =
    { actionCount = 0
    , shown = False
    }


encode : Persist -> Encode.Value
encode persist =
    Encode.object
        [ ( "actionCount", Encode.int persist.actionCount )
        , ( "shown", Encode.bool persist.shown )
        ]


{-| Register one simulator action and update state.
-}
registerAction : Persist -> { openPrompt : Bool, persist : Persist }
registerAction persist =
    if persist.shown then
        { openPrompt = False, persist = persist }

    else if persist.actionCount + 1 >= actionThreshold then
        { openPrompt = True
        , persist = { actionCount = persist.actionCount + 1, shown = True }
        }

    else
        { openPrompt = False
        , persist = { persist | actionCount = persist.actionCount + 1 }
        }
