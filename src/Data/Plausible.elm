module Data.Plausible exposing
    ( Event(..)
    , send
    , sendIf
    )

import Data.Impact.Definition as Definition exposing (Trigram)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Json.Encode as Encode
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
    | PageViewed Url
    | TabSelected Scope String


type alias SerializedEvent =
    { name : String
    , properties : List ( String, String )
    }


send : Session -> Event -> Cmd msg
send session event =
    Ports.sendPlausibleEvent <|
        case event of
            AuthApiTokenCreated ->
                custom session
                    "auth_api_token_created"
                    [ ( "feature", "auth" )
                    ]

            AuthLoginOK ->
                custom session
                    "auth_login_ok"
                    [ ( "feature", "auth" ) ]

            AuthMagicLinkSent ->
                custom session
                    "auth_magic_link_sent"
                    [ ( "feature", "auth" ) ]

            AuthProfileUpdated ->
                custom session
                    "auth_profile_updated"
                    [ ( "feature", "auth" ) ]

            AuthSignup ->
                custom session
                    "auth_signup"
                    [ ( "feature", "auth" ) ]

            BookmarkSaved scope ->
                custom session
                    "bookmark_saved"
                    [ ( "feature", "bookmarks" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComparatorOpened scope ->
                custom session
                    "comparator_opened"
                    [ ( "feature", "comparator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComparisonTypeSelected scope comparisonType ->
                custom session
                    "comparison_type_selected"
                    [ ( "feature", "comparator" )
                    , ( "scope", Scope.toString scope )
                    , ( "comparison_type", comparisonType )
                    ]

            ComponentAdded scope ->
                custom session
                    "component_added"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ComponentUpdated scope ->
                custom session
                    "component_updated"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ExampleSelected scope ->
                custom session
                    "example_selected"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    ]

            ImpactSelected scope trigram ->
                custom session
                    "impact_selected"
                    [ ( "feature", "simulator" )
                    , ( "scope", Scope.toString scope )
                    , ( "trigram", Definition.toString trigram )
                    ]

            PageViewed url ->
                custom session "pageview" [ ( "url", safeUrl url ) ]

            TabSelected scope tab ->
                custom session
                    "tab_selected"
                    [ ( "feature", "share" )
                    , ( "scope", Scope.toString scope )
                    , ( "tab", tab )
                    ]


custom : Session -> String -> List ( String, String ) -> SerializedEvent
custom session name properties =
    { name = name
    , properties = ( "authenticated", encodeAuthenticated session ) :: properties
    }


encodeAuthenticated : Session -> String
encodeAuthenticated =
    Session.isAuthenticated >> Encode.bool >> Encode.encode 0


safeUrl : Url -> String
safeUrl url =
    Url.toString <|
        -- Clean auth urls as they might contain sensitive information
        if url.fragment |> Maybe.map (String.startsWith "/auth/") |> Maybe.withDefault False then
            { url | fragment = Just "/auth/<obfuscated_for_security>/" }

        else
            url


sendIf : Session -> Bool -> Event -> Cmd msg
sendIf session condition event =
    if condition then
        send session event

    else
        Cmd.none
