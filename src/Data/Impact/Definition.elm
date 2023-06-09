module Data.Impact.Definition exposing (Definition, definitions)

import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit


type alias Definition =
    { trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Scope
    }


type Trigram
    = Trigram String


type alias Source =
    { label : String, url : String }


type Quality
    = NotFinished
    | GoodQuality
    | AverageQuality
    | BadQuality
    | UnknownQuality


type alias AggregatedScoreData =
    { color : String
    , normalization : Unit.Impact
    , weighting : Unit.Ratio
    }


type alias Definitions =
    { ecs : Definition
    , pef : Definition
    , acd : Definition
    , ozd : Definition
    , cch : Definition
    , fwe : Definition
    , swe : Definition
    , tre : Definition
    , pco : Definition
    , pma : Definition
    , ior : Definition
    , fru : Definition
    , mru : Definition
    , ldu : Definition
    , wtu : Definition
    , etf : Definition
    , etfc : Definition
    , htc : Definition
    , htcc : Definition
    , htn : Definition
    , htnc : Definition
    , bvi : Definition
    }


definitions : Definitions
definitions =
    { ecs =
        { trigram = Trigram "ecs"
        , source =
            { label = "Ecobalyse"
            , url = "https://ecobalyse.beta.gouv.fr/"
            }
        , label = "Score d'impacts"
        , description = "Impact *agrégé* : somme des impacts **normalisés** et **pondérés** de chaque catégorie d'impact selon la méthode Ecobalyse, incluant l'impact sur la biodiversité.\n\nCet indicateur n'a **pas de dimension**, il se mesure en **Points** (`Pt`), en **milliPoints** (`mPt`) ou en **microPoints** (`µPt`) avec `1 Pt = 1\u{00A0}000 mPt = 1\u{00A0}000\u{00A0}000 µPt`. `1 Pt` correspond à l'impact total d'un européen sur une année."
        , unit = "µPts"
        , decimals = 2
        , quality = UnknownQuality
        , pefData = Nothing
        , ecoscoreData = Nothing
        , scopes = [ Scope.Food ]
        }
    , pef =
        { trigram = Trigram "pef"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Score PEF"
        , description = "Impact *agrégé* : somme des impacts **normalisés** et **pondérés** de chaque catégorie d'impact selon la méthode *single score* du PEF. 12 impacts différents pris en compte à ce stade. 4 encore à ajouter.\n\nCet indicateur n'a **pas de dimension**, il se mesure en **Points** (`Pt`), en **milliPoints** (`mPt`) ou en **microPoints** (`µPt`) avec `1 Pt = 1\u{00A0}000 mPt = 1\u{00A0}000\u{00A0}000 µPt`. `1 Pt` correspond à l'impact total d'un européen sur une année."
        , unit = "µPt PEF"
        , decimals = 2
        , quality = UnknownQuality
        , pefData = Nothing
        , ecoscoreData = Nothing
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , acd =
        { trigram = Trigram "acd"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Acidification"
        , description = "Indicateur de l'**acidification potentielle des sols et des eaux** due à la libération de gaz tels que les oxydes d'azote et les oxydes de soufre.\n\nCet indicateur se mesure en mol (quantité de matière) d'équivalent d'ions hydrogène (`H+`)."
        , unit = "molH+e"
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#ff1493"
                , normalization = Unit.impact 5.55695e1
                , weighting = Unit.ratio 0.062
                }
        , ecoscoreData =
            Just
                { color = "#91cf4f"
                , normalization = Unit.impact 5.55695e1
                , weighting = Unit.ratio 0.0458
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , ozd =
        { trigram = Trigram "ozd"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Appauvrissement de la couche d'ozone"
        , unit = "kgCFC11e"
        , decimals = 2
        , description = "La couche d'ozone est située en haute altitude dans l'atmosphère, elle protège des rayons ultra-violets solaires. Son appauvrissement augmente l'**exposition de l'ensemble des êtres vivants à ces radiations négatives** (cancérigènes en particulier).\n\nCet indicateur se mesure en kg d'équivalent `CFC 11`, le CFC 11 (trichlorofluorométhane) étant l'un des gaz responsable de l'appauvrissement de la couche d'ozone."
        , quality = GoodQuality
        , pefData =
            Just
                { color = "#800080"
                , normalization = Unit.impact 5.3648e-2
                , weighting = Unit.ratio 0.0631
                }
        , ecoscoreData =
            Just
                { color = "#ffc000"
                , normalization = Unit.impact 5.3648e-2
                , weighting = Unit.ratio 0.0466
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , cch =
        { trigram = Trigram "cch"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Changement climatique"
        , unit = "kgCO₂e"
        , decimals = 2
        , description = "Indicateur le plus connu, correspond à la **modification du climat**, affectant l'écosystème global.\n\nCet indicateur se mesure en kg équivalent `CO₂`, le principal gaz à effet de serre."
        , quality = GoodQuality
        , pefData =
            Just
                { color = "#800000"
                , normalization = Unit.impact 7.55308e3
                , weighting = Unit.ratio 0.2106
                }
        , ecoscoreData =
            Just
                { color = "#9025be"
                , normalization = Unit.impact 7.55308e3
                , weighting = Unit.ratio 0.2106
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , fwe =
        { trigram = Trigram "fwe"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Eutrophisation eaux douces"
        , description = "Indicateur correspondant à un **enrichissement excessif des milieux naturels en nutriments**, ce qui conduit à une prolifération et une asphyxie (zone morte). C'est ce phénomène qui est à l'origine des algues vertes. On peut le retrouver en rivière et en lac également.\n\nCet indicateur se mesure en kg d'équivalent Phosphore (`P`), le phosphore étant l'un des éléments responsables de l'eutrophisation des eaux douces."
        , unit = "kgPe"
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#1f7dca"
                , normalization = Unit.impact 1.60685
                , weighting = Unit.ratio 0.028
                }
        , ecoscoreData =
            Just
                { color = "#548235"
                , normalization = Unit.impact 1.60685
                , weighting = Unit.ratio 0.0207
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , swe =
        { trigram = Trigram "swe"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Eutrophisation marine"
        , description = "Indicateur correspondant à un **enrichissement excessif des milieux naturels en nutriments**, ce qui conduit à une prolifération et une asphyxie (zone morte). C'est ce phénomène qui est à l'origine des algues vertes.\n\nCet indicateur se mesure en kg d'équivalent azote (`N`), l'azote étant l'un des éléments responsables de l'eutrophisation des eaux marines."
        , unit = "kgNe"
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#000080"
                , normalization = Unit.impact 1.95452e1
                , weighting = Unit.ratio 0.0296
                }
        , ecoscoreData =
            Just
                { color = "#70ad47"
                , normalization = Unit.impact 1.95452e1
                , weighting = Unit.ratio 0.0219
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , tre =
        { trigram = Trigram "tre"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Eutrophisation terrestre"
        , description = "Comme dans l'eau, l'eutrophisation terrestre correspond à un **enrichissement excessif du milieu**, en azote en particulier, conduisant a un déséquilibre et un appauvrissement de l'écosystème. Ceci concerne principalement les sols agricoles.\n\nCet indicateur se mesure en mol d'équivalent azote (`N`)."
        , unit = "molNe"
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#20b2aa"
                , normalization = Unit.impact 1.76755e2
                , weighting = Unit.ratio 0.0371
                }
        , ecoscoreData =
            Just
                { color = "#c5e0b4"
                , normalization = Unit.impact 1.76755e2
                , weighting = Unit.ratio 0.0274
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , pco =
        { trigram = Trigram "pco"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Formation d'ozone photochimique"
        , description = "Indicateur correspondant à la **dégradation de la qualité de l'air**, principalement via la formation de brouillard de basse altitude nommé *smog*. Il a des conséquences néfastes sur la santé.\n\nCet indicateur se mesure en kg d'équivalent Composés Organiques Volatiles Non Méthaniques (`COVNM`), un ensemble de composés organiques (alcools, aromatiques,...) contribuant à la formation d'ozone photochimique."
        , unit = "kgNMVOCe"
        , decimals = 2
        , quality = GoodQuality
        , pefData =
            Just
                { color = "#da70d6"
                , normalization = Unit.impact 4.08592e1
                , weighting = Unit.ratio 0.0478
                }
        , ecoscoreData =
            Just
                { color = "#ff6161"
                , normalization = Unit.impact 4.08592e1
                , weighting = Unit.ratio 0.0353
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , pma =
        { trigram = Trigram "pma"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Particules"
        , description = "Indicateur correspondant aux **effets négatifs sur la santé humaine** causés par les émissions de particules (`PM`) et de leurs précurseurs (`NOx`, `SOx`, `NH3`).\n\nCet indicateur se mesure en incidence de maladie supplémentaire due aux particules"
        , unit = "dis.inc."
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#696969"
                , normalization = Unit.impact 5.95367e-4
                , weighting = Unit.ratio 0.0896
                }
        , ecoscoreData =
            Just
                { color = "#ffc000"
                , normalization = Unit.impact 5.95367e-4
                , weighting = Unit.ratio 0.0662
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , ior =
        { trigram = Trigram "ior"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Radiations ionisantes"
        , description = "Indicateur correspondant aux dommages pour la **santé humaine et les écosystèmes** liés aux émissions de radionucléides.\n\nIl se mesure en kilobecquerel d'equivalent `Uranium 235`."
        , unit = "kBqU235e"
        , decimals = 2
        , quality = AverageQuality
        , pefData =
            Just
                { color = "#ffd700"
                , normalization = Unit.impact 4.22016e3
                , weighting = Unit.ratio 0.0501
                }
        , ecoscoreData =
            Just
                { color = "#be8f00"
                , normalization = Unit.impact 4.22016e3
                , weighting = Unit.ratio 0.037
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , fru =
        { trigram = Trigram "fru"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Utilisation de ressources fossiles"
        , description = "Indicateur de l'**épuisement des ressources naturelles en combustibles fossiles** (gaz, charbon, pétrole).\n\nIl se mesure en mégajoules (`MJ`), la quantité d'énergie fossile utilisée."
        , unit = "MJ"
        , decimals = 2
        , quality = BadQuality
        , pefData =
            Just
                { color = "#000000"
                , normalization = Unit.impact 6.50043e4
                , weighting = Unit.ratio 0.0832
                }
        , ecoscoreData =
            Just
                { color = "#9dc3e6"
                , normalization = Unit.impact 6.50043e4
                , weighting = Unit.ratio 0.0614
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , mru =
        { trigram = Trigram "mru"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Utilisation de ressources minérales et métalliques"
        , description = "Indicateur de l'**épuisement des ressources naturelles non fossiles**.\n\nIl se mesure en kg d'équivalent d'antimoine (`Sb`) (élément métallique)."
        , unit = "kgSbe"
        , decimals = 2
        , quality = BadQuality
        , pefData =
            Just
                { color = "#a9a9a9"
                , normalization = Unit.impact 6.36226e-2
                , weighting = Unit.ratio 0.0755
                }
        , ecoscoreData =
            Just
                { color = "#698ed0"
                , normalization = Unit.impact 6.36226e-2
                , weighting = Unit.ratio 0.0557
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , ldu =
        { trigram = Trigram "ldu"
        , source =
            { label = "Base Impacts"
            , url = "https://base-impacts.ademe.fr/"
            }
        , label = "Utilisation des sols"
        , description = "Mesure de l'évolution de la **qualité des sols** (production biotique, résistance à l'érosion, filtration mécanique).\n\nCet indicateur n'a pas de dimension, il se mesure en Points (`Pt`)."
        , unit = "Pt"
        , decimals = 2
        , quality = BadQuality
        , pefData =
            Just
                { color = "#006400"
                , normalization = Unit.impact 8.19498e5
                , weighting = Unit.ratio 0.0794
                }
        , ecoscoreData =
            Just
                { color = "#a9d18e"
                , normalization = Unit.impact 8.19498e5
                , weighting = Unit.ratio 0.0586
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , wtu =
        { trigram = Trigram "wtu"
        , source =
            { label = "Kering"
            , url = "https://kering-group.opendatasoft.com/explore/dataset/raw-material-intensities-2020/information/"
            }
        , label = "Utilisation de ressources en eau"
        , description = "Indicateur de la consommation d'eau et son épuisement dans certaines régions. **À ce stade, elle n'est prise en compte que pour l'étape “Matière & Filature”.**\n\nCet indicateur se mesure en **mètre cube (`m³`)** d'eau consommé."
        , unit = "m³"
        , decimals = 2
        , quality = NotFinished
        , pefData =
            Just
                { color = "#00ffff"
                , normalization = Unit.impact 1.14687e4
                , weighting = Unit.ratio 0.0851
                }
        , ecoscoreData =
            Just
                { color = "#0070c0"
                , normalization = Unit.impact 1.14687e4
                , weighting = Unit.ratio 0.0628
                }
        , scopes = [ Scope.Textile, Scope.Food ]
        }
    , etf =
        { trigram = Trigram "etf"
        , source =
            { label = "Agribalyse"
            , url = "https://agribalyse.ademe.fr/"
            }
        , label = "Écotoxicité de l'eau douce"
        , description = "Indicateur d'écotoxicité pour écosystèmes aquatiques d'eau douce. Cet indicateur se mesure en Comparative Toxic Unit for ecosystems (CTUe)"
        , unit = "CTUe"
        , decimals = 2
        , quality = NotFinished
        , pefData =
            Just
                { color = "#03A764"
                , normalization = Unit.impact 5.67166e4
                , weighting = Unit.ratio 0.0192
                }
        , ecoscoreData = Nothing
        , scopes = [ Scope.Food ]
        }
    , etfc =
        { trigram = Trigram "etf-c"
        , source =
            { label = "Ecobalyse"
            , url = "https://ecobalyse.beta.gouv.fr/"
            }
        , label = "Écotoxicité de l'eau douce, corrigée"
        , description = "Indicateur d'écotoxicité pour écosystèmes aquatiques d'eau douce. Cet indicateur se mesure en Comparative Toxic Unit for ecosystems (CTUe). Cet indicateur est corrigé."
        , unit = "CTUe"
        , decimals = 2
        , quality = NotFinished
        , pefData = Nothing
        , ecoscoreData =
            Just
                { color = "#375622"
                , normalization = Unit.impact 5.67166e4
                , weighting = Unit.ratio 0.0407
                }
        , scopes = [ Scope.Food ]
        }
    , htc =
        { trigram = Trigram "htc"
        , source =
            { label = "Agribalyse"
            , url = "https://agribalyse.ademe.fr/"
            }
        , label = "Toxicité humaine - cancer"
        , description = "Indicateur de toxicité cancérigène pour l'homme. Cet indicateur se mesure en Comparative Toxic Unit for humans (CTUh)"
        , unit = "CTUh"
        , decimals = 2
        , quality = NotFinished
        , pefData =
            Just
                { color = "#ffff00"
                , normalization = Unit.impact 1.72529e-5
                , weighting = Unit.ratio 0.0213
                }
        , ecoscoreData = Nothing
        , scopes = [ Scope.Food ]
        }
    , htcc =
        { trigram = Trigram "htc-c"
        , source =
            { label = "Ecobalyse"
            , url = "https://ecobalyse.beta.gouv.fr/"
            }
        , label = "Toxicité humaine - cancer, corrigée"
        , description = "Indicateur de toxicité cancérigène pour l'homme. Cet indicateur se mesure en Comparative Toxic Unit for humans (CTUh). Cet indicateur est corrigé."
        , unit = "CTUh"
        , decimals = 2
        , quality = NotFinished
        , pefData = Nothing
        , ecoscoreData =
            Just
                { color = "#f4b183"
                , normalization = Unit.impact 1.72529e-5
                , weighting = Unit.ratio 0.0452
                }
        , scopes = [ Scope.Food ]
        }
    , htn =
        { trigram = Trigram "htn"
        , source =
            { label = "Agribalyse"
            , url = "https://agribalyse.ademe.fr/"
            }
        , label = "Toxicité humaine - non-cancer"
        , description = "Indicateur de toxicité non cancérigène pour l'homme. Cet indicateur se mesure en Comparative Toxic Unit for humans (CTUh)"
        , unit = "CTUh"
        , decimals = 2
        , quality = NotFinished
        , pefData =
            Just
                { color = "#FFA907"
                , normalization = Unit.impact 1.28736e-4
                , weighting = Unit.ratio 0.0184
                }
        , ecoscoreData = Nothing
        , scopes = [ Scope.Food ]
        }
    , htnc =
        { trigram = Trigram "htn-c"
        , source =
            { label = "Ecobalyse"
            , url = "https://ecobalyse.beta.gouv.fr/"
            }
        , label = "Toxicité humaine - non-cancer, corrigée"
        , description = "Indicateur de toxicité non cancérigène pour l'homme. Cet indicateur se mesure en Comparative Toxic Unit for humans (CTUh). Cet indicateur est corrigé."
        , unit = "CTUh"
        , decimals = 2
        , quality = NotFinished
        , pefData = Nothing
        , ecoscoreData =
            Just
                { color = "#43682b"
                , normalization = Unit.impact 1.28736e-4
                , weighting = Unit.ratio 0.039
                }
        , scopes = [ Scope.Food ]
        }
    , bvi =
        { trigram = Trigram "bvi"
        , source =
            { label = "Valuing Biodiversity in Life Cycle Impact Assessment, Lindner et al 2019"
            , url = "https://www.researchgate.net/publication/336523544_Valuing_Biodiversity_in_Life_Cycle_Impact_Assessment"
            }
        , label = "Biodiversité locale"
        , unit = "BVI"
        , decimals = 2
        , description = "Indicateur de l'impact sur la biodiversité calculé à partir de la méthode BVI (Biodiversity Value Increment), Lindner et al 2019"
        , quality = BadQuality
        , pefData = Nothing
        , ecoscoreData =
            Just
                { color = "#00b050"
                , normalization = Unit.impact 1.6773e4
                , weighting = Unit.ratio 0.125
                }
        , scopes = [ Scope.Food ]
        }
    }
