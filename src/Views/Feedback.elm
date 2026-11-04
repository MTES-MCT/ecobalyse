module Views.Feedback exposing (view)

import Data.Env as Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Views.Modal as Modal


view : msg -> Html msg
view close =
    Modal.view
        { close = close
        , content =
            [ div [ class "d-flex flex-column align-items-center gap-3 p-4 text-center" ]
                [ p [ class "mb-0" ]
                    [ text """Nous serions ravis que vous preniez un moment pour nous dire ce que
                              vous pensez du service. Pour cela, cliquez sur le bouton ci-dessous.""" ]
                , a
                    [ class "d-inline-block"
                    , href Env.feedbackUrl
                    , onClick close
                    , rel "noopener noreferrer"
                    , target "_blank"
                    , title "Je donne mon avis - nouvelle fenêtre"
                    ]
                    [ img
                        [ alt "Je donne mon avis"
                        , class "img-fluid"
                        , src "https://jedonnemonavis.numerique.gouv.fr/static/bouton-bleu-clair.svg"
                        ]
                        []
                    ]
                ]
            ]
        , footer = []
        , formAction = Nothing
        , noOp = close
        , size = Modal.Standard
        , subTitle = Nothing
        , title = "Donnez-nous votre avis !"
        }
