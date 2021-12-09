module Page.Simulator exposing (..)

import Array
import Browser.Dom as Dom
import Browser.Events
import Data.Co2 as Co2 exposing (Co2e)
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
import Data.Step as Step exposing (Step)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook as GitbookApi
import Route exposing (Route(..))
import Task
import Views.Alert as Alert
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
    , customCountryMixInputs : CustomCountryMixInputs
    }


type DisplayMode
    = DetailedMode
    | SimpleMode


type ModalContent
    = NoModal
    | CustomCountryMixModal Step
    | GitbookModal (WebData Gitbook.Page)


type Msg
    = CloseModal
    | CopyToClipBoard String
    | GitbookContentReceived (WebData Gitbook.Page)
    | NoOp
    | OpenCustomCountryMixModal Step
    | OpenDocModal Gitbook.Path
    | Reset
    | ResetCustomCountryMix Step.Label
    | SubmitCustomCountryMix Step.Label (Maybe Co2e)
    | SwitchMode DisplayMode
    | UpdateAirTransportRatio (Maybe Float)
    | UpdateCustomCountryMixInput Step.Label String
    | UpdateDyeingWeighting (Maybe Float)
    | UpdateMassInput String
    | UpdateMaterial Process.Uuid
    | UpdateRecycledRatio (Maybe Float)
    | UpdateStepCountry Int Country.Code
    | UpdateProduct Product.Id


type alias CustomCountryMixInputs =
    -- represents the current state of user raw form inputs for custom country mix values
    { fabric : Maybe String
    , dyeing : Maybe String
    , making : Maybe String
    }


getCustomCountryMixInput : Step.Label -> CustomCountryMixInputs -> Maybe String
getCustomCountryMixInput stepLabel values =
    case stepLabel of
        Step.WeavingKnitting ->
            values.fabric

        Step.Ennoblement ->
            values.dyeing

        Step.Making ->
            values.making

        _ ->
            Nothing


updateCustomCountryMixInputs : Step.Label -> Maybe String -> CustomCountryMixInputs -> CustomCountryMixInputs
updateCustomCountryMixInputs stepLabel maybeValue values =
    case stepLabel of
        Step.WeavingKnitting ->
            { values | fabric = maybeValue }

        Step.Ennoblement ->
            { values | dyeing = maybeValue }

        Step.Making ->
            { values | making = maybeValue }

        _ ->
            values


validateCustomCountryMixInput : Step.Label -> CustomCountryMixInputs -> Maybe Co2e
validateCustomCountryMixInput stepLabel =
    getCustomCountryMixInput stepLabel
        >> Maybe.andThen String.toFloat
        >> Maybe.map Co2.kgCo2e


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
      , customCountryMixInputs = toCustomCountryMixFormInputs query.customCountryMixes
      }
    , case simulator of
        Err error ->
            session |> Session.notifyError "Erreur de récupération des paramètres d'entrée" error

        Ok _ ->
            session
    , Cmd.none
    )


toCustomCountryMixFormInputs : Inputs.CustomCountryMixes -> CustomCountryMixInputs
toCustomCountryMixFormInputs { fabric, dyeing, making } =
    let
        mapToCo2e =
            Maybe.map (Co2.inKgCo2e >> String.fromFloat)
    in
    { fabric = mapToCo2e fabric
    , dyeing = mapToCo2e dyeing
    , making = mapToCo2e making
    }


updateQuery : Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    ( { model
        | query = query
        , simulator = Simulator.compute session.db query
        , customCountryMixInputs = toCustomCountryMixFormInputs query.customCountryMixes
      }
    , session
    , msg
    )


updateQueryCustomCountryMix : Step.Label -> Maybe Co2e -> Inputs.Query -> Inputs.Query
updateQueryCustomCountryMix stepLabel maybeValue ({ customCountryMixes } as query) =
    { query
        | customCountryMixes =
            case stepLabel of
                Step.WeavingKnitting ->
                    { customCountryMixes | fabric = maybeValue }

                Step.Ennoblement ->
                    { customCountryMixes | dyeing = maybeValue }

                Step.Making ->
                    { customCountryMixes | making = maybeValue }

                _ ->
                    customCountryMixes
    }


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ db } as session) msg ({ customCountryMixInputs, query } as model) =
    case msg of
        CloseModal ->
            ( { model | modal = NoModal }, session, Cmd.none )

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        GitbookContentReceived gitbookData ->
            ( { model | modal = GitbookModal gitbookData }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenCustomCountryMixModal step ->
            ( { model | modal = CustomCountryMixModal step }
            , session
            , Dom.focus "customCountryMix" |> Task.attempt (always NoOp)
            )

        OpenDocModal path ->
            ( { model | modal = GitbookModal RemoteData.Loading }
            , session
            , GitbookApi.getPage session path GitbookContentReceived
            )

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        ResetCustomCountryMix stepLabel ->
            ( { model
                | modal = NoModal
                , customCountryMixInputs =
                    customCountryMixInputs
                        |> updateCustomCountryMixInputs stepLabel Nothing
              }
            , session
            , Cmd.none
            )
                |> updateQuery (updateQueryCustomCountryMix stepLabel Nothing query)

        SubmitCustomCountryMix stepLabel Nothing ->
            model |> update session (ResetCustomCountryMix stepLabel)

        SubmitCustomCountryMix stepLabel (Just customCountryMix) ->
            ( { model | modal = NoModal }, session, Cmd.none )
                |> updateQuery (updateQueryCustomCountryMix stepLabel (Just customCountryMix) query)

        SwitchMode displayMode ->
            ( { model | displayMode = displayMode }, session, Cmd.none )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateCustomCountryMixInput stepLabel customCountryMixInput ->
            ( { model
                | customCountryMixInputs =
                    customCountryMixInputs
                        |> updateCustomCountryMixInputs stepLabel (Just customCountryMixInput)
              }
            , session
            , Cmd.none
            )

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
            let
                updatedCustomCountryMixInputs =
                    -- Reset the step's custom country mix form input on country change
                    case index of
                        1 ->
                            customCountryMixInputs
                                |> updateCustomCountryMixInputs Step.WeavingKnitting Nothing

                        2 ->
                            customCountryMixInputs
                                |> updateCustomCountryMixInputs Step.Ennoblement Nothing

                        3 ->
                            customCountryMixInputs
                                |> updateCustomCountryMixInputs Step.Making Nothing

                        _ ->
                            customCountryMixInputs
            in
            ( { model | customCountryMixInputs = updatedCustomCountryMixInputs }
            , session
            , Cmd.none
            )
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
        [ div [ class "col-md-6 mb-2" ]
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
        , div [ class "col-md-6 mb-2" ]
            [ div [ class "form-label fw-bold mb-0 mb-xxl-3" ]
                [ text "Part de matière recyclée" ]
            , RangeSlider.view
                { id = "recycledRatio"
                , update = UpdateRecycledRatio
                , value = Maybe.withDefault 0 recycledRatio
                , toString = Material.recycledRatioToString "d'origine recyclée"
                , disabled = material.recycledProcess == Nothing
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
                    , inputs = simulator.inputs
                    , detailed = displayMode == DetailedMode
                    , index = index
                    , product = simulator.inputs.product
                    , current = current
                    , next = Array.get (index + 1) simulator.lifeCycle
                    , openCustomCountryMixModal = OpenCustomCountryMixModal
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


customCountryMixModal : Model -> Step -> Html Msg
customCountryMixModal { customCountryMixInputs } step =
    let
        countryDefault =
            step.country.electricityProcess.climateChange
                |> Co2.inKgCo2e
                |> String.fromFloat

        customCountryMixInput =
            customCountryMixInputs
                |> getCustomCountryMixInput step.label

        customCountryMixInputValue =
            customCountryMixInput
                |> Maybe.withDefault countryDefault

        maybeCo2e =
            customCountryMixInputs
                |> validateCustomCountryMixInput step.label

        formIsValid =
            (customCountryMixInput == Nothing)
                || (Maybe.andThen String.toFloat customCountryMixInput /= Nothing)
    in
    ModalView.view
        { size = ModalView.Standard
        , close = CloseModal
        , noOp = NoOp
        , title =
            String.join " "
                [ "Personnalisation du mix électrique"
                , step.country.name
                , "pour"
                , Step.labelToString step.label
                ]
        , formAction = Just (SubmitCustomCountryMix step.label maybeCo2e)
        , content =
            [ div []
                [ label [ class "form-label fw-bold", for "customCountryMix" ]
                    [ text "Impact personnalisé" ]
                , div [ class "input-group" ]
                    [ input
                        [ type_ "number"
                        , id "customCountryMix" -- Note: only one widget instance on a single page
                        , class "form-control no-arrows"
                        , classList [ ( "is-invalid", not formIsValid ) ]
                        , Attr.min "0"
                        , Attr.max "1.7"
                        , Attr.step "0.000001"
                        , onInput (UpdateCustomCountryMixInput step.label)
                        , value customCountryMixInputValue
                        ]
                        []
                    , span [ class "input-group-text fs-7" ] [ text "kgCO₂e/KWh" ]
                    ]
                , if not formIsValid then
                    div [ class "invalid-feedback", style "display" "block" ]
                        [ text "Attention, cette valeur est invalide. Vérifiez votre saisie." ]

                  else
                    text ""
                , div [ class "form-text mt-2 text-center" ]
                    [ """Vous trouverez de l'aide dans la
                         [documentation dédiée](https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/electricite#parametrage-manuel-de-limpact-carbone)."""
                        |> MarkdownView.simple [ class "bottomed-paragraphs" ]
                    ]
                ]
            ]
        , footer =
            [ button
                [ type_ "button"
                , class "btn btn-secondary"
                , disabled (customCountryMixInputValue == countryDefault)
                , onClick (ResetCustomCountryMix step.label)
                ]
                [ text "Réinitialiser" ]
            , button
                [ type_ "submit"
                , class "btn btn-primary"
                , disabled (not formIsValid)
                ]
                [ text "Valider" ]
            ]
        }


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


modalView : Model -> Html Msg
modalView model =
    case model.modal of
        NoModal ->
            text ""

        CustomCountryMixModal step ->
            customCountryMixModal model step

        GitbookModal pageData ->
            gitbookModalView pageData


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
                    [ model.simulator
                        |> SummaryView.view { session = session, reusable = False }
                    ]
                , feedbackView
                , shareLinkView session simulator
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered
            [ class "Simulator pb-3" ]
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
