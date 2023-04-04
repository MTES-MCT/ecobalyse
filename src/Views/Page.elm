module Views.Page exposing
    ( ActivePage(..)
    , Config
    , frame
    , loading
    , notFound
    )

import Browser exposing (Document)
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Request.Version as Version
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Spinner as Spinner


type ActivePage
    = Api
    | Changelog
    | Editorial String
    | Explore
    | FoodBuilder
    | FoodExplore
    | Home
    | Other
    | Stats
    | TextileExamples
    | TextileSimulator


type MenuLink
    = Internal String Route.Route ActivePage
    | External String String
    | MailTo String String


type alias Config msg =
    { session : Session
    , mobileNavigationOpened : Bool
    , closeMobileNavigation : msg
    , openMobileNavigation : msg
    , loadUrl : String -> msg
    , reloadPage : msg
    , closeNotification : Session.Notification -> msg
    , activePage : ActivePage
    }


frame : Config msg -> ( String, List (Html msg) ) -> Document msg
frame ({ activePage } as config) ( title, content ) =
    { title = title ++ " | Ecobalyse"
    , body =
        [ stagingAlert config
        , newVersionAlert config
        , pageHeader config
        , if config.mobileNavigationOpened then
            mobileNavigation config

          else
            text ""
        , main_ [ class "bg-white" ]
            [ div [ class "alert alert-info border-start-0 border-end-0 rounded-0 shadow-sm mb-0" ]
                [ Container.centered [ class "d-flex align-items-center gap-3" ]
                    [ span [ class "fs-4" ] [ Icon.info ]
                    , text """Attention : l’outil est aujourd’hui en phase de construction.
                              Les calculs qui sont proposés ne constituent pas un référentiel validé."""
                    ]
                ]
            , notificationListView config
            , div
                [ if activePage == Home then
                    class ""

                  else
                    class "pt-2 pt-sm-5"
                ]
                content
            ]
        , pageFooter config.session
        ]
    }


stagingAlert : Config msg -> Html msg
stagingAlert { session, loadUrl } =
    if
        String.contains "ecobalyse-pr" session.clientUrl
            || String.contains "wikicarbone-pr" session.clientUrl
    then
        div [ class "StagingAlert d-block d-sm-flex justify-content-center align-items-center mt-3" ]
            [ text "Vous êtes sur un environnement de recette. "
            , button
                [ type_ "button"
                , class "btn btn-link"
                , onClick (loadUrl "https://ecobalyse.beta.gouv.fr/")
                ]
                [ text "Retourner vers l'environnement de production" ]
            ]

    else
        text ""


newVersionAlert : Config msg -> Html msg
newVersionAlert { session, reloadPage } =
    case session.currentVersion of
        Version.NewerVersion ->
            div [ class "NewVersionAlert d-block align-items-center" ]
                [ text "Une nouvelle version de l'application est disponible."
                , button
                    [ type_ "button"
                    , class "btn btn-outline-primary"
                    , onClick reloadPage
                    ]
                    [ text "Mettre à jour" ]
                ]

        _ ->
            text ""


headerMenuLinks : List MenuLink
headerMenuLinks =
    [ Internal "Accueil" Route.Home Home
    , Internal "Textile" (Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing) TextileSimulator
    , Internal "Alimentaire" (Route.FoodBuilder Impact.defaultFoodTrigram Nothing) FoodBuilder
    , Internal "Exemples" Route.TextileExamples TextileExamples
    , Internal "Explorateur" (Route.Explore Scope.Textile (Dataset.Impacts Nothing)) Explore
    , Internal "API" Route.Api Api
    , External "Documentation" Env.gitbookUrl

    -- TODO: uncomment the following line when the "Alimentaire" simulator is live
    -- , Internal "Alimentaire" Route.Food Food
    ]


footerMenuLinks : List MenuLink
footerMenuLinks =
    [ Internal "Accueil" Route.Home Home
    , Internal "Textile" (Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing) TextileSimulator
    , Internal "Alimentaire" (Route.FoodBuilder Impact.defaultFoodTrigram Nothing) FoodBuilder
    , Internal "Exemples" Route.TextileExamples TextileExamples
    , Internal "Explorateur" (Route.Explore Scope.Textile (Dataset.Countries Nothing)) Explore
    , Internal "API" Route.Api Api
    , Internal "Nouveautés" Route.Changelog Changelog
    , Internal "Statistiques" Route.Stats Stats
    , Internal "Accessibilité\u{00A0}: non conforme" (Route.Editorial "accessibilité") (Editorial "accessibilité")
    , Internal "Mentions légales" (Route.Editorial "mentions-légales") (Editorial "mentions-légales")
    , External "Code source" Env.githubUrl
    , External "Documentation" Env.gitbookUrl
    , MailTo "Contact" Env.contactEmail
    ]


pageHeader : Config msg -> Html msg
pageHeader config =
    header
        [ class "shadow-sm"
        , attribute "role" "banner"
        ]
        [ Container.centered []
            [ div [ class "pt-4 pb-2 ps-3" ]
                [ a
                    [ href "/"
                    , title "Écobalyse"
                    , class "header-logo text-decoration-none d-flex align-items-center gap-5"
                    ]
                    [ p [ class "fr-logo" ]
                        [ text "République"
                        , br [] []
                        , text "Française"
                        ]
                    , h1 [ class "fs-3 fw-bolder" ]
                        [ text "Ecobalyse" ]
                    ]
                ]
            ]
        , div [ class "border-top" ]
            [ div [ class "container" ]
                [ navbar config
                ]
            ]
        ]


navbar : Config msg -> Html msg
navbar { activePage, openMobileNavigation } =
    nav
        [ class "fr-nav"
        , attribute "role" "navigation"
        , attribute "aria-label" "Menu principal"
        ]
        [ headerMenuLinks
            |> List.map (viewNavigationLink activePage)
            |> div
                [ class "d-none d-sm-flex MainMenu navbar-nav flex-row fs-7"
                , style "overflow" "auto"
                ]
        , button
            [ type_ "button"
            , class "d-inline-block d-sm-none btn btn-dark m-0 p-0"
            , attribute "aria-label" "Ouvrir la navigation"
            , title "Ouvrir la navigation"
            , onClick openMobileNavigation
            ]
            [ Icon.verticalDots ]
        ]


viewNavigationLink : ActivePage -> MenuLink -> Html msg
viewNavigationLink activePage link =
    case link of
        Internal label route page ->
            Link.internal
                (class "nav-link pe-3"
                    :: classList [ ( "active", page == activePage ) ]
                    :: Route.href route
                    :: (if page == activePage then
                            [ attribute "aria-current" "page" ]

                        else
                            []
                       )
                )
                [ text label ]

        External label url ->
            Link.external [ class "nav-link link-external-muted pe-2", href url ]
                [ text label ]

        MailTo label email ->
            a [ class "nav-link", href <| "mailto:" ++ email ] [ text label ]


notificationListView : Config msg -> Html msg
notificationListView ({ session } as config) =
    case session.notifications of
        [] ->
            text ""

        notifications ->
            notifications
                |> List.map (notificationView config)
                |> Container.centered [ class "bg-white pt-3" ]


notificationView : Config msg -> Session.Notification -> Html msg
notificationView { closeNotification } notification =
    -- TODO:
    -- - absolute positionning
    case notification of
        Session.HttpError error ->
            Alert.httpError error

        Session.GenericError title message ->
            Alert.simple
                { level = Alert.Danger
                , title = Just title
                , close = Just (closeNotification notification)
                , content = [ text message ]
                }


pageFooter : Session -> Html msg
pageFooter { currentVersion } =
    footer
        [ class "bg-dark text-light py-4 fs-7" ]
        [ Container.centered []
            [ footerMenuLinks
                |> List.map
                    (\link ->
                        case link of
                            Internal label route _ ->
                                Link.internal [ class "text-white text-decoration-none", Route.href route ]
                                    [ text label ]

                            External label url ->
                                Link.external [ class "text-white text-decoration-none", href url ]
                                    [ text label ]

                            MailTo label email ->
                                a [ class "text-white text-decoration-none link-email", href <| "mailto:" ++ email ]
                                    [ text label ]
                    )
                |> List.map (List.singleton >> li [])
                |> List.intersperse
                    (li
                        [ attribute "aria-hidden" "true"
                        , class "text-muted"
                        ]
                        [ text "|" ]
                    )
                |> ul [ class "d-flex justify-content-start flex-wrap gap-2 list-unstyled pt-1" ]
            , div [ class "row d-flex align-items-center" ]
                [ Link.external
                    [ href "https://www.ecologique-solidaire.gouv.fr/"
                    , class "col text-center bg-white px-3 m-3 link-external-muted"
                    , style "min-height" "200px"
                    ]
                    [ img
                        [ src "img/logo_mte.svg"
                        , alt "Ministère de la transition écologique et solidaire"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                , Link.external
                    [ href "https://www.economie.gouv.fr/plan-de-relance"
                    , class "d-flex flex-wrap justify-content-center align-items-center"
                    , class "col text-center bg-white p-3 m-3 link-external-muted"
                    , style "min-height" "200px"
                    ]
                    [ img
                        [ src "img/logo-france-relance.png"
                        , alt "France Relance"
                        , attribute "width" "100"
                        , attribute "height" "100"
                        ]
                        []
                    , img
                        [ src "img/logo-next-generation-eu.png"
                        , alt "Financé par la l'Union européenne"
                        , attribute "width" "250"
                        , attribute "height" "56"
                        ]
                        []
                    ]
                , Link.external
                    [ href "https://www.ecologique-solidaire.gouv.fr/fabrique-numerique"
                    , class "col d-flex justify-content-center align-items-center text-center bg-white p-3 m-3 link-external-muted"
                    , style "min-height" "200px"
                    ]
                    [ img
                        [ src "img/logo-fabriquenumerique.svg"
                        , alt "La Fabrique Numérique"
                        , attribute "width" "150"
                        , attribute "height" "150"
                        ]
                        []
                    ]
                ]
            , div [ class "text-center pt-2" ]
                [ text "Un produit "
                , Link.external [ href Env.betagouvUrl, class "text-light" ]
                    [ img [ src "img/betagouv.svg", alt "beta.gouv.fr", style "width" "120px" ] [] ]
                , case Version.toString currentVersion of
                    Just hash ->
                        small [ class "d-block pt-1 fs-8 ms-2 text-muted" ]
                            [ Link.external
                                [ class "text-white text-decoration-none"
                                , href <| Env.githubUrl ++ "/commit/" ++ hash
                                ]
                                [ text <| "Version " ++ hash ]
                            ]

                    Nothing ->
                        text ""
                ]
            ]
        ]


notFound : Html msg
notFound =
    Container.centered [ class "pb-5" ]
        [ h1 [ class "mb-3" ] [ text "Page non trouvée" ]
        , p [] [ text "La page que vous avez demandé n'existe pas." ]
        , a [ Route.href Route.Home ] [ text "Retour à l'accueil" ]
        ]


loading : Html msg
loading =
    Container.centered [ class "pb-5" ]
        [ Spinner.view
        ]


mobileNavigation : Config msg -> Html msg
mobileNavigation { activePage, closeMobileNavigation } =
    div []
        [ div
            [ class "offcanvas offcanvas-start show"
            , style "visibility" "visible"
            , id "navigation"
            , attribute "tabindex" "-1"
            , attribute "aria-labelledby" "navigationLabel"
            , attribute "arial-modal" "true"
            , attribute "role" "dialog"
            ]
            [ div [ class "offcanvas-header" ]
                [ h5 [ class "offcanvas-title", id "navigationLabel" ]
                    [ text "Navigation" ]
                , button
                    [ type_ "button"
                    , class "btn-close text-reset"
                    , attribute "aria-label" "Close"
                    , onClick closeMobileNavigation
                    ]
                    []
                ]
            , div [ class "offcanvas-body" ]
                [ footerMenuLinks
                    |> List.map (viewNavigationLink activePage)
                    |> div [ class "nav nav-pills flex-column" ]
                ]
            ]
        , div [ class "offcanvas-backdrop fade show" ] []
        ]
