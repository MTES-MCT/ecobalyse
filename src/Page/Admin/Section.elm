module Page.Admin.Section exposing (Section(..), parseSlug)

import Url.Parser as Parser exposing (Parser)


type Section
    = AccountSection
    | ComponentSection
    | ProcessSection


parseSlug : Parser (Section -> a) a
parseSlug =
    Parser.custom "SECTION" (fromSlug >> Just)


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
