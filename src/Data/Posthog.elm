module Data.Posthog exposing
    ( Event(..)
    , send
    )

import Data.Impact.Definition as Definition exposing (Trigram)
import Ports


type Event
    = AuthApiTokenCreated
    | AuthLoginOK
    | AuthMagicLinkSent
    | AuthProfileUpdated
    | AuthSignup
    | PageView
    | SelectDetailedImpact Trigram


send : Event -> Cmd msg
send event =
    Ports.sendPosthogEvent <|
        case event of
            AuthApiTokenCreated ->
                { name = "AuthApiTokenCreated", properties = [] }

            AuthLoginOK ->
                { name = "AuthLoginOK", properties = [] }

            AuthMagicLinkSent ->
                { name = "AuthMagicLinkSent", properties = [] }

            AuthProfileUpdated ->
                { name = "AuthProfileUpdated", properties = [] }

            AuthSignup ->
                { name = "AuthSignup", properties = [] }

            PageView ->
                --  Note: $pageview is a special event handled by posthog
                { name = "$pageview", properties = [] }

            SelectDetailedImpact trigram ->
                { name = "SelectDetailedImpact"
                , properties = [ ( "trigram", Definition.toString trigram ) ]
                }
