module Page.Admin.Section exposing
    ( Section(..)
    , parseSlug
    , toSlug
    )

import Url.Parser as Parser exposing (Parser)


type Section
    = AccountSection
    | ComponentSection
    | ProcessSection


parseSlug : Parser (Section -> a) a
parseSlug =
    Parser.custom "ADMIN_SECTION" (fromSlug >> Just)


fromSlug : String -> Section
fromSlug slug =
    case slug of
        "accounts" ->
            AccountSection

        "components" ->
            ComponentSection

        "processes" ->
            ProcessSection

        _ ->
            -- Default to components
            ComponentSection


toSlug : Section -> String
toSlug section =
    case section of
        AccountSection ->
            "accounts"

        ComponentSection ->
            "components"

        ProcessSection ->
            "processes"
