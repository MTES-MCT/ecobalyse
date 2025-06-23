module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Scope as Scope
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports
import Route exposing (Route)
import Views.Alert as Alert
import Views.Container as Container
import Views.Link as Link
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = AppMessage App.Msg
    | NoOp


type alias ButtonParams =
    { label : String
    , subLabel : Maybe String
    , callToAction : Bool
    , route : Route
    , testId : String
    }


init : Session -> PageUpdate Model Msg
init session =
    App.createUpdate session ()
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        -- FIXME: this is to have a single use in the codebase for now so elm-review doesn't complain,
        -- but we should eventually remove this from the homepage as it's of no actual use
        AppMessage appMsg ->
            App.createUpdate session model
                |> App.withAppMsgs [ appMsg ]

        NoOp ->
            App.createUpdate session model


simulatorButton : ButtonParams -> Html Msg
simulatorButton { label, subLabel, callToAction, route, testId } =
    a
        [ class "btn btn-lg d-flex flex-column align-items-center justify-content-center"
        , classList [ ( "btn-primary", callToAction ), ( "btn-outline-primary", not callToAction ) ]
        , Route.href route
        , attribute "data-testid" testId
        ]
        [ text label
        , case subLabel of
            Just sub ->
                Html.cite [ class "fw-normal fs-7 d-block" ] [ text sub ]

            Nothing ->
                text ""
        ]


viewHero : Session -> Html Msg
viewHero { enabledSections } =
    Container.centered [ class "pt-4 pb-5" ]
        [ div [ class "px-5" ]
            [ h2 [ class "h1" ]
                [ text "Calculez le coût environnemental de vos produits" ]
            , div [ class "fs-5 mt-3 mb-5" ]
                [ """Ecobalyse permet de comprendre et d’exprimer les impacts environnementaux des produits distribués en France
                par le calcul d’un coût en points d’impact\u{202F}: **le coût environnemental**.
                Découvrez nos outils et notre périmètre d’action\u{202F}!"""
                    |> Markdown.simple []
                ]
            , div [ class "d-flex flex-column flex-sm-row gap-3 mb-4" ]
                [ simulatorButton
                    { label = "Calculer l’impact d’un vêtement"
                    , subLabel = Nothing
                    , callToAction = True
                    , route = Route.TextileSimulatorHome
                    , testId = "textile-callout-button"
                    }
                , if enabledSections.food then
                    simulatorButton
                        { label = "Calculer l’impact de l’alimentation"
                        , subLabel = Just "Méthodologie en concertation"
                        , callToAction = False
                        , route = Route.FoodBuilderHome
                        , testId = "food-callout-button"
                        }

                  else
                    text ""
                , if enabledSections.objects then
                    simulatorButton
                        { label = "Calculer l’impact d’un objet"
                        , subLabel = Just "Simulateur en construction"
                        , callToAction = False
                        , route = Route.ObjectSimulatorHome Scope.Object
                        , testId = "object-callout-button"
                        }

                  else
                    text ""
                ]

            -- FIXME: remove me
            , div [ class "d-flex flex-column gap-4" ]
                [ div []
                    [ button [ onClick <| AppMessage <| App.AddToast "La vie est belle <3" ]
                        [ text "Test notification" ]
                    ]
                , Alert.simple
                    { attributes = []
                    , title = Just "Titre de l'alerte"
                    , content = [ text "Lorem ipsum dolor sit amet" ]
                    , level = Alert.Success
                    , close = Nothing
                    }
                , div [ class "fr-alert fr-alert--success shadow-sm" ]
                    [ p [ class "mb-1" ] [ text "Lorem ipsum dolor sit amet" ] ]
                , div [ class "fr-alert fr-alert--info shadow-sm" ]
                    [ p [ class "mb-1" ] [ text "Lorem ipsum dolor sit amet" ] ]
                , div [ class "fr-alert fr-alert--warning shadow-sm" ]
                    [ p [ class "mb-1" ] [ text "Lorem ipsum dolor sit amet" ] ]
                , div [ class "fr-alert fr-alert--error shadow-sm" ]
                    [ p [ class "mb-1" ] [ text "Lorem ipsum dolor sit amet" ] ]
                , div [ class "fr-alert fr-alert--error shadow-sm" ]
                    [ h3 [ class "h5 mb-1" ] [ text "Titre de l'erreur" ]
                    , p [ class "mb-1" ] [ text "description de l'erreur" ]
                    , pre [ class "bg-light p-2 mb-0" ] [ text "foo\n  bar" ]
                    , button [ class "fr-link fr-link--close" ]
                        [ text "Masquer le message" ]
                    ]
                ]
            ]
        ]


viewInfo : Html Msg
viewInfo =
    Container.centered [ id "decouvrir-ecobalyse", class "overlappedImage" ]
        [ img
            [ src "img/illustration-score.png"
            , alt "Une étiquette présentant différents scores d’impact environnemental"
            ]
            []
        , div [ class "d-flex flex-column gap-2" ]
            [ h3 [ class "mb-1" ] [ text "En savoir plus sur les données et les impacts\u{202F}?" ]
            , """Vous pouvez en savoir plus sur nos données sources et nos modélisations en vous rendant dans [\u{202F}l’explorateur\u{202F}]({url_explorer}).
            Consultez également le détail des impacts environnementaux de vos simulations en [\u{202F}créant votre compte Ecobalyse\u{202F}]({url_account})."""
                |> String.replace "{url_explorer}" (Route.toString <| Route.Explore Scope.Textile (Dataset.TextileExamples Nothing))
                |> String.replace "{url_account}" (Route.toString Route.Auth)
                |> Markdown.simple []
            ]
        ]


viewTools : Html Msg
viewTools =
    Container.centered []
        [ h3 [ class "mb-2" ] [ text "Les dessous du coût environnemental" ]
        , """Le coût environnemental s’appuie sur la méthodologie d’analyse du cycle de vie PEF (Product Environmental Footprint)
        complétée sur les aspects qu’elle ne couvre pas encore. Il est issu du travail des pouvoirs publics (ADEME, Ministère de la transition écologique, ...)
        en s’appuyant sur des experts et des parties prenantes mobilisées notamment lors de phase de concertation.
        Ce cadre méthodologique est explicité dans [la page de documentation]({url_gitbook})."""
            |> String.replace "{url_gitbook}" Env.gitbookUrl
            |> Markdown.simple []
        , div [ class "d-flex mt-4 gap-3" ]
            [ Link.external
                [ class "btn btn-primary"
                , href <| Env.gitbookUrl
                ]
                [ text "Consulter la méthodologie du coût environnemental" ]
            ]
        ]


viewContribution : Html Msg
viewContribution =
    Container.centered []
        [ h3 [ class "mb-2" ] [ text "Des questions sur nos outils ou la méthode\u{202F}?" ]
        , """Ecobalyse est un outil ouvert et gratuit. Vos retours sur la méthode ou sur notre outil nous sont précieux.""" |> Markdown.simple []
        , div [ class "d-flex mt-4 gap-3" ]
            [ Link.external
                [ class "btn btn-primary"
                , href <| Env.communityUrl
                ]
                [ text "Rejoignez la communauté" ]
            , Link.external
                [ class "btn btn-outline-primary"
                , href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter"
                ]
                [ text "Contactez l’équipe Écobalyse" ]
            ]
        ]


viewApi : Html Msg
viewApi =
    Container.centered []
        [ h3 [ class "mb-2" ] [ text "Accéder au coût environnemental à travers notre API" ]
        , """[L’API HTTP Ecobalyse]({api_url}) permet de calculer les impacts environnementaux des différents produits. Elle est expérimentale et donc ne garantit pas de continuité de service à ce stade."""
            |> String.replace "{api_url}" (Route.toString <| Route.Api)
            |> Markdown.simple []
        , """Des questions\u{202F}? Consultez notre [\u{202F}FAQ API Ecobalyse\u{202F}]({api_faq_url})."""
            |> String.replace "{api_faq_url}" (Route.toString <| Route.Editorial "api-faq")
            |> Markdown.simple []
        ]


view : Session -> ( String, List (Html Msg) )
view session =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ div [ class "bg-light pt-5" ]
                [ viewHero session ]
            , viewInfo
            , div [ class "bg-light pt-5 pb-5" ]
                [ viewTools ]
            , div [ class "pt-5 mb-5" ]
                [ viewContribution ]
            , div [ class "bg-light pt-5 pb-5" ]
                [ viewApi ]
            ]
      ]
    )
