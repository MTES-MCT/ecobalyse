module Views.SectorMenu exposing (Config, backdrop, button, mobile, view)

import Data.Env as Env
import Data.Sector as Sector
import Data.Session as Session
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Views.Container as Container
import Views.Link as Link
import Views.Navigation exposing (ActivePage(..), MenuLink(..))


type alias Config msg =
    { activePage : ActivePage
    , close : msg
    , enabledSections : Session.EnabledSections
    , opened : Bool
    , toggle : msg
    }


type Badge
    = Beta
    | Obsolete


type alias Domain msg =
    { entries : List (Entry msg)
    , label : String
    }


type alias Entry msg =
    { badge : Maybe Badge
    , link : MenuLink msg
    }


{-| TODO: check if this shouldn't become a more broadly used helper
-}
addWhen : Bool -> a -> Maybe a
addWhen condition value =
    if condition then
        Just value

    else
        Nothing


backdrop : msg -> Html msg
backdrop close =
    div
        [ class "d-none d-sm-block position-fixed top-0 start-0 bottom-0 end-0 sector-menu-backdrop"
        , attribute "aria-hidden" "true"
        , onClick close
        ]
        []


badgeView : Maybe Badge -> List (Html msg)
badgeView maybeBadge =
    case maybeBadge of
        Just Beta ->
            [ span [ class "badge badge-info" ] [ text "Beta" ] ]

        Just Obsolete ->
            [ span [ class "badge badge-danger" ] [ text "Obsolete" ] ]

        Nothing ->
            []


button : Config msg -> Html msg
button { activePage, opened, toggle } =
    let
        simulatorPage =
            isSimulatorPage activePage
    in
    Html.button
        ([ type_ "button"
         , id "sector-menu-button"
         , class "nav-link d-inline-flex align-items-center gap-2"
         , classList [ ( "active", simulatorPage ), ( "sector-menu-open", opened ) ]
         , attribute "aria-controls" "sector-menu"
         , attribute "aria-expanded"
            (if opened then
                "true"

             else
                "false"
            )
         , attribute "aria-haspopup" "true"
         , onClick toggle
         ]
            ++ (if simulatorPage then
                    [ attribute "aria-current" "page" ]

                else
                    []
               )
        )
        [ text "Simulateurs", chevron opened ]


chevron : Bool -> Html msg
chevron opened =
    span
        [ attribute "aria-hidden" "true"
        , class "chevron"
        , classList [ ( "chevron-up", opened ), ( "chevron-down", not opened ) ]
        ]
        []


domains : Session.EnabledSections -> List (Domain msg)
domains enabledSections =
    [ ( "Objets"
      , [ addWhen enabledSections.furniture
            { badge = Nothing
            , link = Internal [ text "Ameublement" ] (Route.GenericSimulatorHome Sector.Furniture) (Generic Sector.Furniture)
            }
        , addWhen enabledSections.veli
            { badge = Nothing
            , link = Internal [ text "Mobilité" ] (Route.GenericSimulatorHome Sector.Veli) (Generic Sector.Veli)
            }
        , addWhen enabledSections.objects
            { badge = Nothing
            , link = Internal [ text "Autres" ] (Route.GenericSimulatorHome Sector.Object) (Generic Sector.Object)
            }
        ]
      )
    , ( "Textile"
      , [ Just
            { badge = Nothing
            , link = External "Habillement (version stable 7.0.0)" (Env.stableTextileVersionPath ++ "#/textile/simulator")
            }
        , addWhen enabledSections.textile
            { badge = Nothing
            , link = Internal [ text "Habillement" ] Route.TextileSimulatorHome TextileSimulator
            }
        , addWhen enabledSections.apparel
            { badge = Just Beta
            , link = Internal [ text "Mode et linge de maison" ] (Route.GenericSimulatorHome Sector.Apparel) (Generic Sector.Apparel)
            }
        ]
      )
    , ( "Alimentaire"
      , [ addWhen enabledSections.food2
            { badge = Nothing
            , link = Internal [ text "Produits alimentaires" ] (Route.GenericSimulatorHome Sector.Food2) (Generic Sector.Food2)
            }
        , addWhen enabledSections.food
            { badge = Just Obsolete
            , link = Internal [ text "Produits alimentaires" ] Route.FoodBuilderHome Food
            }
        ]
      )
    ]
        |> List.filterMap
            (\( label, maybeEntries ) ->
                case List.filterMap identity maybeEntries of
                    [] ->
                        Nothing

                    entries ->
                        Just
                            { entries = entries
                            , label = label
                            }
            )


entryLink : ActivePage -> Entry msg -> Html msg
entryLink activePage { badge, link } =
    let
        withBadge content =
            content ++ badgeView badge
    in
    case link of
        External label url ->
            withBadge [ text label ]
                |> Link.external (linkAttributes False ++ [ href url ])

        Internal content route page ->
            withBadge content
                |> Link.internal
                    (linkAttributes (page == activePage)
                        ++ (Route.href route
                                :: (if page == activePage then
                                        [ attribute "aria-current" "page" ]

                                    else
                                        []
                                   )
                           )
                    )

        -- No mailto link in the sector menu
        MailTo _ _ ->
            text ""

        -- The sector menu is not recursive
        SectorMenu ->
            text ""


group : Bool -> ActivePage -> Domain msg -> List (Html msg)
group desktop activePage { entries, label } =
    [ div
        [ class "fw-bold text-body"
        , class <|
            if desktop then
                "border-bottom px-3 py-2"

            else
                "px-3 pt-3 pb-1 mb-0"
        ]
        [ text label ]
    , entries
        |> List.map (\entry -> li [] [ entryLink activePage entry ])
        |> ul [ class "list-unstyled mb-0" ]
    ]


isSimulatorPage : ActivePage -> Bool
isSimulatorPage activePage =
    case activePage of
        Food ->
            True

        Generic _ ->
            True

        TextileSimulator ->
            True

        _ ->
            False


linkAttributes : Bool -> List (Attribute msg)
linkAttributes isActive =
    [ class "bg-light-hover d-flex align-items-center gap-2 px-3 py-2 text-decoration-none w-100"
    , classList
        [ ( "active link-primary border-left-primary", isActive )
        , ( "text-body", not isActive )
        ]
    ]


mobile : Config msg -> Html msg
mobile { activePage, enabledSections } =
    div [ class "border-top border-bottom my-2 py-2" ]
        [ div [ class "fw-bold text-body px-3 pt-2 pb-1" ] [ text "Simulateurs" ]
        , domains enabledSections
            |> List.concatMap (group False activePage)
            |> div []
        ]


view : Config msg -> Html msg
view config =
    div
        [ id "sector-menu"
        , attribute "role" "region"
        , attribute "aria-labelledby" "sector-menu-button"
        , class "d-none d-sm-block position-absolute top-100 start-0 end-0 z-index-sticky-plus-1"
        , class "border-top border-bottom shadow pt-3 pb-4 bg-opacity-95 bg-blurry fs-7"
        ]
        [ Container.centered [ class "px-5" ]
            [ div [ class "d-flex justify-content-end" ]
                [ Html.button
                    [ type_ "button"
                    , class "btn btn-link btn-sm text-decoration-none"
                    , class "d-inline-flex align-items-center gap-1 p-0 mb-2"
                    , onClick config.close
                    ]
                    [ text "Fermer"
                    , span [ attribute "aria-hidden" "true" ] [ text "×" ]
                    ]
                ]
            , domains config.enabledSections
                |> List.map (group True config.activePage >> div [ class "col" ])
                |> div [ class "row row-cols-1 row-cols-xl-3 g-4" ]
            ]
        ]
