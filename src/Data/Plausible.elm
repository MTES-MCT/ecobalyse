module Data.Plausible exposing
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
    | ComparisonTypeSelected Scope String
    | ComponentAdded Scope
    | ComponentUpdated Scope
    | ExampleSelected Scope
    | ImpactSelected Scope Trigram
    | PageErrored Url String
    | PageViewed Url
    | TabSelected Scope String


type alias SerializedEvent =
    { name : String
    , properties : List ( String, String )
    }


send : Event -> Cmd msg
send event =
    Ports.sendPlausibleEvent <|
        case event of
            AuthApiTokenCreated ->
                custom "auth_api_token_created"
                    [ ( "feature", "auth" ) ]

            AuthLoginOK ->
                custom "auth_login_ok"
                    [ ( "feature", "auth" ) ]

            AuthMagicLinkSent ->
                custom "auth_magic_link_sent"
                    [ ( "feature", "auth" ) ]

            AuthProfileUpdated ->
                custom "auth_profile_updated"
                    [ ( "feature", "auth" ) ]

            AuthSignup ->
                custom "auth_signup"
                    [ ( "feature", "auth" ) ]

            BookmarkSaved scope ->
                custom "bookmark_saved"
                    [ ( "feature", "bookmarks" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComparatorOpened scope ->
                custom "comparator_opened"
                    [ ( "feature", "comparator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComparisonTypeSelected scope comparisonType ->
                custom "comparison_type_selected"
                    [ ( "feature", "comparator" )
                    , ( "scope", Scope.toString scope )
                    , ( "comparison_type", comparisonType )
                    ]

            ComponentAdded scope ->
                custom "component_added"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComponentUpdated scope ->
                custom "component_updated"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ExampleSelected scope ->
                custom "example_selected"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ImpactSelected scope trigram ->
                custom "impact_selected"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    , ( "trigram", Definition.toString trigram )
                    ]

            PageErrored url error ->
                custom "page_errored"
                    [ ( "feature", "navigation" )
                    , ( "url", Url.toString url )
                    , ( "error", error )
                    ]

            PageViewed url ->
                custom "pageview"
                    [ ( "url", safeUrl url )
                    ]

            TabSelected scope tab ->
                custom "tab_selected"
                    [ ( "feature", "share" )
                    , ( "scope", Scope.toString scope )
                    , ( "tab", tab )
                    ]


custom : String -> List ( String, String ) -> SerializedEvent
custom name properties =
    { name = name, properties = properties }


safeUrl : Url -> String
safeUrl url =
    Url.toString <|
        -- Clean auth urls as they might contain sensitive information
        if url.fragment |> Maybe.map (String.startsWith "/auth/") |> Maybe.withDefault False then
            { url | fragment = Just "/auth/<obfuscated_for_security>/" }

        else
            url


sendIf : Bool -> Event -> Cmd msg
sendIf condition event =
    if condition then
        send event

    else
        Cmd.none
