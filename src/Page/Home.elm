module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Browser.Navigation as Nav
import Data.Env as Env
import Data.Key as Key
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Route exposing (Route)
import Views.Container as Container
import Views.Link as Link
import Views.Markdown as Markdown
import Views.Modal as ModalView


type alias Model =
    { modal : Modal
    }


type Msg
    = LoadRoute Route
    | NoOp
    | ScrollIntoView String


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
        LoadRoute route ->
            ( model, session, Nav.load <| Route.toString route )

        NoOp ->
            ( model, session, Cmd.none )

        ScrollIntoView nodeId ->
            ( model, session, Ports.scrollIntoView nodeId )


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
                [ a [ class "btn btn-lg btn-primary", Route.href Route.TextileSimulatorHome ]
                    [ text "Calculateur textile" ]
                , if enabledSections.food then
                    a [ class "btn btn-lg btn-outline-primary", Route.href Route.FoodBuilderHome ]
                        [ text "Calculateur alimentaire", br [] [], Html.cite [ class "fw-normal fs-7 d-block" ] [ text "Méthodologie en concertation" ] ]

                  else
                    text ""
                , if enabledSections.objects then
                    a [ class "btn btn-lg btn-outline-primary", Route.href (Route.ObjectSimulatorHome Scope.Object) ]
                        [ text "Calculateur objet"
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
            , alt "Une étiquette présentant différents scores d'impact environnemental"
            ]
            []
        , div [ class "d-flex flex-column gap-2" ]
            [ h3 [ class "mb-1" ] [ text "Un coût environnemental pour informer les consommateurs" ]
            , blockquote [ class "d-inline-block fw-bold fs-5 mx-5 mt-3 mb-2" ]
                [ p [ class "mb-0" ]
                    [ text "«\u{00A0}74%\u{00A0}des Français aimeraient avoir plus d’informations sur l’impact environnemental et sociétal des produits qu’ils achètent.\u{00A0}»" ]
                , Html.cite [ class "fw-normal fs-7 text-muted mb-5" ]
                    [ text "14ème baromètre de la consommation responsable Greenflex et ADEME - 2021" ]
                ]
            , h3 [ class "my-3" ] [ text "Inscrit dans la loi Climat et Résilience de 2021" ]
            , p [] [ text "“Un affichage destiné à apporter au consommateur une information relative aux impacts environnementaux (...) d'un bien, d'un service ou d'une catégorie de biens ou de services mis sur le marché national est rendu obligatoire” — Article L.541-9-11 du code de l’environnement" ]
            , h3 [ class "my-3" ] [ text "Les secteurs Textile et Alimentaire, premiers concernés" ]
            , """Un projet de méthodologie est élaboré à partir de **29 expérimentations** qui se sont tenues
                     en 2021 et 2022, des travaux d’un **conseil scientifique alimentaire** et d’un **comité d’experts
                     textile**, de nombreux échanges avec les parties prenantes depuis la mise en ligne d’Ecobalyse…"""
                |> Markdown.simple []
            , """Pour le secteur textile, la méthodologie aujourd’hui présentée est un **premier projet de
                     référentiel technique**. Elle est soumise à concertation et **toute contribution est [la bienvenue]({url}).**"""
                |> String.replace "{url}" Env.communityUrl
                |> Markdown.simple []
            , """Le projet de calculateur pour le produits alimentaires a été temporairement retiré, dans
                     l’attente de la présentation d’une première proposition de méthode complète."""
                |> Markdown.simple []
            ]
        ]


viewTools : Session -> Html Msg
viewTools { enabledSections } =
    Container.centered []
        [ h4 [ class "fw-normal mb-5 lh-base" ]
            [ text "Afin d’amorcer la transition vers un modèle de production plus durable"
            , br [] []
            , h2 [ class "h4" ] [ text "Écobalyse met à la disposition des entreprises : " ]
            ]
        , div [ class "row d-flex mb-5" ]
            [ div [ class "col-md-4 mb-3 mb-md-0" ]
                [ div
                    [ class "card d-flex flex-warp align-content-between text-decoration-none h-100"
                    , attribute "role" "button"
                    ]
                    [ img
                        [ class "w-100"
                        , src "img/img_outil_calculateur.png"
                        , style "width" "450px"
                        , style "height" "auto"
                        , style "aspect-ratio" "auto 450 / 254"
                        , alt "Capture d'écran du calculateur alimentaire"
                        ]
                        []
                    , div [ class "card-body p-4 pb-0 fs-7" ]
                        [ h3 [ class "h5 fw-bold" ] [ text "Calculateur de coût environnemental" ]
                        , """Un calculateur gratuit qui permet de modéliser le coût environnemental d’un produit, et
                             donc ses différents impacts, sur la base de critères simples et accessibles aux marques."""
                            |> Markdown.simple []
                        ]
                    , div [ class "card-footer bg-white border-top-0 text-end fw-bold fs-5 px-4" ] [ text "→" ]
                    ]
                ]
            , div [ class "col-md-4 mb-3 mb-md-0" ]
                [ a
                    [ class "card d-flex flex-warp align-content-between text-decoration-none link-dark h-100"
                    , href Env.gitbookUrl
                    ]
                    [ img
                        [ class "w-100"
                        , src "img/img_outil_methode.png"
                        , style "width" "450px"
                        , style "height" "auto"
                        , style "aspect-ratio" "auto 450 / 254"
                        , alt "Capture d'écran de la documentation"
                        ]
                        []
                    , div [ class "card-body p-4 pb-0 fs-7" ]
                        [ h3 [ class "h5 fw-bold" ] [ text "Support de travail sur la méthode" ]
                        , p [] [ text "Les orientations présentées participent à la construction de la future méthodologie réglementaire." ]
                        , div []
                            [ em [] [ text "Écobalyse, c’est aussi un mode de collaboration ouvert à la critique et aux suggestions, en vue d’aider à élaborer la future méthode réglementaire française (contribuez!)" ]
                            ]
                        ]
                    , div [ class "card-footer bg-white border-top-0 text-end fw-bold fs-5 px-4" ] [ text "→" ]
                    ]
                ]
            , div [ class "col-md-4 mb-3 mb-md-0" ]
                [ a
                    [ class "card d-flex flex-warp align-content-between text-decoration-none link-dark h-100"
                    , href "https://ecobalyse.beta.gouv.fr/#/api"
                    ]
                    [ img
                        [ class "w-100"
                        , src "img/img_outil_api.png"
                        , style "width" "450px"
                        , style "height" "auto"
                        , style "aspect-ratio" "auto 450 / 254"
                        , alt "Engrenages représentant une API"
                        ]
                        []
                    , div [ class "card-body p-4 pb-0 fs-7" ]
                        [ h3 [ class "h5 fw-bold" ] [ text "API ouverte" ]
                        , div [] [ text "Une interface de programmation applicative (API) permet de connecter le calculateur Écobalyse à tout autre service numérique : gestion d’entreprises (ERP), bases de données de produits (PIM), services SaaS… " ]
                        ]
                    , div [ class "card-footer bg-white border-top-0 text-end fw-bold fs-5 px-4" ] [ text "→" ]
                    ]
                ]
            ]
        ]


viewContribution : Html Msg
viewContribution =
    Container.centered [ class "Contribution" ]
        [ div [ class "row d-flex align-items-start" ]
            [ div [ class "col-sm-4 bg-info-dark text-white px-3 py-5" ]
                [ img
                    [ src "img/picto_bulle.png"
                    , class "pb-4"
                    , style "width" "60px"
                    , style "height" "auto"
                    , style "aspect-ratio" "auto 60 / 60"
                    , alt "Picto d'une bulle de conversation"
                    ]
                    []
                , p [] [ q [] [ text "Lorsque j’applique la méthode sur mes produits, je suis surpris du résultat\u{00A0}!" ] ]
                , p [] [ q [] [ text "Comment pourrait-on prendre en compte les labels dont je bénéficie\u{00A0}?" ] ]
                , p [] [ q [] [ text "Comment dois-je calculer ma largeur de gamme si je suis distribué sur une plateforme\u{00A0}?" ] ]
                ]
            , div [ class "col-sm-8 flex-columns gap-5 bg-light mt-5 mb-5 p-5" ]
                [ h3 [ class "h5 fw-bold mb-3" ] [ text "Contribuez à la concertation en cours sur la méthode de calcul du coût environnemental" ]
                , """La méthode présentée aujourd’hui dans Ecobalyse est [soumise à concertation]({url}).
                     Les retours de chacun, positifs ou critiques, seront utiles\u{00A0}!

                     Vous êtes une **marque**, un **producteur**, un **bureau d’étude** ou un **distributeur**\u{00A0}:

- **Faites préciser** les aspects qui devraient l’être
- **Partagez** les résultats de calcul appliqués à vos produits
- **Suggérez** une amélioration de la méthodologie ou du calculateur
                 """
                    |> String.replace "{url}" Env.communityUrl
                    |> Markdown.simple []
                , div [ class "d-flex justify-content-center mt-4 gap-3" ]
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
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session { modal } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ div [ class "bg-light pt-5" ]
                [ viewHero session modal ]
            , viewInfo
            , div [ class "bg-light pt-5" ]
                [ viewTools session ]
            , div [ class "pt-5" ]
                [ viewContribution ]
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none
