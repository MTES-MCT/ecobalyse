module Page.Api exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import App exposing (PageUpdate)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Route
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


init : Session -> PageUpdate Model Msg
init session =
    App.createUpdate session ()
        |> App.withCmds
            [ Ports.loadRapidoc "/vendor/rapidoc-9.3.4.min.js"
            , Ports.scrollTo { x = 0, y = 0 }
            ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        NoOp _ ->
            App.createUpdate session model


getApiServerUrl : Session -> String
getApiServerUrl { clientUrl } =
    clientUrl ++ "/api"


changelog : List News
changelog =
    [ { date = "23 février 2026"
      , level = "minor"
      , domains = [ "Textile" ]
      , md = """Ajout de l'impact des accessoires textiles dans les réponses de l’API."""
      }
    , { date = "17 février 2026"
      , level = "major"
      , domains = [ "Textile", "Alimentaire", "Objets" ]
      , md = """- Les requêtes non authentifiées à l'API ne sont plus autorisées et nécessitent l’utilisation d’un jeton.
               **Pour accéder à l’API, il est maintenant nécessaire de fournir un jeton d'API**,
               accessible dans votre [compte utilisateur]({route}) une fois connecté.

- **Pour accéder au détail des impact, vous devez également [accepter les conditions d’utilisation ecoinvent]({route})**.
""" |> String.replace "{route}" (Route.toString Route.Auth)
      }
    , { date = "11 décembre 2025"
      , level = "major"
      , domains = [ "Textile", "Alimentaire", "Objets" ]
      , md = """Suppression de l’indicateur PEF obsolète dans les réponses de l’API."""
      }
    , { date = "22 juillet 2025"
      , level = "major"
      , domains = [ "Textile" ]
      , md = """Le paramétrage de la surface d'impression interdit désormais les valeurs supérieures à 80%."""
      }
    , { date = "9 juillet 2025"
      , level = "major"
      , domains = [ "Textile" ]
      , md = """Le paramètre `traceability` est supprimé."""
      }
    , { date = "15 avril 2025"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md = """Afin de permettre une meilleure gestion des données et d'éviter des calculs redondants, **Les identifiants des procédés alimentaires (transformation ou emballage) ont été modifiés.** Les anciens identifiants ne sont plus valides et doivent être remplacés par les nouveaux. Les identifiants des ingrédients sont inchangés."""
      }
    , { date = "26 février 2025"
      , level = "major"
      , domains = [ "Textile" ]
      , md = """Les points d'entrée utilisant les paramètres passés en query string pour effectuer des calculs
      sont dépréciés, leur équivalent `POST`/`JSON` leur étant désormais préférés\u{00A0}:
- `GET /food` est déprécié
- `GET /textile/simulator` est déprécié
- `GET /textile/simulator/{impact}` est déprécié
- `GET /textile/simulator/detailed` est déprécié

                **Note: ces points d'entrée seront supprimés dans la prochaine version majeure de l'application.**

                D'autre part et par souci de cohérence et de consistance, certains noms de champs utilisent
                désormais le `camelCase` dans les réponses API\u{00A0}:
- `elec_kWh` devient `elecKWh`
- `heat_MJ` devient `heatMJ`"""
      }
    , { date = "17 février 2025"
      , level = "major"
      , domains = [ "Textile" ]
      , md = """Le paramètre `dyeingMedium`, qui permettait de sélectionner le support de teinture,
                est remplacé par le nouveau paramètre `dyeingProcessType` permettant de spécifier
                le type de teinture directement (continue, discontinue, moyenne)."""
      }
    , { date = "2 janvier 2025"
      , level = "minor"
      , domains = [ "Textile" ]
      , md = """Un nouveau paramètre `trims` est disponible dans l'API textile pour préciser les
                accessoires présents sur le vêtement. Un nouveau point d'entrée `/textile/trims`
                a également été ajouté pour lister les accessoires disponibles."""
      }
    , { date = "5 décembre 2024"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md = """Les identifiants de procédés alimentaires sont désormais au format UUID. Le précedent champ
                `code` pour lier les procédés d'emballage et de transformation est remplacé par la clé `id`
                exploitant ce format."""
      }
    , { date = "13 novembre 2024"
      , level = "minor"
      , domains = []
      , md = "Ajout d'une [FAQ](/#/pages/api-faq) dédiée à l'API."
      }
    , { date = "29 octobre 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md = "Ajout du champ `impactsWithoutDurability` dans la réponse des calculs détaillés. Ce champ a le même format que le champ `impacts` mais contient les scores avant application du coefficient de durabilité."
      }
    , { date = "5 septembre 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md = "Ajout du champ `physicalDurability` qui permet de préciser la durabilité physique d'un vêtement."
      }
    , { date = "29 août 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md = """Ajout du champ booléen `upcycled` qui permet de préciser si un vêtement est remanufacturé.
                En pareil cas, les étape Matières, Filature, Tissage/Tricotage et Ennoblissement sont
                désactivées et la complexité en confection est automatiquement positionnée sur "Élevée".
             """
      }
    , { date = "28 août 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Les champs `countryFabric`, `countryDyeing` at `countryMaking` sont désormais optionnels et prennent pour valeur par défaut celles du *Pays inconnu* (voir la
               [documentation méthodologique](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/transport#pays-par-defaut-etapes-de-transformation)).
               Techniquement, stipuler le code `"---"` pour ces paramètres ou les omettre revient désormais au même.
            """
      }
    , { date = "18 juillet 2024"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le champ `marketingDuration` a été supprimé et n'est désormais plus opérant.
            """
      }
    , { date = "6 juin 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le champ `fabricProcess` n'est plus requis et prend désormais la valeur par
            défaut associée à la catégorie de produit.
            """
      }
    , { date = "10 avril 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Les compléments sont désormais exposés de façon à mieux matérialiser leurs
               effets\u{00A0}; une dégradation est désormais exprimée par un nombre positif
               (qui additionnée au coût le fait augmenter), tandis qu'une amélioration
               s'exprime par une valeur négative (qui additionnée au coût le fait baisser).
            """
      }
    , { date = "9 avril 2024"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """En mode détaillé, le coût environnemental d'une étape du cycle de vie textile
               inclut désormais l'impact des compléments associés."""
      }
    , { date = "25 mars 2024"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md = "La documentation de l'API alimentaire est temporairement mise hors-ligne."
      }
    , { date = "21 février 2024"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre `ennoblingHeatSourceParam` est supprimé. La source
            de chaleur est donnée par la zone France, Europe ou World,
            calculée depuis le pays."""
      }
    , { date = "31 janvier 2024"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre `durability` récemment introduit est remplacé par 5 nouveaux
            paramètres permettant de calculer cet indice\u{00A0}: `business`, `marketingDuration`,
            `numberOfReferences`, `price`, `repairCost` et `traceability`."""
      }
    , { date = "16 janvier 2024"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md =
            """Les paramètres permettant de spécifier des compléments (ou bonus)
            personnalisés par ingrédient ont été retirés, il sont remplacés par la
            gestion automatisée des services écosystémiques."""
      }
    , { date = "15 janvier 2024"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Les paramètres `quality` et `reparability` on été supprimés. Il sont
            remplacés par le champ `durability`."""
      }
    , { date = "21 décembre 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre `makingDeadStock` a été rajouté pour représenter
            le taux de stocks dormants lors de la phase de confection. La valeur par défaut
            est de 15% (0.15)."""
      }
    , { date = "20 décembre 2023"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre `disabledFading` a été renommé en `fading` et représente
            l'opposé. Sélectionner `true` pour **activer** le délavage."""
      }
    , { date = "20 décembre 2023"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre optionnel `knittingProcess` a été remplacé par le
            paramètre requis `fabricProcess`, qui prend en compte les différents
            procédés de tricotage ainsi que le procédé de tissage."""
      }
    , { date = "19 décembre 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre `disabledFading` peut maintenant être configuré pour
            tous les produits."""
      }
    , { date = "9 novembre 2023"
      , level = "minor"
      , domains = [ "Alimentaire", "Textile" ]
      , md =
            """La liste des matières premières textiles et des ingrédients
            alimentaires peuvent maintenant être vides."""
      }
    , { date = "24 octobre 2023"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md =
            """Les identifiants de certains procédés ont été modifiés:

- `durumwheat-semolina` devient `durum-wheat-semolina`;
- `durumwheat` devient `durum-wheat`;
- `Flank-steak` devient `flank-steak`;
- `frenchbean` devient `french-bean`;
- `huilecolza` devient `rapeseed-oil`;
- `huilecolza-organic` devient `rapeseed-oil-organic`;
- `soybeanBRdeforestation` devient `soybean-br-deforestation`;
- `soybeanBRno-deforestation` devient `soybean-br-no-deforestation`;
- `sunfloweroil` devient `sunflower-oil`;
- `sunfloweroil-organic` devient `sunflower-oil-organic`;
- `tapwater` devient `tap-water`;
- `comte-AOP` devient `comte-aop`.
"""
      }
    , { date = "12 octobre 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramétrage optionnel `country` du code de pays d'origine pour la
            matière a été rajouté."""
      }
    , { date = "4 septembre 2023"
      , level = "major"
      , domains = [ "Textile" ]
      , md =
            """Le choix de valeurs pour le paramétrage `knittingProcess` a changé.
            Il faut maintenant choisir entre\u{00A0}:

- `mix` : Tricotage moyen (mix de métiers circulaire & rectiligne)
- `fully-fashioned` : Tricotage fully-fashioned / seamless
- `integral` : Tricotage intégral / whole garment
- `circular` : Tricotage circulaire, inventaire désagrégé
- `straight` : Tricotage rectiligne, inventaire désagrégé
"""
      }
    , { date = "29 août 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramétrage optionnel `spinning` du procédé de filature ou filage pour la
            matière a été rajouté.
"""
      }
    , { date = "6 juillet 2023"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md =
            """Le paramétrage de la variante a été supprimé du mode de requêtage en query string;
            là où on passait `?ingredients=carrot;100;organic;ES` pour 100g de carrot bio
            d'espagne, on passe désormais `?ingredients=carrot;100;ES`; le segment définissant
            la variante — `organic` — a été légitimement supprimé.
"""
      }
    , { date = "25 mai 2023"
      , level = "major"
      , domains = [ "Alimentaire" ]
      , md =
            """Le paramètre `category`, qui permettait d'établir des scores intra-catégoriques,
            a été supprimé. De la même façon, les notes lettrées et les scores sur 100 ont été
            retirés des résultats. Le scoring ne contient désormais par conséquent que les
            impacts par aires de protection.
"""
      }
    , { date = "17 mai 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Le calcul de l'écoscore dans le résultat de l'API alimentaire de constructeur
            de recette prend maintenant correctement en compte les bonus des ingrédients.

            Par ailleurs, le bonus total a été rajouté sous l'entrée `recipe.totalBonusImpact`.
"""
      }
    , { date = "16 mai 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Les points d'accès de simulation textile acceptent désormais le verbe
            `POST` assorti d'une requête au format JSON.
"""
      }
    , { date = "3 mai 2023"
      , level = "minor"
      , domains = [ "Alimentaire" ]
      , md =
            """Un nouveau point d'accès `POST /api/food/recipe` a été créé,
            acceptant les requêtes au format JSON.
"""
      }
    , { date = "28 avril 2023"
      , level = "minor"
      , domains = [ "Textile" ]
      , md =
            """Le paramètre permettant de choisir la complexité de la confection
            `makingComplexity` a été rajouté.

            D'autre part, le paramètre de titrage `yarnSize` peut maintenant être exprimé
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
            à un poids d'un kilogramme (ex\u{00A0}: 50Nm = 50km de ce fil pèsent 1 kg).
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
        , attribute "allow-authentication" "true"
        , attribute "persist-auth" "true"
        ]
        []


view : Session -> ( String, List (Html Msg) )
view session =
    ( "API"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "API Ecobalyse" ]
            , div [ class "row" ]
                [ div [ class "col-xl-8 d-flex flex-column gap-3" ]
                    [ """L'API HTTP Ecobalyse permet de calculer les impacts environnementaux des produits textiles et alimentaires. """
                        |> Markdown.simple [ class "fw-bold" ]
                    , p [ class "mb-0" ]
                        [ text "Elle est accessible à l'adresse "
                        , code [] [ text (getApiServerUrl session) ]
                        , text " et "
                        , a [ href (getApiServerUrl session), target "_blank" ] [ text "documentée" ]
                        , text " au format "
                        , a [ href "https://swagger.io/specification/", target "_blank" ] [ text "OpenAPI" ]
                        , text "."
                        ]
                    , apiDocumentationNotice session
                    , div [ class "height-auto" ] [ apiBrowser session ]
                    ]
                , div [ class "col-xl-4 d-flex flex-column gap-3" ]
                    [ Alert.simple
                        { attributes = []
                        , level = Alert.Info
                        , close = Nothing
                        , title = Just "Avertissement"
                        , content =
                            [ """Cette API est **expérimentale** et n'offre à ce stade **aucune garantie de disponibilité ni de
             stabilité** du service, le contrat d'interface restant susceptible de changer à tout moment en
             fonction des retours et demandes d'évolutions. **Il est vivement déconseillé de vous reposer sur
             cette API en production et/ou pour des missions critiques.**"""
                                |> Markdown.simple [ class "fs-7" ]
                            , p [ class "fs-8 mb-0 text-end" ]
                                [ a [ Route.href (Route.Editorial "api-faq") ] [ text "Accéder à la FAQ »" ]
                                ]
                            ]
                        }
                    , div [ class "card" ]
                        [ div [ class "card-header" ] [ text "Dernières mises à jour" ]
                        , changelog
                            |> List.map
                                (\{ date, level, domains, md } ->
                                    li [ class "list-group-item" ]
                                        [ div [ class "d-flex justify-content-between align-items-right mb-1" ]
                                            [ div [ class "text-nowrap" ] [ text date ]
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
                                                |> div [ class "d-flex gap-1 flex-wrap justify-content-end" ]
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


apiDocumentationNotice : Session -> Html msg
apiDocumentationNotice session =
    let
        alert level md =
            Alert.simple
                { attributes = []
                , level = level
                , close = Nothing
                , title = Nothing
                , content = [ Markdown.simple [ class "fs-7" ] md ]
                }
    in
    if Session.isAuthenticated session then
        """Vous êtes connecté, vous pouvez utiliser l'API avec un jeton dédié.
                Vous pouvez créer et gérer ces jetons depuis votre [compte utilisateur]({route})."""
            |> String.replace "{route}" (Route.toString Route.Auth)
            |> alert Alert.Success

    else
        """Les requêtes non authentifiées à l'API ne sont pas autorisées et nécessitent l’utilisation d’un jeton.
               **Pour accéder à l’API, il est nécessaire de fournir un jeton d'API**,
               accessible dans votre [compte utilisateur]({route}) une fois connecté. **Pour accéder au détail 
               des impact, vous devez également [accepter les conditions d’utilisation ecoinvent]({route})**."""
            |> String.replace "{route}" (Route.toString Route.Auth)
            |> alert Alert.Info
