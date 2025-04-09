module Request.Component exposing
    ( deleteComponent
    , getComponents
    , patchComponent
    )

import Data.Component as Component exposing (Component)
import Data.Scope as Scope
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


apiBaseUrl : String
apiBaseUrl =
    -- FIXME: should be configurable
    "https://ecobalyse-data-pr65.osc-fr1.scalingo.io/api"


deleteComponent : Session -> (WebData String -> msg) -> Component -> Cmd msg
deleteComponent _ event component =
    -- curl -X PATCH https://ecobalyse-data-pr65.osc-fr1.scalingo.io/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9 -d '{"name":"Tissu pour joli canapé"}' --header "Content-Type: application/json"
    -- {"id":"8ca2ca05-8aec-4121-acaa-7cdcc03150a9","name":"Tissu pour joli canapé","elements":[{"amount":1.0,"material":"62a4d6fb-3276-4ba5-93a3-889ecd3bff84","transforms":["9c478d79-ff6b-45e1-9396-c3bd897faa1d","da9d1c32-a166-41ab-bac6-f67aff0cf44a"]},{"amount":1.0,"material":"9dba0e95-0c35-4f8b-9267-62ddf47d4984","transforms":["9c478d79-ff6b-45e1-9396-c3bd897faa1d","ae9cbbad-7982-4f3c-9220-edf27946d347"]}]}
    -- FIXME: use session to secure access?
    Http.deleteWithConfig { defaultConfig | headers = [] }
        (apiBaseUrl ++ "/components/" ++ Component.idToString component.id)
        event
        (Component.encode component)


getComponents : Session -> (WebData (List Component) -> msg) -> Cmd msg
getComponents _ event =
    -- FIXME: use session to secure access?
    Component.decodeList Scope.all
        |> Http.getWithConfig { defaultConfig | headers = [] }
            (apiBaseUrl ++ "/components")
            event


patchComponent : Session -> (WebData Component -> msg) -> Component -> Cmd msg
patchComponent _ event component =
    -- curl -X PATCH https://ecobalyse-data-pr65.osc-fr1.scalingo.io/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9 -d '{"name":"Tissu pour joli canapé"}' --header "Content-Type: application/json"
    -- {"id":"8ca2ca05-8aec-4121-acaa-7cdcc03150a9","name":"Tissu pour joli canapé","elements":[{"amount":1.0,"material":"62a4d6fb-3276-4ba5-93a3-889ecd3bff84","transforms":["9c478d79-ff6b-45e1-9396-c3bd897faa1d","da9d1c32-a166-41ab-bac6-f67aff0cf44a"]},{"amount":1.0,"material":"9dba0e95-0c35-4f8b-9267-62ddf47d4984","transforms":["9c478d79-ff6b-45e1-9396-c3bd897faa1d","ae9cbbad-7982-4f3c-9220-edf27946d347"]}]}
    -- FIXME: use session to secure access?
    Http.patchWithConfig { defaultConfig | headers = [] }
        (apiBaseUrl ++ "/components/" ++ Component.idToString component.id)
        event
        (Component.decode Scope.all)
        (Component.encode component)
