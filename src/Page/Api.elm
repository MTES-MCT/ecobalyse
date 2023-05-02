module Page.Api exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = NoOp Never


type alias News =
    { date : String
    , level : String
    , domains : List String
    , md : String
    }


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( ()
    , session
    , Cmd.batch
        [ Ports.loadRapidoc "/vendor/rapidoc-9.3.4.min.js"
        , Ports.scrollTo { x = 0, y = 0 }
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session _ model =
    ( model, session, Cmd.none )


getApiServerUrl : Session -> String
getApiServerUrl { clientUrl } =
    clientUrl ++ "api"


changelog : List News
changelog =
    [ { date = "28 avril 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre de titrage `yarnSize` peut maintenant être exprimé
            avec une unité, permettant de spécifier le titrage en décitex (Dtex).
"""
      }
    , { date = "25 avril 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre de choix du procédé de tricotage `knittingProcess`
            permettant de choisir un procédé autre que le "mix" par défaut a été
            rajouté.
"""
      }
    , { date = "13 avril 2023"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre de simulation `picking` permettant de définir le
            duitage a été supprim\u{00A0}; il est remplacé par un nouveau paramètre
            `yarnSize`, permettant de définir le titrage du fil utilisé pour
            l'étape de tissage, exprimé en *numéro métrique* (`Nm`).

            Le numéro métrique indique un nombre de kilomètres de fil correspondant
            à un poids d’un kilogramme (ex\u{00A0}: 50Nm = 50km de ce fil pèsent 1 kg).
"""
      }
    , { date = "12 avril 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Il est désormais possible de paramétrer les bonus appliqués à
            la diversité agricole, aux infrastructures agro-écologiques et
            aux conditions d'élevage dans les paramètres d'ingrédient.
"""
      }
    , { date = "20 mars 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Le mode de distribution a été rendu facultatif
"""
      }
    , { date = "8 mars 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Une étape a été ajoutée au constructeur de recette pour tenir
            compte de l'impact de la consommation. Un nouveau paramètre
            optionnel `preparation` a été ajouté sur le point d'entrée
            `/food/recipe`, qui accepte une liste de techniques de préparation
            (`freezing` pour congélation, `frying` pour friture, etc.)
"""
      }
    , { date = "21 février 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Une étape a été ajoutée au constructeur de recette pour tenir
            compte de l'impact de la distribution. Elle se matérialise par un
            paramètre optionnel `distribution` sur le point d'entrée
            `/food/recipe` qui prend `ambient` comme valeur par défaut pour
            indiquer qu'il s'agit d'une stockage sec à température ambiante, ou
            `fresh` pour un produit réfrigéré, ou `frozen` pour un produit
            surgelé.
"""
      }
    , { date = "21 décembre 2022"
      , level = "major"
      , domains = [ "Alimentaire", "Textile" ]
      , md =
            """La liste des pays est désormais distinctement accessible en fonction du domaine\u{00A0}:

- pour le textile, au point d'entrée `textile/countries`
- pour l'alimentaire, au point d'entrée `food/countries`

De la même façon, l'ensemble des points d'entrée textile sont désormais préfixés par `textile`, en
cohérence avec ceux de l'alimentaire qui le sont par `food`.

L'ancien point d'entrée `/countries` est donc redirigé vers `textile/countries`.
"""
      }
    , { date = "30 novembre 2022"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Un nouveau paramètre `ennoblingHeatSource` a été ajouté, permettant si besoin de préciser
            la source de chaleur à l'étape d'ennoblissement\u{00A0}; il peut prendre les valeurs
            suivantes\u{00A0}:

- `coal`: Vapeur à partir de charbon
- `naturalgas`: Vapeur à partir de gaz naturel
- `lightfuel`: Vapeur à partir de fioul léger
- `heavyfuel`: Vapeur à partir de fioul lourd

En l'absence d'utilisation explicite du paramètre, la source de chaleur utilisée sera celle du mix régional.
"""
      }
    , { date = "22 novembre 2022"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Un nouveau paramètre `printing` a été ajouté, permettant si besoin de préciser
            le procédé d'impression utilisé sur le vêtement\u{00A0}; les valeurs possibles
            sont\u{00A0}:

- `pigment`\u{00A0}: Impression pigmentaire
- `substantive`\u{00A0}: Impression Fixé-Lavé

D'autre part, le paramètre `surfaceMass` permettant de définir le grammage de l'étoffe est
désormais opérant quand le paramètre `printing` est fourni\u{00A0}; en effet, le procédé d'impression
est appliqué en fonction de la surface du vêtement, calculée au moyen de cette valeur et
qui peut désormais varier.

Enfin, l'identification de l'étape d'ennoblissement a été renommée de `dyeing` à `ennobling`. Cela
impacte le paramètre `disabledSteps` qui n'accepte désormais plus `dyeing` mais bien `ennobling` en
remplacement.
"""
      }
    , { date = "14 novembre 2022"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Un nouveau paramètre `dyeingMedium` a été ajouté pour permettre de préciser le
            support de teinture, parmi les trois valeurs possibles suivantes\u{00A0}:

- `article` lorsque la teinture est effectuée sur pièce\u{00A0};
- `fabric` lorsqu'elle est effectuée sur le tissu\u{00A0};
- `yarn` lorsqu'elle est effectuée sur fil.
"""
      }
    , { date = "9 novembre 2022"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le support du paramètre `dyeingWeighting` a été supprimé. Son utilisation est
            désormais inopérante."""
      }
    , { date = "15 septembre 2022"
      , level = "major"
      , domains = [ "Alimentaire", "Textile" ]
      , md =
            """Les scores PEF renvoyés par l'API sont désormais exprimés en `µPt` (micropoints)
            au lieu de `mPt` (millipoints).

            Pour mémoire, `1 Pt = 1\u{202F}000 mPt = 1\u{202F}000\u{202F}000 µPt`."""
      }
    , { date = "5 juillet 2022"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Un nouveau paramètre optionnel `disabledSteps` a été ajouté aux endpoints de
            simulation, permettant de définir la liste des étapes du cycle de vie à désactiver,
            séparée par des virgules. Chaque étape est identifiée par un code\u{00A0}:
- `material`: Matière
- `spinning`: Filature
- `fabric`: Tissage/Tricotage
- `ennobling`: Ennoblissement
- `making`: Confection
- `distribution`: Distribution
- `use`: Utilisation
- `eol`: Fin de vie

            Par exemple, pour désactiver les étapes de filature et d'ennoblissement, on peut passer
            `disabledSteps=spinning,ennobling`."""
      }
    , { date = "2 juin 2022"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le format de définition de la liste des matières a évolué\u{00A0};
            là où vous définissiez une liste de matières en y incluant le pourcentage de matière
            recyclée, par ex. `materials[]=coton;0.3;0.5&…` pour *30% coton à 50% recyclé*,
            vous devez désormais écrire `materials[]=coton;0.15&materials[]=coton-rdp;0.15&…`
            (soit *15% coton, 15% coton recyclé*, ce qui revient au même)."""
      }
    ]


apiBrowser : Session -> Html Msg
apiBrowser session =
    node "rapi-doc"
        -- RapiDoc options: https://mrin9.github.io/RapiDoc/api.html
        [ attribute "spec-url" (getApiServerUrl session)
        , attribute "server-url" (getApiServerUrl session)
        , attribute "default-api-server" (getApiServerUrl session)
        , attribute "theme" "light"
        , attribute "font-size" "largest"
        , attribute "load-fonts" "false"
        , attribute "layout" "column"
        , attribute "show-info" "false"
        , attribute "update-route" "false"
        , attribute "render-style" "view"
        , attribute "show-header" "false"
        , attribute "show-components" "true"
        , attribute "schema-description-expanded" "true"
        , attribute "allow-authentication" "false"
        , attribute "allow-server-selection" "false"
        , attribute "allow-api-list-style-selection" "false"
        ]
        []


view : Session -> Model -> ( String, List (Html Msg) )
view session _ =
    ( "API"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "API Ecobalyse" ]
            , div [ class "row" ]
                [ div [ class "col-xl-8" ]
                    [ Alert.simple
                        { level = Alert.Info
                        , close = Nothing
                        , title = Nothing
                        , content =
                            [ div [ class "fs-7" ]
                                [ """Cette API est en version *alpha*, l'implémentation et le contrat d'interface sont susceptibles
                             de changer à tout moment. Vous êtes vivement invité à **ne pas exploiter cette API en production**."""
                                    |> Markdown.simple []
                                ]
                            ]
                        }
                    , p [ class "fw-bold" ]
                        [ text "L'API HTTP Ecobalyse permet de calculer les impacts environnementaux des produits textiles et alimentaires." ]
                    , p []
                        [ text "Elle est accessible à l'adresse "
                        , code [] [ text (getApiServerUrl session) ]
                        , text " et "
                        , a [ href (getApiServerUrl session), target "_blank" ] [ text "documentée" ]
                        , text " au format "
                        , a [ href "https://swagger.io/specification/", target "_blank" ] [ text "OpenAPI" ]
                        , text "."
                        ]
                    , div [ class "height-auto" ] [ apiBrowser session ]
                    ]
                , div [ class "col-xl-4" ]
                    [ div [ class "card" ]
                        [ div [ class "card-header" ] [ text "Dernières mises à jour" ]
                        , changelog
                            |> List.map
                                (\{ date, level, domains, md } ->
                                    li [ class "list-group-item" ]
                                        [ div [ class "d-flex justify-content-between align-items-center mb-1" ]
                                            [ text date
                                            , span
                                                [ class "badge"
                                                , classList
                                                    [ ( "badge-danger", level == "major" )
                                                    , ( "badge-success", level /= "major" )
                                                    ]
                                                ]
                                                [ text level ]
                                                :: (domains
                                                        |> List.map
                                                            (\domain ->
                                                                span [ class "badge badge-info" ]
                                                                    [ text domain ]
                                                            )
                                                   )
                                                |> div [ class "d-flex gap-1" ]
                                            ]
                                        , Markdown.simple [ class "fs-7" ] md
                                        ]
                                )
                            |> ul [ class "list-group list-group-flush" ]
                        ]
                    ]
                ]
            ]
      ]
    )
