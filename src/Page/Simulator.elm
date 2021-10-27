module Page.Simulator exposing (..)

import Array
import Browser.Events
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Inputs as Inputs
import Data.Key as Key
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Session as Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook as GitbookApi
import Route exposing (Route(..))
import Views.Alert as Alert
import Views.Comparator as ComparatorView
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as MarkdownView
import Views.Modal as ModalView
import Views.RangeSlider as RangeSlider
import Views.Spinner as SpinnerView
import Views.Step as StepView
import Views.Summary as SummaryView


type alias Model =
    { simulator : Result String Simulator
    , massInput : String
    , query : Inputs.Query
    , displayMode : DisplayMode
    , modal : ModalContent
    }


type DisplayMode
    = DetailedMode
    | SimpleMode


type ModalContent
    = NoModal
    | GitbookModal (WebData Gitbook.Page)


type Msg
    = CloseModal
    | CopyToClipBoard String
    | ModalContentReceived (WebData Gitbook.Page)
    | NoOp
    | OpenDocModal Gitbook.Path
    | Reset
    | SwitchMode DisplayMode
    | UpdateAirTransportRatio (Maybe Float)
    | UpdateDyeingWeighting (Maybe Float)
    | UpdateMassInput String
    | UpdateMaterial Process.Uuid
    | UpdateRecycledRatio (Maybe Float)
    | UpdateStepCountry Int Country.Code
    | UpdateProduct Product.Id


init : Maybe Inputs.Query -> Session -> ( Model, Session, Cmd Msg )
init maybeQuery session =
    let
        query =
            Maybe.withDefault Inputs.defaultQuery maybeQuery

        simulator =
            Simulator.compute session.db query
    in
    ( { simulator = simulator
      , massInput = query.mass |> Mass.inKilograms |> String.fromFloat
      , query = query
      , displayMode = SimpleMode
      , modal = NoModal
      }
    , case simulator of
        Err error ->
            session |> Session.notifyError "Erreur de récupération des paramètres d'entrée" error

        Ok _ ->
            session
    , Cmd.none
    )


updateQuery : Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model | query = query, simulator = Simulator.compute session.db query }
    , session
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ db } as session) msg ({ query } as model) =
    case msg of
        CloseModal ->
            ( { model | modal = NoModal }, session, Cmd.none )

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        ModalContentReceived gitbookData ->
            ( { model | modal = GitbookModal gitbookData }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenDocModal path ->
            ( { model | modal = GitbookModal RemoteData.Loading }
            , session
            , GitbookApi.getPage session path ModalContentReceived
            )

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        SwitchMode displayMode ->
            ( { model | displayMode = displayMode }, session, Cmd.none )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateDyeingWeighting dyeingWeighting ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingWeighting = dyeingWeighting }

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( { model | massInput = massInput }, session, Cmd.none )
                        |> updateQuery { query | mass = mass }

                Nothing ->
                    ( { model | massInput = massInput }, session, Cmd.none )

        UpdateMaterial materialId ->
            case Material.findByUuid materialId db.materials of
                Ok material ->
                    ( model, session, Cmd.none )
                        |> updateQuery (Inputs.updateMaterial material query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de matière première" error, Cmd.none )

        UpdateRecycledRatio recycledRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | recycledRatio = recycledRatio }

        UpdateStepCountry index code ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateStepCountry index code query)

        UpdateProduct productId ->
            case Product.findById productId db.products of
                Ok product ->
                    ( { model | massInput = product.mass |> Mass.inKilograms |> String.fromFloat }, session, Cmd.none )
                        |> updateQuery { query | product = product.id, mass = product.mass }

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de produit" error, Cmd.none )


massField : String -> Html Msg
massField massInput =
    div []
        [ label [ for "mass", class "form-label fw-bold" ] [ text "Masse du produit fini" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.05"
                , step "0.05"
                , value massInput
                , onInput UpdateMassInput
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


materialFormSet : Db -> Maybe Float -> Material -> Html Msg
materialFormSet db recycledRatio material =
    let
        ( ( natural1, synthetic1, recycled1 ), ( natural2, synthetic2, recycled2 ) ) =
            Material.groupAll db.materials

        toOption m =
            option
                [ value <| Process.uuidToString m.uuid
                , selected (material.uuid == m.uuid)
                , title m.name
                ]
                [ text m.shortName ]

        toGroup name materials =
            if materials == [] then
                text ""

            else
                materials
                    |> List.map toOption
                    |> optgroup [ attribute "label" name ]
    in
    div [ class "row mb-2" ]
        [ div [ class "col-md-6" ]
            [ div [ class "form-label fw-bold" ]
                [ text "Matières premières" ]
            , [ toGroup "Matières naturelles" natural1
              , toGroup "Matières synthétiques" synthetic1
              , toGroup "Matières recyclées" recycled1
              , toGroup "Autres matières naturelles" natural2
              , toGroup "Autres matières synthétiques" synthetic2
              , toGroup "Autres matières recyclées" recycled2
              ]
                |> select
                    [ id "material"
                    , class "form-select"
                    , onInput (Process.Uuid >> UpdateMaterial)
                    ]
            ]
        , div [ class "col-md-6" ]
            [ div [ class "form-label fw-bold mb-0 mb-xl-3" ]
                [ text "Part de matière recyclée" ]
            , RangeSlider.view
                { id = "recycledRatio"
                , update = UpdateRecycledRatio
                , value = Maybe.withDefault 0 recycledRatio
                , toString = Material.recycledRatioToString
                , disabled = material.recycledUuid == Nothing
                }
            ]
        ]


productField : Db -> Product -> Html Msg
productField db product =
    div []
        [ label [ for "product", class "form-label fw-bold" ] [ text "Type de produit" ]
        , db.products
            |> List.map
                (\p ->
                    option
                        [ value (Product.idToString p.id)
                        , selected (product.id == p.id)
                        ]
                        [ text p.name ]
                )
            |> select
                [ id "product"
                , class "form-select"
                , onInput (Product.Id >> UpdateProduct)
                ]
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


lifeCycleStepsView : Db -> DisplayMode -> Simulator -> Html Msg
lifeCycleStepsView db displayMode simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , detailed = displayMode == DetailedMode
                    , index = index
                    , product = simulator.inputs.product
                    , current = current
                    , next = Array.get (index + 1) simulator.lifeCycle
                    , openDocModal = OpenDocModal
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingWeighting = UpdateDyeingWeighting
                    }
            )
        |> Array.toList
        |> List.intersperse (div [ class "text-center" ] [ downArrow ])
        |> div [ class "pt-1" ]


shareLinkView : Session -> Simulator -> Html Msg
shareLinkView session simulator =
    let
        shareableLink =
            simulator.inputs
                |> (Inputs.toQuery >> Just)
                |> Route.Simulator
                |> Route.toString
                |> (++) session.clientUrl
    in
    div [ class "card shadow-sm" ]
        [ div [ class "card-header" ] [ text "Partager cette simulation" ]
        , div [ class "card-body" ]
            [ div
                [ class "input-group" ]
                [ input
                    [ type_ "url"
                    , class "form-control"
                    , value shareableLink
                    ]
                    []
                , button
                    [ class "input-group-text"
                    , title "Copier l'adresse"
                    , onClick (CopyToClipBoard shareableLink)
                    ]
                    [ Icon.clipboard
                    ]
                ]
            , div [ class "form-text fs-7" ]
                [ text "Copiez cette adresse pour partager votre simulation" ]
            ]
        ]


displayModeView : DisplayMode -> Html Msg
displayModeView displayMode =
    ul [ class "nav nav-pills nav-fill py-2 bg-white sticky-md-top" ]
        [ li [ class "nav-item" ]
            [ button
                [ classList [ ( "nav-link", True ), ( "active", displayMode == SimpleMode ) ]
                , onClick (SwitchMode SimpleMode)
                ]
                [ span [ class "me-2" ] [ Icon.zoomout ], text "Affichage simple" ]
            ]
        , li [ class "nav-item" ]
            [ button
                [ classList [ ( "nav-link", True ), ( "active", displayMode == DetailedMode ) ]
                , onClick (SwitchMode DetailedMode)
                ]
                [ span [ class "me-2" ] [ Icon.zoomin ], text "Affichage détaillé" ]
            ]
        ]


feedbackView : Html msg
feedbackView =
    -- Note: only visible on smallest viewports
    Link.external
        [ class "d-block d-sm-none btn btn-outline-primary"
        , href "https://hhvat39ihea.typeform.com/to/HnNn6rIY"
        ]
        [ span [ class "me-2" ] [ Icon.dialog ]
        , text "Aidez-nous à améliorer ce simulateur"
        ]


modalView : ModalContent -> Html Msg
modalView modal =
    case modal of
        NoModal ->
            text ""

        GitbookModal RemoteData.NotAsked ->
            text ""

        GitbookModal RemoteData.Loading ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = "Chargement…"
                , content = [ SpinnerView.view ]
                , footer = []
                }

        GitbookModal (RemoteData.Failure error) ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = "Erreur"
                , content = [ Alert.httpError error ]
                , footer = []
                }

        GitbookModal (RemoteData.Success gitbookPage) ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = gitbookPage.title
                , content =
                    [ case gitbookPage.description of
                        Just description ->
                            p [ class "fw-bold text-muted fst-italic" ] [ text description ]

                        Nothing ->
                            text ""
                    , if String.trim gitbookPage.markdown == "" then
                        Alert.preformatted
                            { title = "Une erreur a été rencontrée"
                            , close = Nothing
                            , level = Alert.Info
                            , content =
                                [ div [ class "mb-0 d-flex align-items-center" ]
                                    [ span [ class "fs-4 me-2" ] [ Icon.hammer ]
                                    , text "Cette page est en cours de construction"
                                    ]
                                ]
                            }

                      else
                        MarkdownView.gitbook [ class "GitbookContent" ] gitbookPage
                    ]
                , footer =
                    [ div [ class "text-end" ]
                        [ Link.external [ href <| Gitbook.publicUrlFromPath gitbookPage.path ]
                            [ text "Ouvrir cette page sur le site de documentation Wikicarbone"
                            ]
                        ]
                    ]
                }


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView ({ db } as session) model ({ inputs } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-7" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 mb-2" ]
                    [ productField db simulator.inputs.product
                    ]
                , div [ class "col-md-6 mb-2" ]
                    [ massField model.massInput
                    ]
                ]
            , materialFormSet db inputs.recycledRatio inputs.material
            , displayModeView model.displayMode
            , lifeCycleStepsView db model.displayMode simulator
            , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
                [ a [ Route.href Route.Home ]
                    [ text "« Retour à l'accueil" ]
                , button
                    [ class "btn btn-secondary"
                    , onClick Reset
                    , disabled (model.query == Inputs.defaultQuery)
                    ]
                    [ text "Réinitialiser le simulateur" ]
                ]
            ]
        , div [ class "col-lg-5" ]
            [ div [ class "d-flex flex-column gap-3 mb-3 sticky-md-top", style "top" "7px" ]
                [ div [ class "Summary" ]
                    [ SummaryView.view False model.simulator ]
                , ComparatorView.view
                    { session = session
                    , simulator = simulator
                    , openDocModal = OpenDocModal
                    }
                , feedbackView
                , shareLinkView session simulator
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator" ]
            [ h1 [ class "mb-3" ] [ text "Simulateur" ]
            , case model.simulator of
                Ok simulator ->
                    simulatorView session model simulator

                Err error ->
                    Alert.simple
                        { level = Alert.Danger
                        , close = Nothing
                        , title = "Erreur"
                        , content = [ text error ]
                        }
            ]
      , modalView model.modal
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        GitbookModal _ ->
            Browser.Events.onKeyDown (Key.escape CloseModal)

        NoModal ->
            Sub.none
