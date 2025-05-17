module Views.Page exposing
    ( ActivePage(..)
    , Config
    , frame
    , loading
    , notFound
    , restricted
    )

import Browser exposing (Document)
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Github as Github
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import RemoteData
import Request.Version as Version exposing (Version(..))
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Spinner as Spinner


type ActivePage
    = Admin
    | Api
    | Auth
    | Auth2
    | Editorial String
    | Explore
    | FoodBuilder
    | Home
    | Object Scope
    | Other
    | Stats
    | TextileSimulator


type MenuLink
    = External String String
    | Internal String Route.Route ActivePage
    | MailTo String String


type alias Config msg =
    { session : Session
    , mobileNavigationOpened : Bool
    , closeMobileNavigation : msg
    , openMobileNavigation : msg
    , loadUrl : String -> msg
    , reloadPage : msg
    , closeNotification : Session.Notification -> msg
    , resetSessionStore : msg
    , switchVersion : String -> msg
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
            [ notificationListView config
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


isStaging : Session -> Bool
isStaging { clientUrl } =
    String.contains "ecobalyse-pr" clientUrl || String.contains "staging-ecobalyse" clientUrl


stagingAlert : Config msg -> Html msg
stagingAlert { session, loadUrl } =
    if isStaging session then
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
        Version.NewerVersion _ { tag } ->
            div [ class "NewVersionAlert d-block align-items-center" ]
                [ case tag of
                    Just version ->
                        text <| "La nouvelle version " ++ version ++ " de l'application est disponible."

                    Nothing ->
                        text "Une nouvelle version de l'application est disponible."
                , button
                    [ type_ "button"
                    , class "btn btn-outline-primary"
                    , onClick reloadPage
                    ]
                    [ text "Mettre à jour" ]
                ]

        _ ->
            text ""


mainMenuLinks : Session -> List MenuLink
mainMenuLinks { enabledSections } =
    let
        addRouteIf flag route =
            if flag then
                Just route

            else
                Nothing
    in
    List.filterMap identity
        [ Just <| Internal "Accueil" Route.Home Home
        , addRouteIf enabledSections.textile <|
            Internal "Textile" Route.TextileSimulatorHome TextileSimulator
        , addRouteIf enabledSections.food <|
            Internal "Alimentaire" Route.FoodBuilderHome FoodBuilder
        , addRouteIf enabledSections.objects <|
            Internal "Objets" (Route.ObjectSimulatorHome Scope.Object) (Object Scope.Object)
        , addRouteIf enabledSections.veli <|
            Internal "Véhicules intermédiaires" (Route.ObjectSimulatorHome Scope.Veli) (Object Scope.Veli)
        , Just <| Internal "Explorateur" (Route.Explore Scope.Textile (Dataset.TextileExamples Nothing)) Explore
        , Just <| Internal "API" Route.Api Api
        , Just <| MailTo "Contact" Env.contactEmail
        ]


secondaryMenuLinks : List MenuLink
secondaryMenuLinks =
    [ Internal "Versions" (Route.Editorial "changelog") (Editorial "changelog")
    , Internal "Statistiques" Route.Stats Stats
    , External "Documentation" Env.gitbookUrl
    , External "Communauté" Env.communityUrl
    , External "Code source" Env.githubUrl
    , External "CGU" Env.cguUrl
    , Internal "Admin" Route.Admin Admin
    ]


headerMenuLinks : Session -> List MenuLink
headerMenuLinks session =
    mainMenuLinks session
        ++ List.filterMap identity
            [ Just <| External "Communauté" Env.communityUrl
            , Just <| External "Documentation" Env.gitbookUrl
            , if Session.isStaff session then
                Just <| Internal "Admin" Route.Admin Admin

              else
                Nothing
            ]


footerMenuLinks : Session -> List MenuLink
footerMenuLinks session =
    mainMenuLinks session
        ++ [ External "Documentation" Env.gitbookUrl
           , External "Communauté" Env.communityUrl
           , MailTo "Contact" Env.contactEmail
           , if Session.isAuthenticated session then
                Internal "Mon compte" (Route.Auth { authenticated = True }) Auth

             else
                Internal "Connexion ou inscription" (Route.Auth { authenticated = False }) Auth
           ]


legalMenuLinks : List MenuLink
legalMenuLinks =
    [ Internal "Accessibilité\u{00A0}: non conforme" (Route.Editorial "accessibilité") (Editorial "accessibilité")
    , Internal "Mentions légales" (Route.Editorial "mentions-légales") (Editorial "mentions-légales")
    , MailTo "Contact" Env.contactEmail
    ]


pageFooter : Session -> Html msg
pageFooter session =
    let
        makeLink link =
            case link of
                External label url ->
                    Link.external [ class "text-decoration-none", href url ]
                        [ text label ]

                Internal label route _ ->
                    Link.internal [ class "text-decoration-none", Route.href route ]
                        [ text label ]

                MailTo label email ->
                    a [ class "text-decoration-none", href <| "mailto:" ++ email ]
                        [ text label ]
    in
    footer
        (class "Footer"
            :: -- Add bottom padding to avoid StagingAlert to hide the version details
               (if isStaging session then
                    [ class "pb-5" ]

                else
                    []
               )
        )
        [ div [ class "FooterNavigation" ]
            [ Container.centered []
                [ div [ class "row" ]
                    [ div [ class "col-6 col-sm-4 col-md-3 col-lg-2" ]
                        [ mainMenuLinks session
                            |> List.map makeLink
                            |> List.map (List.singleton >> li [])
                            |> ul [ class "list-unstyled" ]
                        ]
                    , div [ class "col-6 col-sm-4 col-md-3 col-lg-2" ]
                        [ secondaryMenuLinks
                            |> List.map makeLink
                            |> List.map (List.singleton >> li [])
                            |> ul [ class "list-unstyled" ]
                        ]
                    ]
                ]
            ]
        , Container.centered
            [ class "d-flex flex-wrap justify-content-center justify-content-sm-between align-items-center gap-3"
            ]
            [ a [ class "FooterBrand py-3", href "https://www.ecologie.gouv.fr/" ]
                [ img
                    [ class "FooterLogo"
                    , alt "Ministère de la Transition écologique et de la Cohésion des Territoires"
                    , src "img/logo_mte.svg"
                    , style "width" "201px"
                    , style "height" "135px"
                    , style "aspect-ratio" "auto 201 / 135"
                    ]
                    []
                ]
            , a [ class "FooterBrand py-3", href "https://www.ademe.fr/" ]
                [ img
                    [ class "FooterLogo"
                    , alt "Ademe"
                    , src "img/logo_ademe.svg"
                    , style "height" "120px"
                    , style "aspect-ratio" "auto 79.41 / 93.61"
                    ]
                    []
                ]
            , div [ class "d-flex justify-content-end align-items-center gap-4 mt-2" ]
                [ Link.external [ class "FooterInstitutionLink", href "https://www.ademe.fr/" ]
                    [ text "ademe.fr" ]
                , Link.external [ class "FooterInstitutionLink", href Env.betagouvUrl ]
                    [ text "beta.gouv.fr" ]
                , Link.external [ class "FooterInstitutionLink", href "https://www.ecologie.gouv.fr/fabrique-numerique" ]
                    [ text "Fabrique Numérique" ]
                , Link.external [ class "FooterInstitutionLink", href "https://www.economie.gouv.fr/plan-de-relance" ]
                    [ text "France Relance" ]
                ]
            ]
        , Container.centered []
            [ legalMenuLinks
                |> List.map makeLink
                |> List.map (List.singleton >> li [])
                |> List.intersperse (li [ attribute "aria-hidden" "true", class "text-muted" ] [ text "|" ])
                |> ul [ class "FooterLegal d-flex justify-content-start flex-wrap gap-2 list-unstyled mt-3 pt-2 border-top" ]
            , div [ class "d-flex align-items-center gap-1 fs-9 mb-2" ]
                [ versionLink session.currentVersion
                , text "("
                , Link.internal [ Route.href (Route.Editorial "changelog") ] [ text "changelog" ]
                , text ")"
                ]
            ]
        ]


versionLink : Version -> Html msg
versionLink version =
    case version of
        Version versionData ->
            let
                displayLink url linkText =
                    Link.external
                        [ class "text-decoration-none"
                        , href url
                        ]
                        [ text <| "Version\u{00A0}: " ++ linkText ]
            in
            case ( versionData.hash, versionData.tag ) of
                -- If we have a tag provided, display it by default
                ( _, Just tag ) ->
                    displayLink (Env.githubUrl ++ "/releases/tag/" ++ tag) tag

                -- If we don't have a tag (in dev mode for example) display a link to the commit
                ( hash, _ ) ->
                    displayLink (Env.githubUrl ++ "/commit/" ++ hash) hash

        _ ->
            text ""


pageHeader : Config msg -> Html msg
pageHeader { session, activePage, openMobileNavigation, loadUrl, switchVersion } =
    header
        [ class "Header shadow-sm"
        , classList [ ( "mb-2", activePage /= Home ) ]
        , attribute "role" "banner"
        ]
        [ div [ class "MobileMenuButton" ]
            [ button
                [ type_ "button"
                , class "d-inline-block d-sm-none btn m-0 p-0"
                , attribute "aria-label" "Ouvrir la navigation"
                , title "Ouvrir la navigation"
                , onClick openMobileNavigation
                ]
                [ span [ class "fs-3" ] [ Icon.ham ] ]
            ]
        , Container.centered [ class "d-flex justify-content-between align-items-center gap-2" ]
            [ a
                [ class "HeaderBrand text-decoration-none d-flex align-items-center gap-3 gap-sm-5 pe-3"

                -- Note: this class makes Dashlord understand DSFR guidelines are implemented
                -- https://dashlord.mte.incubateur.net/dashlord/url/ecobalyse-beta-gouv-fr/best-practices/#dsfr
                , class "fr-header__brand"
                , href "/"
                , onClick (loadUrl "/")
                ]
                [ img [ class "HeaderLogo", alt "République Française", src "img/republique-francaise.svg" ] []
                , h1 [ class "HeaderTitle" ]
                    [ img [ class "HeaderSubLogo", alt "BetaGouv", src "img/logo_betagouv.jpg" ] []
                    , text "Ecobalyse"
                    ]
                ]
            , session.releases
                |> RemoteData.map
                    (\releases ->
                        (case Version.getTag session.currentVersion of
                            Just _ ->
                                releases

                            Nothing ->
                                -- If we're not on a tag, add an "unreleased" entry to reflect that
                                Github.unreleased :: releases
                        )
                            |> List.map
                                (\release ->
                                    option [ selected <| Version.is release session.currentVersion ]
                                        [ text release.tag ]
                                )
                    )
                |> RemoteData.withDefault []
                |> select
                    [ class "VersionSelector d-none d-sm-block form-select form-select-sm w-auto"
                    , onInput switchVersion
                    ]
            , div [ class "HeaderAuthLink" ]
                [ a
                    [ class "d-none d-sm-block flex-fill text-end"
                    , Route.href (Route.Auth { authenticated = False })
                    ]
                    [ if Session.isAuthenticated session then
                        text "Mon compte"

                      else
                        text "Connexion ou inscription"
                    ]
                , a
                    [ class "d-none d-sm-block flex-fill text-end"
                    , Route.href Route.Auth2
                    ]
                    [ if Session.isAuthenticated2 session then
                        text "Mon compte (new auth)"

                      else
                        text "Connexion ou inscription (new auth)"
                    ]
                ]
            ]
        , Container.fluid [ class "border-top" ]
            [ div [ class "container" ]
                [ nav
                    [ class "text-end text-sm-start"
                    , attribute "role" "navigation"
                    , attribute "aria-label" "Menu principal"
                    ]
                    [ headerMenuLinks session
                        |> List.map (viewNavigationLink activePage)
                        |> div [ class "HeaderNavigation d-none d-sm-flex navbar-nav flex-row overflow-auto" ]
                    ]
                ]
            ]
        ]


viewNavigationLink : ActivePage -> MenuLink -> Html msg
viewNavigationLink activePage link =
    case link of
        External label url ->
            Link.external [ class "nav-link link-external-muted", href url ]
                [ text label ]

        Internal label route page ->
            Link.internal
                (class "nav-link"
                    :: classList [ ( "active", page == activePage ) ]
                    :: Route.href route
                    :: (if page == activePage then
                            [ attribute "aria-current" "page" ]

                        else
                            []
                       )
                )
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
notificationView { closeNotification, resetSessionStore } notification =
    -- TODO:
    -- - absolute positionning
    case notification of
        Session.GenericError title message ->
            Alert.simple
                { level = Alert.Danger
                , title = Just title
                , close = Just (closeNotification notification)
                , content = [ text message ]
                }

        Session.GenericInfo title message ->
            Alert.simple
                { level = Alert.Info
                , title = Just title
                , close = Just (closeNotification notification)
                , content = [ text message ]
                }

        Session.StoreDecodingError decodeError ->
            Alert.simple
                { level = Alert.Warning
                , title = Just "Erreur de récupération de session"
                , close = Nothing
                , content =
                    [ p [] [ text "Votre précédente session n'a pas pu être récupérée, elle doit donc être réinitialisée." ]
                    , p [] [ button [ class "btn btn-primary", onClick resetSessionStore ] [ text "D’accord, réinitialiser la session" ] ]
                    , details []
                        [ summary [] [ text "Afficher les détails techniques de l'erreur" ]
                        , pre [] [ text <| Decode.errorToString decodeError ]
                        ]
                    ]
                }


notFound : Html msg
notFound =
    Container.centered [ class "pb-5" ]
        [ h1 [ class "mb-3" ] [ text "Page non trouvée" ]
        , p [] [ text "La page que vous avez demandé n'existe pas." ]
        , a [ Route.href Route.Home ] [ text "Retour à l'accueil" ]
        ]


restricted : Session -> Html msg
restricted session =
    Container.centered [ class "pb-5" ]
        [ h1 [ class "mb-3" ] [ text "Accès refusé" ]
        , p [] [ text "Cette page n'est accessible qu'à l'équipe Ecobalyse." ]
        , p []
            [ a [ Route.href <| Route.Auth { authenticated = False } ]
                [ if Session.isAuthenticated session then
                    text "Authentifiez-vous avec les droits appropriés"

                  else
                    text "Connectez-vous"
                ]
            , text "\u{00A0}ou\u{00A0}"
            , a [ Route.href Route.Home ] [ text "retournez à l'accueil" ]
            ]
        ]


loading : Html msg
loading =
    Container.centered [ class "pb-5" ]
        [ Spinner.view
        ]


mobileNavigation : Config msg -> Html msg
mobileNavigation { activePage, closeMobileNavigation, loadUrl, session } =
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
                [ h3 [ class "h5 offcanvas-title", id "navigationLabel" ]
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
                [ footerMenuLinks session
                    |> List.map (viewNavigationLink activePage)
                    |> div [ class "nav nav-pills flex-column" ]
                , h4 [ class "h6 mt-3" ] [ text "Versions" ]
                , session.releases
                    |> RemoteData.map
                        (List.map
                            (\release ->
                                if Version.is release session.currentVersion then
                                    strong [] [ text release.tag ]

                                else
                                    a
                                        [ class "nav-link"
                                        , href <| "/versions/" ++ release.tag
                                        , onClick (loadUrl <| "/versions/" ++ release.tag)
                                        ]
                                        [ text release.tag ]
                            )
                        )
                    |> RemoteData.withDefault []
                    |> div [ class "nav nav-pills flex-column" ]
                ]
            ]
        , div [ class "offcanvas-backdrop fade show" ] []
        ]
