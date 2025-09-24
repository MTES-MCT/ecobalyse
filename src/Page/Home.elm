module Page.Home exposing
    ( Model
    , Msg(..)
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
                |> App.withCmds [ Nav.load <| Route.toString route ]


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
    viewSection "Afficher le coût environnemental"
        [ """![Exemple d'étiquetage environnemental réglementaire de 360 points d'impact](img/etiquette-exemple.png)
Le coût environnemental peut être utilisé pour comprendre, informer, enrichir un bilan carbone
ou pour différentes politiques publiques (marchés publics, eco-modulation…)

L’affichage du coût environnemental d’un produit permet d’**informer le consommateur**. Depuis la loi Climat et
Résilience de 2021, des travaux sont engagés pour permettre cet affichage. Ils portent sur les vêtements, les
produits alimentaires ou encore l’ameublement. Pour plus d’informations, vous pouvez consulter\u{202F}:

- le [site de l’ADEME](https://affichage-environnemental.ademe.fr)
- le site du [ministère en charge de l’écologie](https://www.ecologie.gouv.fr/politiques-publiques/affichage-environnemental-vêtements)

Pour les vêtements, **un cadre règlementaire complet a été publié le 9 septembre 2025**. Il encadre l’affichage
volontaire du coût environnemental des vêtements. Une méthodologie de calcul règlementaire est ainsi arrêtée.
Vous pouvez y accéder en version [7.0.0 via le mode règlementaire](/versions/v7.0.0/#/textile/simulator)\u{202F}!

Pour afficher le coût environnemental sur vos produits textiles, il est nécessaire de [déclarer leur coût
sur le portail dédié](https://affichage-environnemental.ecobalyse.beta.gouv.fr/declarations)\u{202F}!
"""
            |> Markdown.simple [ class "illustrated-markdown" ]
        ]


viewEcs : Html Msg
viewEcs =
    viewSection "En savoir plus sur les données et les impacts\u{202F}?"
        [ """Vous pouvez en savoir plus sur nos données sources et nos modélisations en vous rendant dans [\u{202F}l’explorateur\u{202F}]({url_explorer}).
            Consultez également le détail des impacts environnementaux de vos simulations en [\u{202F}créant votre compte Ecobalyse\u{202F}]({url_account})."""
            |> String.replace "{url_explorer}" (Route.toString <| Route.Explore Scope.Textile (Dataset.TextileExamples Nothing))
            |> String.replace "{url_account}" (Route.toString Route.Auth)
            |> Markdown.simple []
        ]


viewTools : Html Msg
viewTools =
    viewSection "Les dessous du coût environnemental"
        [ """Le coût environnemental s’appuie sur la méthodologie d’analyse du cycle de vie PEF (Product Environmental Footprint)
        complétée sur les aspects qu’elle ne couvre pas encore. Il est issu du travail des pouvoirs publics (ADEME, Ministère de la transition écologique,\u{00A0}…)
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
    viewSection "Des questions sur nos outils ou la méthode\u{202F}?"
        [ """Ecobalyse est un outil ouvert et gratuit. Vos retours sur la méthode ou sur notre outil nous sont précieux."""
            |> Markdown.simple []
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
    viewSection "Accéder au coût environnemental à travers notre API"
        [ """[L’API HTTP Ecobalyse]({api_url}) permet de calculer les impacts environnementaux des différents produits.
             Elle est expérimentale et donc ne garantit pas de continuité de service à ce stade."""
            |> String.replace "{api_url}" (Route.toString <| Route.Api)
            |> Markdown.simple []
        , """Des questions\u{202F}? Consultez notre [\u{202F}FAQ API Ecobalyse\u{202F}]({api_faq_url})."""
            |> String.replace "{api_faq_url}" (Route.toString <| Route.Editorial "api-faq")
            |> Markdown.simple []
        ]


viewSection : String -> List (Html Msg) -> Html Msg
viewSection heading content =
    Container.centered []
        [ h3 [] [ text heading ]
            :: content
            |> div [ class "d-flex flex-column gap-2 p-0 px-md-5" ]
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
                [ viewEcs ]
            , div [ class "bg-light p-5" ]
                [ viewContribution ]
            , div [ class "p-5" ]
                [ viewApi ]
            ]
      ]
    )
