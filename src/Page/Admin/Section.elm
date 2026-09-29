module Page.Admin.Section exposing
    ( Section(..)
    , parseSlug
    , toLabel
    , toSlug
    )

import Url.Parser as Parser exposing (Parser)


type Section
    = AccountSection
    | ProcessSection


fromSlug : String -> Maybe Section
fromSlug slug =
    case slug of
        "accounts" ->
            Just AccountSection

        "processes" ->
            Just ProcessSection

        _ ->
            Nothing


parseSlug : Parser (Section -> a) a
parseSlug =
    Parser.custom "ADMIN_SECTION" fromSlug


toLabel : Section -> String
toLabel section =
    case section of
        AccountSection ->
            "Utilisateurs"

        ProcessSection ->
            "Procédés"


toSlug : Section -> String
toSlug section =
    case section of
        AccountSection ->
            "accounts"

        ProcessSection ->
            "processes"
