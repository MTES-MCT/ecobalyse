module Data.Posthog exposing
    ( Event(..)
    , send
    , sendIf
    )

import Data.Impact.Definition as Definition exposing (Trigram)
import Data.Scope as Scope exposing (Scope)
import Ports
import Url exposing (Url)


type Event
    = AuthApiTokenCreated
    | AuthLoginOK
    | AuthMagicLinkSent
    | AuthProfileUpdated
    | AuthSignup
    | BookmarkSaved Scope
    | ComparatorOpened Scope
    | ExampleSelected Scope
    | ImpactSelected Scope Trigram
    | PageViewed Url
    | TabSelected Scope String


type alias SerializedEvent =
    { name : String
    , properties : List ( String, String )
    }


send : Event -> Cmd msg
send event =
    Ports.sendPosthogEvent <|
        case event of
            AuthApiTokenCreated ->
                simple "auth_api_token_created"

            AuthLoginOK ->
                simple "auth_login_ok"

            AuthMagicLinkSent ->
                simple "auth_magic_link_sent"

            AuthProfileUpdated ->
                simple "auth_profile_updated"

            AuthSignup ->
                simple "auth_signup"

            BookmarkSaved scope ->
                custom "bookmark_saved"
                    [ ( "scope", Scope.toString scope ) ]

            ComparatorOpened scope ->
                custom "comparator_opened"
                    [ ( "scope", Scope.toString scope ) ]

            ExampleSelected scope ->
                custom "example_selected"
                    [ ( "scope", Scope.toString scope ) ]

            ImpactSelected scope trigram ->
                custom "impact_selected"
                    [ ( "scope", Scope.toString scope )
                    , ( "trigram", Definition.toString trigram )
                    ]

            PageViewed url ->
                --  Note: $pageview is a special event handled by posthog
                custom "$pageview"
                    -- same for $current_url
                    [ ( "$current_url", Url.toString url ) ]

            TabSelected scope tab ->
                custom "tab_selected"
                    [ ( "scope", Scope.toString scope )
                    , ( "tab", tab )
                    ]


sendIf : Bool -> Event -> Cmd msg
sendIf condition event =
    if condition then
        send event

    else
        Cmd.none


simple : String -> SerializedEvent
simple name =
    { name = name, properties = [] }


custom : String -> List ( String, String ) -> SerializedEvent
custom name properties =
    { name = name, properties = properties }
