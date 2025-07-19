module Views.WebData exposing (map)

import Html exposing (Html, text)
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.BackendHttp.Error as BackendError
import Views.Alert as Alert
import Views.Spinner as Spinner


map : (a -> Html msg) -> WebData a -> Html msg
map fn webData =
    case webData of
        RemoteData.Failure err ->
            Alert.serverError <| BackendError.errorToString err

        RemoteData.Loading ->
            Spinner.view

        RemoteData.NotAsked ->
            text ""

        RemoteData.Success data ->
            fn data
