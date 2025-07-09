module Data.Posthog exposing
    ( Event(..)
    , send
    )

import Ports


type Event
    = PageView


send : Event -> Cmd msg
send event =
    Ports.sendPosthogEvent <|
        case event of
            PageView ->
                { name = "$pageview", properties = [] }
