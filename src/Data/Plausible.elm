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
import Request.Version as Version
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


type alias Key =
    String


type alias Property =
    ( Key, Encode.Value )


type alias SerializedEvent =
    { name : String
    , properties : List Property
    }


send : Session -> Event -> Cmd msg
send session event =
    Ports.sendPlausibleEvent <|
        case event of
            AuthApiTokenCreated ->
                track session
                    "auth_api_token_created"
                    [ string "feature" "auth" ]

            AuthLoginOK ->
                track session
                    "auth_login_ok"
                    [ string "feature" "auth" ]

            AuthMagicLinkSent ->
                track session
                    "auth_magic_link_sent"
                    [ string "feature" "auth" ]

            AuthProfileUpdated ->
                track session
                    "auth_profile_updated"
                    [ string "feature" "auth" ]

            AuthSignup ->
                track session
                    "auth_signup"
                    [ string "feature" "auth" ]

            BookmarkSaved scope ->
                track session
                    "bookmark_saved"
                    [ string "feature" "bookmarks"
                    , string "scope" (Scope.toString scope)
                    ]

            ComparatorOpened scope ->
                track session
                    "comparator_opened"
                    [ string "feature" "comparator"
                    , string "scope" (Scope.toString scope)
                    ]

            ComparisonTypeSelected scope comparisonType ->
                track session
                    "comparison_type_selected"
                    [ string "feature" "comparator"
                    , string "scope" (Scope.toString scope)
                    , string "comparison_type" comparisonType
                    ]

            ComponentAdded scope ->
                track session
                    "component_added"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ComponentUpdated scope ->
                track session
                    "component_updated"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ExampleSelected scope ->
                track session
                    "example_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    ]

            ImpactSelected scope trigram ->
                track session
                    "impact_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Scope.toString scope)
                    , string "trigram" (Definition.toString trigram)
                    ]

            PageViewed url ->
                track session
                    "pageview"
                    [ string "url" (safeUrl url) ]

            TabSelected scope tab ->
                track session
                    "tab_selected"
                    [ string "feature" "share"
                    , string "scope" (Scope.toString scope)
                    , string "tab" tab
                    ]


bool : Key -> Bool -> Property
bool key value =
    ( key, Encode.bool value )


maybe : (Key -> a -> Property) -> Key -> Maybe a -> Property
maybe fn key =
    Maybe.map (fn key) >> Maybe.withDefault (null key)


null : Key -> Property
null key =
    ( key, Encode.null )


string : Key -> String -> Property
string key value =
    ( key, Encode.string value )


safeUrl : Url -> String
safeUrl url =
    Url.toString <|
        -- Clean auth urls as they might contain sensitive information
        if url.fragment |> Maybe.map (String.startsWith "/auth/") |> Maybe.withDefault False then
            { url | fragment = Just "/auth/<***>/" }

        else
            url


sendIf : Session -> Bool -> Event -> Cmd msg
sendIf session condition event =
    if condition then
        send session event

    else
        Cmd.none


track : Session -> String -> List Property -> SerializedEvent
track session name properties =
    { name = name
    , properties =
        -- generic properties
        bool "admin" (Session.isSuperuser session)
            :: bool "authenticated" (Session.isAuthenticated session)
            :: string "clientUrl" session.clientUrl
            :: maybe string "scalingoAppName" session.scalingoAppName
            :: string "subsystem" "front-end"
            :: maybe string "version" (Version.getTag session.currentVersion)
            :: properties
    }
