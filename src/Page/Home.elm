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
import Data.Impact as Impact
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
    = NoModal
    | CalculatorPickerModal


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
    Container.centered [ class "pb-5" ]
        [ h2 [ class "display-5" ]
            [ text "Entreprises"
            , br [] []
            , text "Calculez l'impact écologique de vos produits"
            ]
        , div [ class "fs-4 text-muted mt-4 mb-5" ]
            [ text "Écobalyse permet aux marques de comprendre et de calculer les impacts écologiques des produits distribués en France." ]
        , div [ class "row mb-4" ]
            [ div [ class "col-md-6 text-center text-md-end py-2" ]
                [ button
                    [ class "btn btn-lg btn-primary w-50"
                    , onClick OpenCalculatorPickerModal
                    ]
                    [ text "Lancer le calculateur" ]
                ]
            , div [ class "col-md-6 text-center text-md-start py-2" ]
                [ button
                    [ class "btn btn-lg btn-primary w-50"
                    , onClick <| ScrollIntoView "decouvrir-ecobalyse"
                    ]
                    [ text "Découvrir Écobalyse" ]
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
                    , title = ""
                    , formAction = Nothing
                    , content =
                        [ calculatorPickerModalContent ]
                    , footer = []
                    }
        ]


calculatorPickerModalContent : Html Msg
calculatorPickerModalContent =
    div []
        [ div [ class "row d-flex ps-5 pt-5 w-100 fs-5 fw-bold" ]
            [ text "→ Sélectionnez le secteur concerné" ]
        , div
            [ class "row d-flex text-center align-items-stretch justify-content-start ps-4 pt-2 pb-5 w-100 gap-1" ]
            [ div [ class "col-sm-3" ]
                [ a
                    [ class "card align-items-center text-decoration-none"
                    , Route.href (Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing)
                    ]
                    [ img
                        [ class "w-75 px-3 pt-3"
                        , src "img/picto_textile.png"
                        , alt "Lancer le calculateur du textile"
                        ]
                        []
                    , span [ class "card-body" ]
                        [ text "Textile" ]
                    ]
                ]
            , div [ class "col-sm-3" ]
                [ a
                    [ class "card align-items-center text-decoration-none"
                    , Route.href (Route.FoodBuilder Impact.defaultFoodTrigram Nothing)
                    ]
                    [ img
                        [ class "w-75 px-3 pt-3"
                        , src "img/picto_alimentaire.png"
                        , alt "Lancer le calculateur de l'alimentaire"
                        ]
                        []
                    , span [ class "card-body" ]
                        [ text "Alimentaire" ]
                    ]
                ]
            , div [ class "col-sm-3" ]
                [ div [ class "card h-100 justify-content-center" ]
                    [ text "Autre secteur,"
                    , br [] []
                    , Link.external
                        [ href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter" ]
                        [ text "contactez-nous" ]
                    ]
                ]
            ]
        ]


viewInfo : Html Msg
viewInfo =
    div
        [ class "container overlappedImage"
        , id "decouvrir-ecobalyse"
        ]
        [ img
            [ src "img/Illustration_Score.png"
            , alt "Illustration de score d'impact"
            ]
            []
        , div []
            [ h3 [] [ text "Un eco-score pour informer les consommateurs" ]
            , Html.cite [ class "d-inline-block fw-bold mx-5 mt-5" ] [ text "« 74%\u{00A0}des Français aimeraient avoir plus d’informations sur l’impact environnemental et sociétal des produits qu’ils achètent. »" ]
            , caption [ class "w-100 fs-7 text-muted mx-5 mb-5" ] [ text "14ème baromètre de la consommation responsable Greenflex et ADEME - 2021" ]
            , h3 [] [ text "Inscrit dans la loi Climat et Résilience de 2021" ]
            , p [] [ text "“Un affichage destiné à apporter au consommateur une information relative aux impacts environnementaux (...) d'un bien, d'un service ou d'une catégorie de biens ou de services mis sur le marché national est rendu obligatoire” — Article L.541-9-11 du code de l’environnement" ]
            , h3 [] [ text "Les secteurs Textile et Alimentaire, premiers concernés" ]
            , p [] [ text "Les méthodologies de calcul doivent être définies d’ici fin 2023 pour les produits alimentaires et textiles. Les travaux pour aider à définir une méthodologie de calcul réglementaire sont en cours." ]
            , p [] [ text "Nous publions les mises à jour et le calendrier pour les secteurs Textile et Alimentaire.\u{2028}D’autres secteurs suivront dans les années à venir." ]
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
