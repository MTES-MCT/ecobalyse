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
    , properties : List ( String, Encode.Value )
    }


send : Session -> Event -> Cmd msg
send session event =
    Ports.sendPlausibleEvent <|
        case event of
            AuthApiTokenCreated ->
                custom session
                    "auth_api_token_created"
                    [ string "feature" "auth" ]

            AuthLoginOK ->
                custom session
                    "auth_login_ok"
                    [ string "feature" "auth" ]

            AuthMagicLinkSent ->
                custom session
                    "auth_magic_link_sent"
                    [ string "feature" "auth" ]

            AuthProfileUpdated ->
                custom session
                    "auth_profile_updated"
                    [ string "feature" "auth" ]

            AuthSignup ->
                custom session
                    "auth_signup"
                    [ string "feature" "auth" ]

            BookmarkSaved scope ->
                custom session
                    "bookmark_saved"
                    [ string "feature" "bookmarks"
                    , string "scope" (Scope.toString scope)
                    ]

            ComparatorOpened scope ->
                custom session
                    "comparator_opened"
                    [ string "feature" "comparator"
                    , string "scope" (Scope.toString scope)
                    ]

            ComparisonTypeSelected scope comparisonType ->
                custom session
                    "comparison_type_selected"
                    [ string "feature" "comparator"
                    , string "scope" (Scope.toString scope)
                    , string "comparison_type" comparisonType
                    ]

            ComponentAdded scope ->
                custom session
                    "component_added"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ComponentUpdated scope ->
                custom session
                    "component_updated"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ExampleSelected scope ->
                custom session
                    "example_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ImpactSelected scope trigram ->
                custom session
                    "impact_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    , string "trigram" (Definition.toString trigram)
                    ]

            PageViewed url ->
                custom session
                    "pageview"
                    [ string "url" (safeUrl url) ]

            TabSelected scope tab ->
                custom session
                    "tab_selected"
                    [ string "feature" "share"
                    , string "scope" (Scope.toString scope)
                    , string "tab" tab
                    ]


bool : String -> Bool -> ( String, Encode.Value )
bool key value =
    ( key, Encode.bool value )


string : String -> String -> ( String, Encode.Value )
string key value =
    ( key, Encode.string value )


custom : Session -> String -> List ( String, Encode.Value ) -> SerializedEvent
custom session name properties =
    { name = name
    , properties =
        -- generic properties
        bool "authenticated" (Session.isAuthenticated session)
            :: string "clientUrl" session.clientUrl
            :: properties
    }


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
