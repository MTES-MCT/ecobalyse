module Data.Posthog exposing
    ( Event(..)
    , send
    )

import Data.Impact.Definition as Definition exposing (Trigram)
import Ports


type Event
    = PageView
    | SelectDetailedImpact Trigram


send : Event -> Cmd msg
send event =
    Ports.sendPosthogEvent <|
        case event of
            PageView ->
                { name = "$pageview", properties = [] }

            SelectDetailedImpact trigram ->
                { name = "select_detailed_impact"
                , properties = [ ( "trigram", Definition.toString trigram ) ]
                }
