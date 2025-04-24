module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Data.Dataset as Dataset
import Data.Env as Env
import Data.Scope as Scope
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Route
import Views.Container as Container
import Views.Link as Link
import Views.Markdown as Markdown


type alias Model =
    { modal : Modal
    }


type Msg
    = NoOp


type Modal
    = NoModal


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { modal = NoModal }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


viewHero : Session -> Modal -> Html Msg
viewHero { enabledSections } modal =
    Container.centered [ class "pt-4 pb-5" ]
        [ div [ class "px-5" ]
            [ h2 [ class "h1" ]
                [ text "Calculez le coût environnemental de vos produits" ]
            , div [ class "fs-5 mt-3 mb-5" ]
                [ """Ecobalyse permet de comprendre et d’exprimer les impacts environnementaux des produits distribués en France par le calcul d’un coût en points d’impact\u{202F}: le coût environnemental. Découvrez nos outils et notre périmètre d’action\u{202F}!"""
                    |> Markdown.simple []
                ]
            , div [ class "d-flex flex-column flex-sm-row gap-3 mb-4" ]
                [ a [ class "btn btn-lg btn-primary d-flex align-items-center justify-content-center", Route.href Route.TextileSimulatorHome ]
                    [ text "Calculer l’impact d’un vêtement" ]
                , if enabledSections.food then
                    a [ class "btn btn-lg btn-outline-primary", Route.href Route.FoodBuilderHome ]
                        [ text "Calculer l’impact de l’alimentation", br [] [], Html.cite [ class "fw-normal fs-7 d-block" ] [ text "Méthodologie en concertation" ] ]

                  else
                    text ""
                , if enabledSections.objects then
                    a [ class "btn btn-lg btn-outline-primary", Route.href (Route.ObjectSimulatorHome Scope.Object) ]
                        [ text "Calculer l’impact d’un objet"
                        , Html.cite [ class "fw-normal fs-7 d-block" ] [ text "Simulateur en construction" ]
                        ]

                  else
                    text ""
                ]
            ]
        , case modal of
            NoModal ->
                text ""
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
            , """Vous pouvez en savoir plus sur nos données sources et nos modélisations en vous rendant dans [\u{202F}l’explorateur\u{202F}]({url_explorer}). Consultez également le détail des impacts environnementaux de vos simulations en [\u{202F}créant votre compte Ecobalyse\u{202F}]({url_account})."""
                |> String.replace "{url_explorer}" (Route.toString <| Route.Explore Scope.Textile (Dataset.TextileExamples Nothing))
                |> String.replace "{url_account}" (Route.toString <| Route.Auth { authenticated = False })
                |> Markdown.simple []
            ]
        ]


viewTools : Html Msg
viewTools =
    Container.centered []
        [ h3 [ class "mb-2" ] [ text "Les dessous du coût environnemental" ]
        , """Le coût environnemental s’appuie sur la méthodologie d’analyse du cycle de vie PEF (Product Environmental Footprint) complétée sur les aspects qu’elle ne couvre pas encore. Il est issu du travail des pouvoirs publics (ADEME, Ministère de la transition écologique, ...) en s’appuyant sur des experts et des parties prenantes mobilisées notamment lors de phase de concertation. Ce cadre méthodologique est explicité."""
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
        , """Ecobalyse est un outil ouvert et gratuit. Vos retours sur notre méthode ou sur notre outil sont riches.""" |> Markdown.simple []
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


view : Session -> Model -> ( String, List (Html Msg) )
view session { modal } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ div [ class "bg-light pt-5" ]
                [ viewHero session modal ]
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


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none
