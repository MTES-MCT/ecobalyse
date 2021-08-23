module Data.Material exposing
    ( Material
    , choices
    , cotton
    , decode
    , encode
    , findById
    )

import Data.Material.Category as Category exposing (Category)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { id : String
    , name : String
    , category : Category
    }


choices : List Material
choices =
    [ -- Natural
      { id = "n01", name = "Plume de canard, inventaire agrégé", category = Category.Natural }
    , { id = "n02", name = "Fil de soie", category = Category.Natural }
    , { id = "n03", name = "Fil de lin (filasse)", category = Category.Natural }
    , { id = "n04", name = "Fil de lin (étoupe)", category = Category.Natural }
    , { id = "n05", name = "Fil de laine de mouton Mérinos, inventaire partiellement agrégé", category = Category.Natural }
    , { id = "n06", name = "Fil de laine de mouton", category = Category.Natural }
    , { id = "n07", name = "Fil de laine de chameau", category = Category.Natural }
    , { id = "n08", name = "Fil de jute", category = Category.Natural }
    , cotton
    , { id = "n10", name = "Fil de chanvre", category = Category.Natural }
    , { id = "n11", name = "Fil de cachemire", category = Category.Natural }
    , { id = "n12", name = "Fil d'angora", category = Category.Natural }
    , { id = "n13", name = "Fibres de kapok, inventaire agrégé", category = Category.Natural }

    -- Synthetic
    , { id = "s01", name = "Filament de viscose", category = Category.Synthetic }
    , { id = "s02", name = "Filament de polyuréthane", category = Category.Synthetic }
    , { id = "s03", name = "Filament de polytriméthylène téréphtalate (PTT), inventaire partiellement agrégé", category = Category.Synthetic }
    , { id = "s04", name = "Filament de polytéréphtalate de butylène (PBT), inventaire agrégé", category = Category.Synthetic }
    , { id = "s05", name = "Filament de polypropylène", category = Category.Synthetic }
    , { id = "s06", name = "Filament de polylactide", category = Category.Synthetic }
    , { id = "s07", name = "Filament de polyéthylène", category = Category.Synthetic }
    , { id = "s08", name = "Filament de polyester, inventaire partiellement agrégé", category = Category.Synthetic }
    , { id = "s09", name = "Filament de polyamide 66", category = Category.Synthetic }
    , { id = "s10", name = "Filament d'aramide", category = Category.Synthetic }
    , { id = "s11", name = "Filament d'acrylique", category = Category.Synthetic }
    , { id = "s12", name = "Filament bi-composant polypropylène/polyamide", category = Category.Synthetic }
    , { id = "s13", name = "Feuille de néoprène, inventaire agrégé", category = Category.Synthetic }

    -- Recycled
    , { id = "r01", name = "Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r02", name = "Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r03", name = "Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r04", name = "Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r05", name = "Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r06", name = "Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r07", name = "Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r08", name = "Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r09", name = "Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r10", name = "Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé", category = Category.Recycled }
    , { id = "r11", name = "Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique), inventaire partiellement agrégé", category = Category.Recycled }
    ]


cotton : Material
cotton =
    { id = "n09"
    , name = "Fil de coton conventionnel, inventaire partiellement agrégé"
    , category = Category.Natural
    }


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "category", Category.encode v.category )
        ]


findById : String -> Maybe Material
findById id =
    choices |> List.filter (\m -> m.id == id) |> List.head
