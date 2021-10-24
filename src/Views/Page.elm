module Views.Page exposing (..)

import Browser exposing (Document)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.Common as HttpCommon
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Spinner as Spinner


type ActivePage
    = Home
    | Changelog
    | Editorial String
    | Examples
    | Simulator
    | Stats
    | Other


type MenuLink
    = Internal String Route.Route ActivePage
    | External String String
    | MailTo String String


type alias Config msg =
    { session : Session
    , closeNotification : Session.Notification -> msg
    , activePage : ActivePage
    }


frame : Config msg -> ( String, List (Html msg) ) -> Document msg
frame config ( title, content ) =
    { title = title ++ " | wikicarbone"
    , body =
        [ navbar config
        , feedback
        , main_ [ class "bg-white" ]
            [ notificationListView config
            , div [ class "pt-5" ] content
            ]
        , pageFooter
        ]
    }


headerMenuLinks : List MenuLink
headerMenuLinks =
    [ Internal "Accueil" Route.Home Home
    , Internal "Simulateur" (Route.Simulator Nothing) Simulator
    , Internal "Exemples" Route.Examples Examples
    , External "Documentation" "https://fabrique-numerique.gitbook.io/wikicarbone/"
    ]


footerMenuLinks : List MenuLink
footerMenuLinks =
    [ Internal "Accueil" Route.Home Home
    , Internal "Simulateur" (Route.Simulator Nothing) Simulator
    , Internal "Exemples" Route.Examples Examples
    , Internal "Changelog" Route.Changelog Changelog
    , Internal "Statistiques" Route.Stats Stats
    , External "Code source" "https://github.com/MTES-MCT/wikicarbone/"
    , External "Documentation" "https://fabrique-numerique.gitbook.io/wikicarbone/"
    , External "FAQ" "https://fabrique-numerique.gitbook.io/wikicarbone/faq"
    , MailTo "Contact" "wikicarbone@beta.gouv.fr"
    ]


navbar : Config msg -> Html msg
navbar { activePage } =
    nav [ class "Header navbar navbar-expand-lg navbar-dark bg-dark shadow" ]
        [ Container.centered []
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ img
                    [ class "d-inline-block align-text-bottom invert me-2"
                    , alt ""
                    , src "img/logo.svg"
                    , height 26
                    ]
                    []
                , span [ class "fs-3" ] [ text "wikicarbone" ]
                ]
            , headerMenuLinks
                |> List.map
                    (\link ->
                        case link of
                            Internal label route page ->
                                Link.internal
                                    ([ class "nav-link pe-1"
                                     , classList [ ( "active", page == activePage ) ]
                                     , Route.href route
                                     ]
                                        ++ (if page == activePage then
                                                [ attribute "aria-current" "page" ]

                                            else
                                                []
                                           )
                                    )
                                    [ text label ]

                            External label url ->
                                Link.external [ class "nav-link pe-1", href url ]
                                    [ text label ]

                            MailTo label email ->
                                a [ class "link-email", href <| "mailto:" ++ email ] [ text label ]
                    )
                |> div
                    [ class "MainMenu navbar-nav justify-content-between flex-row"
                    , style "overflow" "auto"
                    ]
            ]
        ]


feedback : Html msg
feedback =
    -- Note: only visible on larger viewports
    Container.fluid [ class "d-none d-sm-block alert alert-info p-2 m-0 rounded-0 shadow-sm" ]
        [ Container.centered [ class "text-center" ]
            [ span []
                [ span [ class "me-1" ] [ Icon.dialog ]
                , text "Que pensez-vous de notre produit\u{00A0}? "
                , Link.external
                    [ href "https://hhvat39ihea.typeform.com/to/HnNn6rIY"
                    ]
                    [ text "Prenons-5 minutes pour voir comment l'améliorer"
                    ]
                ]
            ]
        ]


notificationListView : Config msg -> Html msg
notificationListView ({ session } as config) =
    session.notifications
        |> List.map (notificationView config)
        |> Container.centered [ class "bg-white" ]


notificationView : Config msg -> Session.Notification -> Html msg
notificationView { closeNotification } notification =
    -- TODO:
    -- - close button
    -- - maybe switch to alert
    -- - generic DRY view
    -- - absolute positionning
    case notification of
        Session.HttpError title error ->
            Alert.preformatted
                { level = Alert.Danger
                , title = title
                , close = Just (closeNotification notification)
                , content = [ error |> HttpCommon.errorToString |> text ]
                }

        Session.GenericError title message ->
            Alert.simple
                { level = Alert.Danger
                , title = title
                , close = Just (closeNotification notification)
                , content = [ text message ]
                }


pageFooter : Html msg
pageFooter =
    footer
        [ class "bg-dark text-light py-5 fs-7" ]
        [ Container.centered []
            [ div [ class "row d-flex align-items-center" ]
                [ div [ class "col" ]
                    [ h3 [] [ text "wikicarbone" ]
                    , footerMenuLinks
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
                        |> ul [ class "list-unstyled" ]
                    ]
                , Link.external
                    [ href "https://www.ecologique-solidaire.gouv.fr/"
                    , class "col text-center bg-white px-3 m-3 link-external-muted"
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
                    [ href "https://www.cohesion-territoires.gouv.fr/"
                    , class "col text-center bg-white px-3 m-3 link-external-muted"
                    ]
                    [ img
                        [ src "img/logo_mct.svg"
                        , alt "Ministère de la Cohésion des territoires et des Relations avec les collectivités territoriales"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                , Link.external
                    [ href "https://www.ecologique-solidaire.gouv.fr/fabrique-numerique"
                    , class "col text-center px-3 py-2 link-external-muted"
                    ]
                    [ img
                        [ src "img/logo-fabriquenumerique.svg"
                        , alt "La Fabrique Numérique"
                        , attribute "width" "200"
                        , attribute "height" "200"
                        ]
                        []
                    ]
                ]
            , div [ class "text-center pt-2" ]
                [ text "Un produit "
                , Link.external [ href "https://beta.gouv.fr/startups/wikicarbone.html", class "text-light" ]
                    [ img [ src "img/betagouv.svg", alt "beta.gouv.fr", style "width" "120px" ] [] ]
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
