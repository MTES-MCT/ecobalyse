module Data.Plausible exposing
    ( Event(..)
    , send
    , sendIf
    )

import Data.Impact.Definition as Definition exposing (Trigram)
import Data.Sector as Sector exposing (Sector)
import Data.Session as Session exposing (Session)
import Json.Encode as Encode
import Ports
import Request.Version as Version
import Url exposing (Url)


{-| Front-end product analytics sent to Plausible
-}
type Event
    = -- `auth_api_token_created`: (Auth) A new API token was created from the account page
      AuthApiTokenCreated
    | -- `auth_login_ok`: (Auth) Magic link login successfully completed with detailed processes loaded
      AuthLoginOK
    | -- `auth_magic_link_sent`: (Auth) A magic link was sent to the user
      AuthMagicLinkSent
    | -- `auth_profile_updated`: (Auth) A user profile was saved
      AuthProfileUpdated
    | -- `auth_signup`: (Auth) A signup form was submitted successfully
      AuthSignup
    | -- `bookmark_saved`: (Bookmarks) A simulation was saved as a bookmark
      BookmarkSaved Sector
    | -- `comparator_opened`: (Comparator) The comparison modal was opened
      ComparatorOpened Sector
    | -- `comparison_type_selected`: (Comparator) A tab was selected; can be "Impacts", "Étapes", "Sous-scores" or "Total"
      ComparisonTypeSelected Sector String
    | -- `component_added` (Generic simulator) A production item was added (existing component or raw material)
      ComponentAdded Sector
    | -- `component_updated` (Generic simulator) A production item's quantity, name or elements list was updated
      ComponentUpdated Sector
    | -- `consumption_added` (Generic simulator) A new consumption was added at the use stage
      ConsumptionAdded Sector
    | -- `example_selected`: (Simulator) An example simulation was loaded into the simulator
      ExampleSelected Sector
    | -- `impact_selected`: (Simulator) The current impact indicator changed (eg. `ecs` -> `acd`)
      ImpactSelected Sector Trigram
    | -- `pageview`: (Navigation) Triggered every time the URL changes
      PageViewed Url
    | -- `tab_selected`: (Simulator) A tab was selected, eg. "Partager", "Impacts", "Étapes", "Sous-scores" etc.
      TabSelected Sector String


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

            BookmarkSaved sector ->
                track session
                    "bookmark_saved"
                    [ string "feature" "bookmarks"
                    , string "scope" (Sector.toString sector)
                    ]

            ComparatorOpened sector ->
                track session
                    "comparator_opened"
                    [ string "feature" "comparator"
                    , string "scope" (Sector.toString sector)
                    ]

            ComparisonTypeSelected sector comparisonType ->
                track session
                    "comparison_type_selected"
                    [ string "feature" "comparator"
                    , string "scope" (Sector.toString sector)
                    , string "comparison_type" comparisonType
                    ]

            ComponentAdded sector ->
                track session
                    "component_added"
                    [ string "feature" "simulator"
                    , string "scope" (Sector.toString sector)
                    ]

            ComponentUpdated sector ->
                track session
                    "component_updated"
                    [ string "feature" "simulator"
                    , string "scope" (Sector.toString sector)
                    ]

            ConsumptionAdded sector ->
                track session
                    "consumption_added"
                    [ string "feature" "simulator"
                    , string "scope" (Sector.toString sector)
                    ]

            ExampleSelected sector ->
                track session
                    "example_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Sector.toString sector)
                    ]

            ImpactSelected sector trigram ->
                track session
                    "impact_selected"
                    [ string "feature" "simulator"
                    , string "scope" (Sector.toString sector)
                    , string "trigram" (Definition.toString trigram)
                    ]

            PageViewed url ->
                track session
                    "pageview"
                    [ string "url" (safeUrl url) ]

            TabSelected sector tab ->
                track session
                    "tab_selected"
                    [ string "feature" "share"
                    , string "scope" (Sector.toString sector)
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
