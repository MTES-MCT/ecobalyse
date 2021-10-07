module Page.Simulator exposing (..)

import Array
import Browser.Events
import Data.Country exposing (Country)
import Data.Gitbook as Gitbook
import Data.Inputs as Inputs exposing (Inputs)
import Data.Key as Key
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Ports
import RemoteData exposing (WebData)
import Request.Common as HttpCommon
import Request.Gitbook as GitbookApi
import Route exposing (Route(..))
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as MarkdownView
import Views.Modal as ModalView
import Views.Spinner as SpinnerView
import Views.Step as StepView
import Views.Summary as SummaryView


type alias Model =
    { simulator : Simulator
    , massInput : String
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
    | OpenDocModal String
    | Reset
    | SwitchMode DisplayMode
    | UpdateAirTransportRatio (Maybe Float)
    | UpdateDyeingWeighting (Maybe Float)
    | UpdateMassInput String
    | UpdateMaterial Material
    | UpdateMaterialCategory Category
    | UpdateStepCountry Int Country
    | UpdateProduct Product


init : Maybe Inputs.Query -> Session -> ( Model, Session, Cmd Msg )
init maybeInputs ({ store } as session) =
    let
        simulator =
            -- TODO: is using store.simulator necessary? why should it be serialized in a first step?
            maybeInputs
                |> Maybe.map Inputs.fromQuery
                |> Maybe.withDefault store.inputs
                |> Simulator.compute
    in
    ( { simulator = simulator
      , massInput = simulator.inputs.mass |> Mass.inKilograms |> String.fromFloat
      , displayMode = SimpleMode
      , modal = NoModal
      }
    , session
    , Cmd.none
    )


updateInputs : Inputs -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateInputs inputs ( model, session, msg ) =
    ( { model | simulator = Simulator.compute inputs }
    , session
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ simulator } as model) =
    let
        { inputs } =
            simulator
    in
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
                |> updateInputs Inputs.default

        SwitchMode displayMode ->
            ( { model | displayMode = displayMode }, session, Cmd.none )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateInputs { inputs | airTransportRatio = airTransportRatio }

        UpdateDyeingWeighting dyeingWeighting ->
            ( model, session, Cmd.none )
                |> updateInputs { inputs | dyeingWeighting = dyeingWeighting }

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( { model | massInput = massInput }, session, Cmd.none )
                        |> updateInputs { inputs | mass = mass }

                Nothing ->
                    ( { model | massInput = massInput }, session, Cmd.none )

        UpdateMaterial material ->
            ( model, session, Cmd.none )
                |> updateInputs { inputs | material = material }

        UpdateMaterialCategory category ->
            ( model, session, Cmd.none )
                |> updateInputs
                    { inputs
                        | material =
                            Material.choices
                                |> List.filter (.category >> (==) category)
                                |> List.head
                                |> Maybe.withDefault Material.cotton
                    }

        UpdateStepCountry index country ->
            ( model, session, Cmd.none )
                |> updateInputs (Inputs.updateStepCountry index country inputs)

        UpdateProduct product ->
            ( { model | massInput = product.mass |> Mass.inKilograms |> String.fromFloat }, session, Cmd.none )
                |> updateInputs { inputs | product = product, mass = product.mass }


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


materialCategoryField : Material -> Html Msg
materialCategoryField material =
    div [ class "mb-2" ]
        [ div [ class "form-label fw-bold" ] [ text "Matières premières" ]
        , [ ( Category.Natural, "leaf" )
          , ( Category.Synthetic, "lab" )
          , ( Category.Recycled, "recycle" )
          ]
            |> List.map
                (\( m, icon ) ->
                    button
                        [ type_ "button"
                        , classList
                            [ ( "btn", True )
                            , ( "btn-outline-primary", material.category /= m )
                            , ( "btn-primary", material.category == m )
                            , ( "text-truncate", True )
                            ]
                        , onClick (UpdateMaterialCategory m)
                        ]
                        [ span [ class "me-1" ] [ Icon.icon icon ]
                        , m |> Category.toString |> text
                        ]
                )
            |> div [ class "btn-group w-100" ]
        ]


materialField : Material -> Html Msg
materialField material =
    Material.choices
        |> List.filter (.category >> (==) material.category)
        |> List.map
            (\m ->
                option
                    [ value <| Process.uuidToString m.materialProcessUuid
                    , selected (material.materialProcessUuid == m.materialProcessUuid)
                    , title m.name
                    ]
                    [ text m.name ]
            )
        |> select
            [ id "material"
            , class "form-select"
            , onInput (Process.Uuid >> Material.findByProcessUuid >> UpdateMaterial)
            ]


productField : Product -> Html Msg
productField product =
    div []
        [ label [ for "product", class "form-label fw-bold" ] [ text "Type de produit" ]
        , Product.choices
            |> List.map (\p -> option [ value (Product.idToString p.id), selected (product.id == p.id) ] [ text p.name ])
            |> select
                [ id "product"
                , class "form-select"
                , onInput (Product.Id >> Product.findById >> UpdateProduct)
                ]
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


lifeCycleStepsView : Model -> Html Msg
lifeCycleStepsView { displayMode, simulator } =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { detailed = displayMode == DetailedMode
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


shareLinkView : Session -> Model -> Html Msg
shareLinkView session { simulator } =
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
                , content =
                    [ div [ class "alert alert-danger mb-0" ]
                        [ p [] [ text "Une erreur a été rencontrée" ]
                        , p [] [ text <| HttpCommon.errorToString error ]
                        ]
                    ]
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
                        div [ class "alert alert-info mb-0 d-flex align-items-center" ]
                            [ span [ class "fs-4 me-2" ] [ Icon.hammer ]
                            , text "Cette page est en cours de construction"
                            ]

                      else
                        gitbookPage.markdown
                            |> Gitbook.cleanMarkdown
                            |> MarkdownView.view [ class "GitbookContent" ]
                    ]
                , footer =
                    [ div [ class "text-end" ]
                        [ Link.external [ href <| Gitbook.publicUrl gitbookPage.path ]
                            [ text "Ouvrir cette page sur le site de documentation Wikicarbone"
                            ]
                        ]
                    ]
                }


view : Session -> Model -> ( String, List (Html Msg) )
view session ({ displayMode, simulator } as model) =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator" ]
            [ h1 [ class "mb-3" ] [ text "Simulateur" ]
            , div [ class "row" ]
                [ div [ class "col-lg-7" ]
                    [ div [ class "row" ]
                        [ div [ class "col-md-6 mb-2" ]
                            [ productField simulator.inputs.product
                            ]
                        , div [ class "col-md-6 mb-2" ]
                            [ massField model.massInput
                            ]
                        ]
                    , materialCategoryField simulator.inputs.material
                    , div [ class "mb-1" ] [ materialField simulator.inputs.material ]
                    , displayModeView displayMode
                    , lifeCycleStepsView model
                    , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
                        [ a [ Route.href Route.Home ] [ text "« Retour à l'accueil" ]
                        , button
                            [ class "btn btn-secondary"
                            , onClick Reset
                            , disabled (Simulator.default == simulator)
                            ]
                            [ text "Réinitialiser le simulateur" ]
                        ]
                    ]
                , div [ class "col-lg-5" ]
                    [ div [ class "d-flex flex-column gap-3 mb-3 sticky-md-top" ]
                        [ div [ class "Summary" ] [ SummaryView.view False simulator ]
                        , feedbackView
                        , shareLinkView session model
                        ]
                    ]
                ]
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
