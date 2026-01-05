module Page.Home exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Browser.Navigation as Nav
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Scope as Scope
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports
import Route exposing (Route)
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = NoOp
    | ProcessLink Link


type Link
    = ExternalLink String
    | RouteLink Route


type alias ButtonParams =
    { label : String
    , subLabel : Maybe String
    , callToAction : Bool
    , link : Link
    , testId : String
    }


init : Session -> PageUpdate Model Msg
init session =
    App.createUpdate session ()
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        NoOp ->
            App.createUpdate session model

        ProcessLink (ExternalLink url) ->
            App.createUpdate session model
                |> App.withCmds [ Nav.load url ]

        ProcessLink (RouteLink route) ->
            App.createUpdate session model
                |> App.withCmds
                    [ Ports.scrollTo { x = 0, y = 0 }
                    , Nav.load <| Route.toString route
                    ]


simulatorButton : ButtonParams -> Html Msg
simulatorButton { label, subLabel, callToAction, link, testId } =
    button
        [ type_ "button"
        , class "btn btn-lg d-flex flex-column align-items-center justify-content-center"
        , classList [ ( "btn-primary", callToAction ), ( "btn-outline-primary", not callToAction ) ]
        , onClick <| ProcessLink link
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
            [ h2 [ class "h1" ] [ text "Calculez le coût environnemental de vos produits" ]
            , div [ class "fs-5 mt-3 mb-5" ]
                [ """Ecobalyse permet de comprendre et d’exprimer les impacts environnementaux des produits distribués en France
                     par le calcul d’un coût en points d’impact\u{202F}: **le coût environnemental**.
                     Découvrez nos outils et notre périmètre d’action\u{202F}!"""
                    |> Markdown.simple []
                ]
            , [ ( True
                , { label = "Calculer l’impact d’un vêtement"
                  , subLabel = Just "Version réglementaire"
                  , callToAction = True
                  , link = ExternalLink "/versions/v7.0.0/#/textile/simulator"
                  , testId = "textile-callout-button"
                  }
                )
              , ( enabledSections.food
                , { label = "Calculer l’impact de l’alimentation"
                  , subLabel = Just "Méthodologie en concertation"
                  , callToAction = False
                  , link = RouteLink Route.FoodBuilderHome
                  , testId = "food-callout-button"
                  }
                )
              , ( enabledSections.objects
                , { label = "Calculer l’impact d’un objet"
                  , subLabel = Just "Simulateur en construction"
                  , callToAction = False
                  , link = RouteLink <| Route.ObjectSimulatorHome Scope.Object
                  , testId = "object-callout-button"
                  }
                )
              , ( enabledSections.veli
                , { label = "Calculer l’impact d’un véhicule"
                  , subLabel = Just "Simulateur en construction"
                  , callToAction = False
                  , link = RouteLink <| Route.ObjectSimulatorHome Scope.Veli
                  , testId = "veli-callout-button"
                  }
                )
              ]
                |> List.filterMap
                    (\( enabled, button ) ->
                        if enabled then
                            Just <| simulatorButton button

                        else
                            Nothing
                    )
                |> div [ class "d-flex flex-column flex-lg-row gap-3 mb-4" ]
            ]
        ]


viewInfo : Html Msg
viewInfo =
    Container.centered []
        [ div [ class "d-flex flex-column gap-2 p-0 px-md-5" ]
            [ h2 [ class "h3" ] [ text "Afficher le coût environnemental" ]
            , """Le coût environnemental peut être utilisé pour comprendre, informer, enrichir un bilan carbone
ou pour différentes politiques publiques (marchés publics, eco-modulation…)

L’affichage du coût environnemental d’un produit permet d’**informer le consommateur**. Depuis la loi Climat et
Résilience de 2021, des travaux sont engagés pour permettre cet affichage. Ils portent sur les vêtements, les
produits alimentaires ou encore l’ameublement. Pour plus d’informations, vous pouvez consulter\u{202F}:

- le [site de l’ADEME](https://affichage-environnemental.ademe.fr)
- le site du [ministère en charge de l’écologie](https://www.ecologie.gouv.fr/politiques-publiques/affichage-environnemental-vêtements)"""
                |> Markdown.simple []
            , div [ class "d-flex flex-column flex-lg-row gap-3" ]
                [ span [ class "home-illustration" ]
                    [ img
                        [ src "img/etiquette-exemple.png"
                        , alt "Exemple d'étiquetage environnemental réglementaire de 930 points d'impact"
                        ]
                        []
                    ]
                , div [ class "row g-3" ]
                    [ div [ class "col-lg-6 d-flex flex-column justify-content-between gap-2 h-100" ]
                        [ """Pour les vêtements, **un cadre règlementaire complet a été publié le 9 septembre 2025**.
                             Il encadre l’affichage volontaire du coût environnemental des vêtements. Une méthodologie
                             de calcul règlementaire est ainsi arrêtée, la **v7.0.0**."""
                            |> Markdown.simple []
                        , button
                            [ class "btn btn-primary"
                            , onClick <| ProcessLink <| ExternalLink "/versions/v7.0.0/#/textile/simulator"
                            ]
                            [ text "Utiliser la version réglementaire 7.0.0" ]
                        ]
                    , div [ class "col-lg-6 d-flex flex-column justify-content-between gap-3 h-100" ]
                        [ """Pour afficher le coût environnemental sur vos produits textiles, il est nécessaire de **déclarer leur coût**
                             sur un portail dédié\u{202F}!"""
                            |> Markdown.simple []
                        , Link.external
                            [ class "btn btn-outline-primary"
                            , href "https://affichage-environnemental.ecobalyse.beta.gouv.fr/declarations"
                            ]
                            [ text "Accéder au portail de déclaration" ]
                        ]
                    ]
                ]
            ]
        ]


viewTools : Html Msg
viewTools =
    Container.centered []
        [ div [ class "row px-md-5 gap-5 gap-md-0" ]
            [ div [ class "col-md-6 d-flex flex-column justify-content-between gap-2" ]
                [ h3 [ class "h4 d-flex align-items-baseline gap-2" ]
                    [ span [ class "fs-5" ] [ Icon.search ]
                    , text "Les dessous du coût environnemental"
                    ]
                , """Le coût environnemental s’appuie sur la méthodologie [ACV]({url_acv} "Analyse en Cycle de Vie")
                     du [PEF]({url_pef} "Product Environmental Footprint")
                     **complétée sur les aspects qu’elle ne couvre pas encore**. Il est issu du travail des pouvoirs publics
                     en s’appuyant sur des **experts** et parties prenantes mobilisés lors de concertations."""
                    |> String.replace "{url_acv}" "https://fr.wikipedia.org/wiki/Analyse_du_cycle_de_vie"
                    |> String.replace "{url_pef}" "https://eplca.jrc.ec.europa.eu/EnvironmentalFootprint.html"
                    |> Markdown.simple [ class "flex-fill" ]
                , div [ class "d-flex mt-3 gap-3" ]
                    [ Link.external
                        [ class "btn btn-primary text-truncate"
                        , href <| Env.gitbookUrl
                        ]
                        [ text "Parcourir la documentation méthodologique" ]
                    ]
                ]
            , div [ class "col-md-6 d-flex flex-column justify-content-between gap-2" ]
                [ h3 [ class "h4 d-flex align-items-baseline gap-2" ]
                    [ span [ class "fs-5" ] [ Icon.material ]
                    , text "Impacts et données détaillées"
                    ]
                , """Accédez aux **impacts environnementaux détaillés** de vos simulations en créant un compte utilisateur
                     et à l'ensemble des modélisations et **données sources** en parcourant l’explorateur.""" |> Markdown.simple [ class "flex-fill" ]
                , div [ class "d-flex mt-3 gap-3" ]
                    [ Link.external
                        [ class "btn btn-primary"
                        , href <| Route.toString <| Route.AuthSignup
                        ]
                        [ text "Créer un compte Ecobalyse" ]
                    , button
                        [ class "btn btn-outline-primary"
                        , onClick <| ProcessLink <| RouteLink <| Route.Explore Scope.Textile (Dataset.TextileExamples Nothing)
                        ]
                        [ text "Explorer les données" ]
                    ]
                ]
            ]
        ]


viewTools2 : Html Msg
viewTools2 =
    Container.centered []
        [ div [ class "row px-md-5 gap-5 gap-md-0" ]
            [ div [ class "col-md-6 d-flex flex-column justify-content-between gap-2" ]
                [ h3 [ class "h4 d-flex align-items-baseline gap-2" ]
                    [ span [ class "fs-5" ] [ Icon.plug ]
                    , text "L'API Ecobalyse"
                    ]
                , """[L’API HTTP Ecobalyse]({api_url}) permet de calculer les impacts environnementaux des différents produits.
             Elle est expérimentale et donc ne garantit pas de continuité de service à ce stade."""
                    |> String.replace "{api_url}" (Route.toString <| Route.Api)
                    |> Markdown.simple []
                , """Des questions\u{202F}? Consultez notre [\u{202F}FAQ dédiée à l’API\u{202F}]({api_faq_url})."""
                    |> String.replace "{api_faq_url}" (Route.toString <| Route.Editorial "api-faq")
                    |> Markdown.simple []
                ]
            , div [ class "col-md-6 d-flex flex-column justify-content-between gap-2" ]
                [ h3 [ class "h4 d-flex align-items-baseline gap-2" ]
                    [ span [ class "fs-5" ] [ Icon.question ]
                    , text "Des questions\u{00A0}?"
                    ]
                , """Ecobalyse est un outil **ouvert et gratuit**. Vos retours sur la méthode ou sur notre outil nous sont précieux."""
                    |> Markdown.simple [ class "flex-fill" ]
                , div [ class "d-flex flex-column flex-xl-row mt-3 gap-3" ]
                    [ Link.external
                        [ class "btn btn-primary text-truncate"
                        , href <| Env.communityUrl
                        ]
                        [ text "Rejoindre la communauté" ]
                    , Link.external
                        [ class "btn btn-outline-primary text-truncate"
                        , href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter"
                        ]
                        [ text "Contacter l’équipe Écobalyse" ]
                    ]
                ]
            ]
        ]


view : Session -> ( String, List (Html Msg) )
view session =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ div [ class "bg-light pt-5 shadow-inner-top" ]
                [ viewHero session ]
            , div [ class "p-5" ]
                [ viewInfo ]
            , div [ class "bg-light p-5" ]
                [ viewTools ]
            , div [ class "p-5" ]
                [ viewTools2 ]
            ]
      ]
    )
