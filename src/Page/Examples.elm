module Page.Examples exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs
import Data.Sample as Sample
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Container as Container
import Views.Format as Format
import Views.Summary as SummaryView


type alias Model =
    ()


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( (), session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


viewExamples : Session -> Html Msg
viewExamples session =
    div []
        [ div [ class "row mb-3" ]
            [ div [ class "col-md-7 col-lg-8 col-xl-9" ]
                [ h1 [ class "mb-3" ] [ text "Exemples de simulation" ]
                ]
            , div [ class "col-md-5 col-lg-4 col-xl-3 text-center text-md-end" ]
                [ a
                    [ Route.href (Route.Simulator Nothing)
                    , class "btn btn-primary w-100"
                    ]
                    [ text "Faire une simulation" ]
                ]
            ]
        , Inputs.presets
            |> List.map
                (Simulator.compute session.db
                    >> SummaryView.view { session = session, reusable = True }
                    >> (\v -> div [ class "col" ] [ v ])
                )
            |> div [ class "row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4" ]
        ]


formatCustomCountryMixes : Inputs.CustomCountryMixes -> Html Msg
formatCustomCountryMixes { fabric, dyeing, making } =
    let
        mixes =
            [ ( "Tissage/Tricotage", fabric )
            , ( "Teinture", dyeing )
            , ( "Confection", making )
            ]
                |> List.filterMap
                    (\( step, mix ) ->
                        mix |> Maybe.map (\mix_ -> span [] [ text step, text "\u{00A0}: ", Format.kgCo2 3 mix_ ])
                    )
    in
    if List.length mixes == 0 then
        text "Aucun"

    else
        mixes
            |> List.intersperse (br [] [])
            |> div []


viewSectionOrSample : Session -> Sample.SectionOrSample -> Html Msg
viewSectionOrSample session sectionOrSample =
    let
        headers =
            [ th [ scope "col" ] [ text "Produit" ]
            , th [ scope "col" ] [ text "Matière" ]
            , th [ scope "col" ] [ text "Masse" ]
            , th [ scope "col" ] [ text "Circuit" ]
            , th [ scope "col" ] [ text "Matière recyclée" ]
            , th [ scope "col" ] [ text "Teinture majorée" ]
            , th [ scope "col" ] [ text "Transport avion" ]
            , th [ scope "col" ] [ text "Mix modifié" ]
            , th [ scope "col", class "text-center" ] [ text "Impact" ]
            , th [ scope "col", class "text-center" ] [ text "Action" ]
            ]
    in
    case sectionOrSample of
        Sample.Section title samples ->
            div []
                [ tr []
                    [ td [] [ h3 [ class "fs-4" ] [ text title ] ]
                    ]
                , samples
                    |> List.map (viewSectionOrSample session)
                    |> (\rows ->
                            div [ class "table-responsive" ]
                                [ table [ class "table table-sm table-hover align-middle" ]
                                    [ if Sample.hasTests samples then
                                        thead []
                                            [ tr [ class "fs-7" ] headers
                                            ]

                                      else
                                        text ""
                                    , tbody [] rows
                                    ]
                                ]
                       )
                ]

        Sample.Sample sampleTitle { query, expected } ->
            case Simulator.compute session.db query of
                Err error ->
                    tr [ class "table-danger" ]
                        [ td [ headers |> List.length |> colspan ] [ text error ] ]

                Ok simulator ->
                    let
                        success =
                            simulator.co2 == expected
                    in
                    tr
                        [ class "fs-7"
                        , classList [ ( "table-success", success ), ( "table-danger", not success ) ]
                        , title sampleTitle
                        ]
                        [ td [] [ text simulator.inputs.product.name ]
                        , td [] [ text simulator.inputs.material.shortName ]
                        , td [ class "text-end" ] [ Format.kg simulator.inputs.mass ]
                        , td [] [ query.countries |> List.map Country.codeToString |> String.join "→" |> text ]
                        , td [] [ query.recycledRatio |> Maybe.map ((*) 100 >> Format.percent) |> Maybe.withDefault (text "Non") ]
                        , td [] [ query.dyeingWeighting |> Maybe.map ((*) 100 >> Format.percent) |> Maybe.withDefault (text "Non") ]
                        , td [] [ query.airTransportRatio |> Maybe.map ((*) 100 >> Format.percent) |> Maybe.withDefault (text "Non") ]
                        , td [] [ formatCustomCountryMixes query.customCountryMixes ]
                        , td [ class "text-end" ]
                            [ if success then
                                Format.kgCo2 3 expected

                              else
                                div []
                                    [ text "Attendu: "
                                    , Format.kgCo2 3 expected
                                    , br [] []
                                    , text "Calculé: "
                                    , Format.kgCo2 3 simulator.co2
                                    ]
                            ]
                        , td [ class "text-center" ]
                            [ a
                                [ class "btn btn-sm btn-primary"
                                , Route.href (Route.Simulator (Just query))
                                ]
                                [ text "Charger" ]
                            ]
                        ]


viewSamples : Session -> Html Msg
viewSamples session =
    div [ class "py-5" ]
        [ div [ class "row mb-3" ]
            [ h2 [ class "mb-3" ] [ text "Suite de test" ]
            ]
        , Sample.samples
            |> List.map (viewSectionOrSample session)
            |> div []
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session _ =
    ( "Exemples"
    , [ Container.centered [ class "pb-5" ]
            [ viewExamples session
            , viewSamples session
            ]
      ]
    )
