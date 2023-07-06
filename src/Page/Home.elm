module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Data.Env as Env
import Data.Impact.Definition as Definition
import Data.Key as Key
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import Route
import Views.Container as Container
import Views.Link as Link
import Views.Modal as ModalView


type alias Model =
    { modal : Modal
    }


type Msg
    = CloseModal
    | NoOp
    | OpenCalculatorPickerModal
    | ScrollIntoView String


type Modal
    = CalculatorPickerModal
    | NoModal


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { modal = NoModal }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        CloseModal ->
            ( { model | modal = NoModal }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenCalculatorPickerModal ->
            ( { model | modal = CalculatorPickerModal }, session, Cmd.none )

        ScrollIntoView nodeId ->
            ( model, session, Ports.scrollIntoView nodeId )


viewHero : Modal -> Html Msg
viewHero modal =
    Container.centered [ class "pt-4 pb-5" ]
        [ div [ class "px-5" ]
            [ h2 [ class "h1" ]
                [ text "Calculez l'impact écologique de vos produits" ]
            , div [ class "fs-5 mt-3 mb-5" ]
                [ text "Ecobalyse permet de comprendre et de calculer les impacts écologiques des produits distribués en France." ]
            , div [ class "d-flex flex-column flex-sm-row gap-3 mb-4" ]
                [ button
                    [ class "btn btn-lg btn-primary"
                    , onClick OpenCalculatorPickerModal
                    ]
                    [ text "Lancer le calculateur" ]
                , button
                    [ class "btn btn-lg btn-outline-primary"
                    , onClick <| ScrollIntoView "decouvrir-ecobalyse"
                    ]
                    [ text "Découvrir Écobalyse ↓" ]
                ]
            ]
        , case modal of
            NoModal ->
                text ""

            CalculatorPickerModal ->
                ModalView.view
                    { size = ModalView.Large
                    , close = CloseModal
                    , noOp = NoOp
                    , title = "Sélectionnez le secteur concerné"
                    , formAction = Nothing
                    , content = [ calculatorPickerModalContent ]
                    , footer = []
                    }
        ]


calculatorPickerModalContent : Html Msg
calculatorPickerModalContent =
    div [ class "p-4" ]
        [ div [ class "Launcher d-flex flex-wrap justify-content-center justify-content-sm-start gap-3" ]
            [ a
                [ class "LauncherLink text-dark fw-bold d-flex flex-column justify-content-center align-items-center text-decoration-none"
                , Route.href (Route.TextileSimulator Definition.Ecs Unit.PerItem ViewMode.Simple Nothing)
                ]
                [ img
                    [ src "img/picto_textile.png"
                    , alt "Lancer le calculateur du textile"
                    ]
                    []
                , div [] [ text "Textile" ]
                ]
            , a
                [ class "LauncherLink text-dark fw-bold d-flex flex-column justify-content-center align-items-center text-decoration-none"
                , Route.href (Route.FoodBuilder Definition.Ecs Nothing)
                ]
                [ img
                    [ src "img/picto_alimentaire.png"
                    , alt "Lancer le calculateur de l'alimentaire"
                    ]
                    []
                , div [] [ text "Alimentaire" ]
                ]
            , div [ class "LauncherLink d-flex flex-column justify-content-center align-items-center" ]
                [ text "Autre secteur,"
                , br [] []
                , Link.external
                    [ href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter" ]
                    [ text "contactez-nous" ]
                ]
            ]
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
            [ h2 [] [ text "Un eco-score pour informer les consommateurs" ]
            , blockquote [ class "d-inline-block fw-bold mx-5 mt-3 mb-2" ]
                [ p [ class "mb-0" ]
                    [ text "«\u{00A0}74%\u{00A0}des Français aimeraient avoir plus d’informations sur l’impact environnemental et sociétal des produits qu’ils achètent.\u{00A0}»" ]
                , Html.cite [ class "fw-normal fs-7 text-muted mb-5" ]
                    [ text "14ème baromètre de la consommation responsable Greenflex et ADEME - 2021" ]
                ]
            , h3 [ class "my-3" ] [ text "Inscrit dans la loi Climat et Résilience de 2021" ]
            , p [] [ text "“Un affichage destiné à apporter au consommateur une information relative aux impacts environnementaux (...) d'un bien, d'un service ou d'une catégorie de biens ou de services mis sur le marché national est rendu obligatoire” — Article L.541-9-11 du code de l’environnement" ]
            , h3 [ class "my-3" ] [ text "Les secteurs Textile et Alimentaire, premiers concernés" ]
            , p [] [ text "Les méthodologies de calcul doivent être définies d’ici fin 2023 pour les produits alimentaires et textiles. Les travaux pour aider à définir une méthodologie de calcul réglementaire sont en cours." ]
            , p [] [ text "Nous publions les mises à jour et le calendrier pour les secteurs Textile et Alimentaire. D’autres secteurs suivront dans les années à venir." ]
            ]
        ]


viewTools : Html Msg
viewTools =
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
                    , onClick <| OpenCalculatorPickerModal
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
                        [ h3 [ class "h5 fw-bold" ] [ text "Calculateur d’impacts écologiques" ]
                        , text "Un calculateur gratuit qui permet d’obtenir les impacts d’un produit sur la base de critères simples et accessibles aux marques."
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
                , p [] [ q [] [ text "Tiens, ce chiffre me parait étonnant…" ] ]
                , p [] [ q [] [ text "Et si on utilisait la surface du tissu plutôt que la masse du vêtement\u{00A0}?" ] ]
                , p [] [ q [] [ text "Pourquoi l’impact diminue lorsque la production se fait au Myanmar\u{00A0}?" ] ]
                ]
            , div [ class "col-sm-8 bg-light mt-5 mb-5 p-5" ]
                [ h3 [ class "h5 fw-bold" ] [ text "Contribuez à améliorer le calcul d’impacts écologiques" ]
                , p [] [ text "La définition de la méthode de calcul et la mise en œuvre de l’éco-score nécessitent un travail collectif au long cours en relation avec les acteurs de chaque filière." ]
                , p [] [ text "Vous êtes une marque, un producteur, un bureau d’étude ou un distributeur\u{00A0}:" ]
                , ul [ class "mb-5" ]
                    [ li [] [ text "Partagez les données d’impact de votre production," ]
                    , li [] [ text "Suggérez une amélioration de la méthodologie ou du calculateur," ]
                    , li [] [ text "Proposez votre participation aux travaux collectifs. " ]
                    ]
                , Link.external
                    [ class "btn btn-primary"
                    , href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter"
                    ]
                    [ text "Contactez l’équipe Écobalyse" ]
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ { modal } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ div [ class "bg-light pt-5" ]
                [ viewHero modal ]
            , div [ class "pt-5" ]
                [ viewInfo ]
            , div [ class "bg-light pt-5" ]
                [ viewTools ]
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

        _ ->
            Browser.Events.onKeyDown (Key.escape CloseModal)
