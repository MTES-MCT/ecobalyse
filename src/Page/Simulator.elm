module Page.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Browser.Events
import Browser.Navigation as Navigation
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Key as Key
import Data.Material as Material
import Data.Product as Product exposing (Product)
import Data.Session as Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook as GitbookApi
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Link as Link
import Views.Markdown as MarkdownView
import Views.Material as MaterialView
import Views.Modal as ModalView
import Views.Spinner as SpinnerView
import Views.Step as StepView
import Views.Summary as SummaryView


type alias Model =
    { simulator : Result String Simulator
    , massInput : String
    , initialQuery : Inputs.Query
    , query : Inputs.Query
    , detailed : Bool
    , modal : ModalContent
    , impact : Impact.Definition
    , funit : Unit.Functional
    }


type ModalContent
    = NoModal
    | GitbookModal (WebData Gitbook.Page)


type Msg
    = AddMaterial
    | CloseModal
    | CopyToClipBoard String
    | GitbookContentReceived (WebData Gitbook.Page)
    | NoOp
    | OpenDocModal Gitbook.Path
    | RemoveMaterial Int
    | Reset
    | SelectInputText String
    | SwitchFunctionalUnit Unit.Functional
    | SwitchImpact Impact.Trigram
    | UpdateAirTransportRatio (Maybe Unit.Ratio)
    | UpdateDyeingWeighting (Maybe Unit.Ratio)
    | UpdateMassInput String
    | UpdateMaterial Int Material.Id
    | UpdateMaterialRecycledRatio Int Unit.Ratio
    | UpdateMaterialShare Int Unit.Ratio
    | UpdateProduct Product.Id
    | UpdateQuality (Maybe Unit.Quality)
    | UpdateStepCountry Int Country.Code


init :
    Impact.Trigram
    -> Unit.Functional
    -> { detailed : Bool }
    -> Maybe Inputs.Query
    -> Session
    -> ( Model, Session, Cmd Msg )
init trigram funit { detailed } maybeQuery ({ db } as session) =
    let
        query =
            maybeQuery
                |> Maybe.withDefault Inputs.defaultQuery

        simulator =
            Simulator.compute db query
    in
    ( { simulator = simulator
      , massInput = query.mass |> Mass.inKilograms |> String.fromFloat
      , initialQuery = query
      , query = query
      , detailed = detailed
      , modal = NoModal
      , impact = db.impacts |> Impact.getDefinition trigram |> Result.withDefault Impact.default
      , funit = funit
      }
    , case simulator of
        Err error ->
            session |> Session.notifyError "Erreur de récupération des paramètres d'entrée" error

        Ok _ ->
            session
    , case maybeQuery of
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }

        Just _ ->
            Cmd.none
    )


updateQuery : Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model
        | query = query
        , simulator = Simulator.compute session.db query
      }
    , session
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ db, navKey } as session) msg ({ query } as model) =
    case msg of
        AddMaterial ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.addMaterial db query)

        CloseModal ->
            ( { model | modal = NoModal }, session, Cmd.none )

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        GitbookContentReceived gitbookData ->
            ( { model | modal = GitbookModal gitbookData }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenDocModal path ->
            ( { model | modal = GitbookModal RemoteData.Loading }
            , session
            , GitbookApi.getPage session path GitbookContentReceived
            )

        RemoveMaterial index ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.removeMaterial index query)

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        SelectInputText index ->
            ( model, session, Ports.selectInputText index )

        SwitchFunctionalUnit funit ->
            ( model
            , session
            , Route.Simulator model.impact.trigram funit { detailed = model.detailed } (Just query)
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact trigram ->
            ( model
            , session
            , Route.Simulator trigram model.funit { detailed = model.detailed } (Just query)
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

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

        UpdateMaterial index materialId ->
            case Material.findById materialId db.materials of
                Ok material ->
                    ( model, session, Cmd.none )
                        |> updateQuery (Inputs.updateMaterial index material query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de matière première" error, Cmd.none )

        UpdateMaterialRecycledRatio index recycledRatio ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialRecycledRatio index recycledRatio query)

        UpdateMaterialShare index share ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialShare index share query)

        UpdateProduct productId ->
            case Product.findById productId db.products of
                Ok product ->
                    ( { model | massInput = product.mass |> Mass.inKilograms |> String.fromFloat }, session, Cmd.none )
                        |> updateQuery (Inputs.updateProduct product query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de produit" error, Cmd.none )

        UpdateQuality quality ->
            ( model, session, Cmd.none )
                |> updateQuery { query | quality = quality }

        UpdateStepCountry index code ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateStepCountry index code query)


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


productField : Db -> Product -> Html Msg
productField db product =
    div []
        [ label [ for "product", class "form-label fw-bold" ]
            [ text "Type de produit" ]
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


lifeCycleStepsView : Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { detailed, funit, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , inputs = simulator.inputs
                    , detailed = detailed
                    , impact = impact
                    , funit = funit
                    , daysOfWear = simulator.daysOfWear
                    , index = index
                    , current = current
                    , next = Array.get (index + 1) simulator.lifeCycle
                    , openDocModal = OpenDocModal
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingWeighting = UpdateDyeingWeighting
                    , updateQuality = UpdateQuality
                    }
            )
        |> Array.toList
        |> List.intersperse (div [ class "text-center" ] [ downArrow ])
        |> div [ class "pt-1" ]


shareLinkView : Session -> Model -> Simulator -> Html Msg
shareLinkView session { impact, funit, detailed } simulator =
    let
        shareableLink =
            simulator.inputs
                |> (Inputs.toQuery >> Just)
                |> Route.Simulator impact.trigram funit { detailed = detailed }
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
                [ text "Copiez cette adresse pour partager ou sauvegarder votre simulation" ]
            ]
        ]


displayModeView : Impact.Trigram -> Unit.Functional -> Bool -> Inputs.Query -> Html Msg
displayModeView trigram funit detailed query =
    nav
        [ class "nav nav-pills nav-fill py-2 bg-white sticky-md-top justify-content-between"
        , class "justify-content-sm-end align-items-center gap-0 gap-sm-2"
        ]
        [ a
            [ classList [ ( "nav-link", True ), ( "active", not detailed ) ]
            , Just query
                |> Route.Simulator trigram funit { detailed = False }
                |> Route.href
            ]
            [ span [ class "me-1" ] [ Icon.zoomout ], text "Affichage simple" ]
        , a
            [ classList [ ( "nav-link", True ), ( "active", detailed ) ]
            , Just query
                |> Route.Simulator trigram funit { detailed = True }
                |> Route.href
            ]
            [ span [ class "me-1" ] [ Icon.zoomin ], text "Affichage détaillé" ]
        ]


gitbookModalView : WebData Gitbook.Page -> Html Msg
gitbookModalView pageData =
    case pageData of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = "Chargement…"
                , formAction = Nothing
                , content = [ SpinnerView.view ]
                , footer = []
                }

        RemoteData.Failure error ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = "Erreur"
                , formAction = Nothing
                , content = [ Alert.httpError error ]
                , footer = []
                }

        RemoteData.Success gitbookPage ->
            ModalView.view
                { size = ModalView.Large
                , close = CloseModal
                , noOp = NoOp
                , title = gitbookPage.title
                , formAction = Nothing
                , content =
                    [ case gitbookPage.description of
                        Just description ->
                            p [ class "fw-bold text-muted fst-italic" ] [ text description ]

                        Nothing ->
                            text ""
                    , if String.trim gitbookPage.markdown == "" then
                        Alert.preformatted
                            { title = Just "Une erreur a été rencontrée"
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


modalView : Model -> Html Msg
modalView model =
    case model.modal of
        NoModal ->
            text ""

        GitbookModal pageData ->
            gitbookModalView pageData


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView ({ db } as session) ({ impact, funit, query, detailed } as model) ({ inputs } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-7" ]
            [ h1 [] [ text "Simulateur " ]
            , ImpactView.viewDefinition model.impact
            , div [ class "row" ]
                [ div [ class "col-6 col-md-7 mb-2" ]
                    [ productField db inputs.product
                    ]
                , div [ class "col-6 col-md-5 mb-2" ]
                    [ massField model.massInput
                    ]
                ]
            , MaterialView.formSet
                { materials = db.materials
                , inputs = inputs.materials
                , add = AddMaterial
                , remove = RemoveMaterial
                , update = UpdateMaterial
                , updateRecycledRatio = UpdateMaterialRecycledRatio
                , updateShare = UpdateMaterialShare
                , selectInputText = SelectInputText
                }
            , query
                |> displayModeView impact.trigram funit detailed
            , lifeCycleStepsView db model simulator
            , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
                [ a [ Route.href Route.Home ]
                    [ text "« Retour à l'accueil" ]
                , button
                    [ class "btn btn-secondary"
                    , onClick Reset
                    , disabled (model.query == model.initialQuery)
                    ]
                    [ text "Réinitialiser le simulateur" ]
                ]
            ]
        , div [ class "col-lg-5 bg-white" ]
            [ div [ class "d-flex flex-column gap-3 mb-3 sticky-md-top", style "top" "7px" ]
                [ ImpactView.selector
                    { impacts = session.db.impacts
                    , selectedImpact = model.impact.trigram
                    , switchImpact = SwitchImpact
                    , selectedFunctionalUnit = model.funit
                    , switchFunctionalUnit = SwitchFunctionalUnit
                    }
                , div [ class "Summary" ]
                    [ model.simulator
                        |> SummaryView.view
                            { session = session
                            , impact = model.impact
                            , funit = model.funit
                            , reusable = False
                            }
                    ]
                , shareLinkView session model simulator
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            [ case model.simulator of
                Ok simulator ->
                    simulatorView session model simulator

                Err error ->
                    Alert.simple
                        { level = Alert.Danger
                        , close = Nothing
                        , title = Just "Erreur"
                        , content = [ text error ]
                        }
            ]
      , modalView model
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        _ ->
            Browser.Events.onKeyDown (Key.escape CloseModal)
