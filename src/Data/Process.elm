module Data.Process exposing (..)

import Csv.Decode as Csv
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Process =
    { cat1 : Cat1
    , cat2 : Cat2
    , cat3 : Cat3
    , name : String
    , uuid : Uuid
    , climateChange : Float -- kgCO2e per kg of material to process
    , heat : Energy -- MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process
    , waste : Mass -- kg of textile wasted per kg of material to process
    }


type Uuid
    = Uuid String


type Cat1
    = --Energie
      Energy
      --Textile
    | Textile
      --Transport
    | Transport


type Cat2
    = -- "Aérien"
      AirTransport
      -- "Chaleur"
    | Heat
      -- "Electricité"
    | Electricity
      -- "Ennoblissement"
    | Ennoblement
      -- "Maritime"
    | SeaTransport
      -- "Matières"
    | Material
      -- "Mise en forme"
    | Processing
      -- "Routier"
    | RoadTransport


type Cat3
    = -- Mix moyen
      AverageMix
      -- Valeur par énergie primaire
    | PrimaryEnergyValue
      -- Matières naturelles
    | NaturalMaterials
      -- Matières synthétiques
    | SyntheticMaterials
      -- Matières recyclées
    | RecycledMaterials
      -- Tricotage
    | Knitting
      -- Tissage
    | Weaving
      -- Teinture
    | Dyeing
      -- Confection
    | Making
      -- Flotte moyenne
    | AverageFleet
      -- Flotte moyenne continentale
    | AverageContinentalFleet
      -- Flotte moyenne française
    | AverageFrenchFleet


decodeFrenchFloat : Csv.Decoder Float
decodeFrenchFloat =
    Csv.string
        |> Csv.andThen
            (String.replace "," "."
                >> String.toFloat
                >> Csv.fromMaybe "Impossible de décoder ce nombre flottant"
            )


decodeProcess : Csv.Decoder Process
decodeProcess =
    Csv.into Process
        |> Csv.pipeline (Csv.field "Catégorie (niveau 1)" (Csv.string |> Csv.andThen (cat1FromString >> Csv.fromResult)))
        |> Csv.pipeline (Csv.field "Catégorie (niveau 2)" (Csv.string |> Csv.andThen (cat2FromString >> Csv.fromResult)))
        |> Csv.pipeline (Csv.field "Catégorie (niveau 3)" (Csv.string |> Csv.andThen (cat3FromString >> Csv.fromResult)))
        |> Csv.pipeline (Csv.field "Procédé" Csv.string)
        |> Csv.pipeline (Csv.field "UUID" (Csv.map Uuid Csv.string))
        |> Csv.pipeline (Csv.field "Changement climatique" decodeFrenchFloat)
        |> Csv.pipeline (Csv.field "heat" (decodeFrenchFloat |> Csv.andThen (Energy.megajoules >> Csv.succeed)))
        |> Csv.pipeline (Csv.field "electricity per pick per meter" decodeFrenchFloat)
        |> Csv.pipeline (Csv.field "electricity" (decodeFrenchFloat |> Csv.andThen (Energy.megajoules >> Csv.succeed)))
        |> Csv.pipeline (Csv.field "textile waste" (decodeFrenchFloat |> Csv.andThen (Mass.kilograms >> Csv.succeed)))


noOp : Process
noOp =
    { cat1 = Textile
    , cat2 = Material
    , cat3 = NaturalMaterials
    , name = "void"
    , uuid = Uuid ""
    , climateChange = 0
    , heat = Energy.megajoules 0
    , elec_pppm = 0
    , elec = Energy.megajoules 0
    , waste = Mass.kilograms 0
    }


decodeCsv : String -> Result Csv.Error (List Process)
decodeCsv =
    Csv.decodeCustom
        { fieldSeparator = ';' }
        Csv.FieldNamesFromFirstRow
        decodeProcess


findByUuid : Uuid -> Process
findByUuid uuid =
    processes |> List.filter (.uuid >> (==) uuid) |> List.head |> Maybe.withDefault noOp


findByName : String -> Process
findByName name =
    processes |> List.filter (.name >> (==) name) |> List.head |> Maybe.withDefault noOp


airTransport : Process
airTransport =
    findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"


seaTransport : Process
seaTransport =
    findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"


roadTransportPreMaking : Process
roadTransportPreMaking =
    findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"


roadTransportPostMaking : Process
roadTransportPostMaking =
    findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"


distribution : Process
distribution =
    findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"


dyeingHigh : Process
dyeingHigh =
    findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"


dyeingLow : Process
dyeingLow =
    findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"


cat1 : Cat1 -> List Process -> List Process
cat1 c1 =
    List.filter (.cat1 >> (==) c1)


cat2 : Cat2 -> List Process -> List Process
cat2 c2 =
    List.filter (.cat2 >> (==) c2)


cat3 : Cat3 -> List Process -> List Process
cat3 c3 =
    List.filter (.cat3 >> (==) c3)


cat1FromString : String -> Result String Cat1
cat1FromString c1 =
    case c1 of
        "Energie" ->
            Ok Energy

        "Textile" ->
            Ok Textile

        "Transport" ->
            Ok Transport

        _ ->
            Err <| "Catégorie 1 invalide: " ++ c1


cat1ToString : Cat1 -> String
cat1ToString c1 =
    case c1 of
        Energy ->
            "Energie"

        Textile ->
            "Textile"

        Transport ->
            "Transport"


cat2FromString : String -> Result String Cat2
cat2FromString c2 =
    case c2 of
        "Aérien" ->
            Ok AirTransport

        "Chaleur" ->
            Ok Heat

        "Electricité" ->
            Ok Electricity

        "Ennoblissement" ->
            Ok Ennoblement

        "Maritime" ->
            Ok SeaTransport

        "Matières" ->
            Ok Material

        "Mise en forme" ->
            Ok Processing

        "Routier" ->
            Ok RoadTransport

        _ ->
            Err <| "Catégorie 2 invalide: " ++ c2


cat2ToString : Cat2 -> String
cat2ToString c2 =
    case c2 of
        AirTransport ->
            "Aérien"

        Heat ->
            "Chaleur"

        Electricity ->
            "Electricité"

        Ennoblement ->
            "Ennoblissement"

        SeaTransport ->
            "Maritime"

        Material ->
            "Matières"

        Processing ->
            "Mise en forme"

        RoadTransport ->
            "Routier"


cat3FromString : String -> Result String Cat3
cat3FromString c3 =
    case c3 of
        "Mix moyen" ->
            Ok AverageMix

        "Valeur par énergie primaire" ->
            Ok PrimaryEnergyValue

        "Matières naturelles" ->
            Ok NaturalMaterials

        "Matières synthétiques" ->
            Ok SyntheticMaterials

        "Matières recyclées" ->
            Ok RecycledMaterials

        "Tricotage" ->
            Ok Knitting

        "Tissage" ->
            Ok Weaving

        "Teinture" ->
            Ok Dyeing

        "Confection" ->
            Ok Making

        "Flotte moyenne" ->
            Ok AverageFleet

        "Flotte moyenne continentale" ->
            Ok AverageContinentalFleet

        "Flotte moyenne française" ->
            Ok AverageFrenchFleet

        _ ->
            Err <| "Catégorie 3 invalide: " ++ c3


cat3ToString : Cat3 -> String
cat3ToString c3 =
    case c3 of
        AverageMix ->
            "Mix moyen"

        PrimaryEnergyValue ->
            "Valeur par énergie primaire"

        NaturalMaterials ->
            "Matières naturelles"

        SyntheticMaterials ->
            "Matières synthétiques"

        RecycledMaterials ->
            "Matières recyclées"

        Knitting ->
            "Tricotage"

        Weaving ->
            "Tissage"

        Dyeing ->
            "Teinture"

        Making ->
            "Confection"

        AverageFleet ->
            "Flotte moyenne"

        AverageContinentalFleet ->
            "Flotte moyenne continentale"

        AverageFrenchFleet ->
            "Flotte moyenne française"


processes : List Process
processes =
    -- In a first iteration, processes data will statically live in memory; later on, we'll load them over HTTP.
    case decodeCsv csvSource of
        Ok decoded ->
            decoded

        Err _ ->
            []


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


csvSource : String
csvSource =
    """Catégorie (niveau 1);Catégorie (niveau 2);Catégorie (niveau 3);Procédé;UUID avec espaces;UUID;Changement climatique;heat;electricity per pick per meter;electricity;textile waste
Energie;Electricité;Mix moyen;Mix électrique réseau, TR;6fad8643-de3e-49dd-a48b-8e17b4175c23;6fad8643-de3e-49dd-a48b-8e17b4175c23;0,706988;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, TN;f0eb64cd-468d-4f3c-a9a3-3b3661625955;f0eb64cd-468d-4f3c-a9a3-3b3661625955;0,80722;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, IN;1b470f5c-6ae6-404d-bd71-8546d33dbc17;1b470f5c-6ae6-404d-bd71-8546d33dbc17;1,58299;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, FR;05585055-9742-4fff-81ff-ad2e30e1b791;05585055-9742-4fff-81ff-ad2e30e1b791;0,0813225;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, CN;8f923f3d-0bd2-4326-99e2-f984b4454226;8f923f3d-0bd2-4326-99e2-f984b4454226;1,05738;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, ES;37301c44-c4cf-4214-a4ac-eee5785ccdc5;37301c44-c4cf-4214-a4ac-eee5785ccdc5;0,467803;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, PT;a1d83202-0052-4d10-b9d2-938564be6a0b;a1d83202-0052-4d10-b9d2-938564be6a0b;0,571172;0;0;0;0
Energie;Electricité;Mix moyen;Mix électrique réseau, BD;1ee6061e-8e15-4558-9338-94ad87abf932;1ee6061e-8e15-4558-9338-94ad87abf932;0,795168;0;0;0;0
Energie;Chaleur;Mix moyen;Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA;2e8de6f6-0ea1-455b-adce-ea74d307d222;2e8de6f6-0ea1-455b-adce-ea74d307d222;0,106827;0;0;0;0
Energie;Chaleur;Mix moyen;Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), RER;59c4c64c-0916-868a-5dd6-a42c4c42222f;59c4c64c-0916-868a-5dd6-a42c4c42222f;0,0744719;0;0;0;0
Energie;Chaleur;Mix moyen;Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR;12fc43f2-a007-423b-a619-619d725793ea;12fc43f2-a007-423b-a619-619d725793ea;0,0854514;0;0;0;0
Energie;Chaleur;Valeur par énergie primaire;Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES;618440a9-f4aa-65bc-21cb-ea40eee53f3d;618440a9-f4aa-65bc-21cb-ea40eee53f3d;0,0830517;0;0;0;0
Textile;Matières;Matières naturelles;Plume de canard, inventaire agrégé;d1f06ea5-d63f-453a-8f98-55ce78ae7579;d1f06ea5-d63f-453a-8f98-55ce78ae7579;16,238;0;0;0;0
Textile;Matières;Matières naturelles;Fil de soie;94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68;94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68;18,5727;0;0;0;7,79322
Textile;Matières;Matières naturelles;Fil de lin (filasse);e5a6d538-f932-4242-98b4-3a0c6439629c;e5a6d538-f932-4242-98b4-3a0c6439629c;16,7281;0;0;0;0,170215
Textile;Matières;Matières naturelles;Fil de lin (étoupe);fcef1a31-bb18-49e4-bdb6-e53dfe015ba0;fcef1a31-bb18-49e4-bdb6-e53dfe015ba0;15,1829;0;0;0;0,288932
Textile;Matières;Matières naturelles;Fil de laine de mouton Mérinos, inventaire partiellement agrégé;4e035dbf-f48b-4b5a-94ea-0006c713958b;4e035dbf-f48b-4b5a-94ea-0006c713958b;73,8467;0;0;0;0,08696
Textile;Matières;Matières naturelles;Fil de laine de mouton;376bd165-d354-41aa-a6e3-fd3228413bb2;376bd165-d354-41aa-a6e3-fd3228413bb2;80,2769;0;0;0;0,672241
Textile;Matières;Matières naturelles;Fil de laine de chameau;c191a4dd-5080-4eb6-9c59-b13c943327bc;c191a4dd-5080-4eb6-9c59-b13c943327bc;175,102;0;0;0;3,17851
Textile;Matières;Matières naturelles;Fil de jute;72010874-4d26-4c7a-95de-c6987dfdedeb;72010874-4d26-4c7a-95de-c6987dfdedeb;12,9611;0;0;0;0,270519
Textile;Matières;Matières naturelles;Fil de coton conventionnel, inventaire partiellement agrégé;f211bbdb-415c-46fd-be4d-ddf199575b44;f211bbdb-415c-46fd-be4d-ddf199575b44;16,3699;0;0;0;0,201201
Textile;Matières;Matières naturelles;Fil de chanvre;08601439-f338-4f94-ac8c-538061b65d16;08601439-f338-4f94-ac8c-538061b65d16;19,5483;0;0;0;0,221094
Textile;Matières;Matières naturelles;Fil de cachemire;380c0d9c-2840-4390-bd3f-5c960f26f5ed;380c0d9c-2840-4390-bd3f-5c960f26f5ed;385,476;0;0;0;3,17851
Textile;Matières;Matières naturelles;Fil d'angora;29bddef1-d753-45af-9ca6-aec05e2d02b9;29bddef1-d753-45af-9ca6-aec05e2d02b9;45,1782;0;0;0;0,672241
Textile;Matières;Matières naturelles;Fibres de kapok, inventaire agrégé;36cdbfc4-3f48-47b0-8ae0-294bb6017df1;36cdbfc4-3f48-47b0-8ae0-294bb6017df1;-0,0280245;0;0;0;0
Textile;Matières;Matières synthétiques;Filament de viscose;81a67d97-3cd9-44ef-9ee2-159364364c0f;81a67d97-3cd9-44ef-9ee2-159364364c0f;7,99002;0;0;0;0,0582011
Textile;Matières;Matières synthétiques;Filament de polyuréthane;c3738500-0a62-4b95-b4a2-b7beb12a9e1a;c3738500-0a62-4b95-b4a2-b7beb12a9e1a;20,6809;0;0;0;0,00796392
Textile;Matières;Matières synthétiques;Filament de polytriméthylène téréphtalate (PTT), inventaire partiellement agrégé;eca33573-0d09-4d79-9b28-da42bfcc7a4b;eca33573-0d09-4d79-9b28-da42bfcc7a4b;12,0842;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament de polytéréphtalate de butylène (PBT), inventaire agrégé;7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc;7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc;10,1195;0;0;0;0
Textile;Matières;Matières synthétiques;Filament de polypropylène;a30cfbde-393a-40db-9263-ea00bfced0b7;a30cfbde-393a-40db-9263-ea00bfced0b7;6,91894;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament de polylactide;f2dd799d-1b69-4e7a-99bd-696bbbd5a978;f2dd799d-1b69-4e7a-99bd-696bbbd5a978;9,35683;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament de polyéthylène;088ed617-67fa-4d42-b3af-ee6cf39cf36f;088ed617-67fa-4d42-b3af-ee6cf39cf36f;6,91078;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament de polyester, inventaire partiellement agrégé;4d57c51d-7d56-46e1-acde-02fbcdc943e4;4d57c51d-7d56-46e1-acde-02fbcdc943e4;10,2505;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament de polyamide 66;182fa424-1f49-4728-b0f1-cb4e4ab36392;182fa424-1f49-4728-b0f1-cb4e4ab36392;13,6468;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Filament d'aramide;7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5;7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5;22,3103;0;0;0;0
Textile;Matières;Matières synthétiques;Filament d'acrylique;aee6709f-0864-4fc5-8760-68cb644a0021;aee6709f-0864-4fc5-8760-68cb644a0021;18,4288;0;0;0;0,00796392
Textile;Matières;Matières synthétiques;Filament bi-composant polypropylène/polyamide;37396ac4-13a2-484c-9cc6-5b5a93ff6e6e;37396ac4-13a2-484c-9cc6-5b5a93ff6e6e;8,26356;0;0;0;0,0319569
Textile;Matières;Matières synthétiques;Feuille de néoprène, inventaire agrégé;76fefff3-3781-49a2-8deb-c12945a6b71f;76fefff3-3781-49a2-8deb-c12945a6b71f;9,87734;0;0;0;0
Textile;Matières;Matières recyclées;Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation, inventaire partiellement agrégé;4072bfa2-1948-4d12-8de9-bbeb6cc628e1;4072bfa2-1948-4d12-8de9-bbeb6cc628e1;6,58922;0;0;0;0,031957
Textile;Matières;Matières recyclées;Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation, inventaire partiellement agrégé;e65e8157-9bd1-4711-9571-8e4a22c2d2b5;e65e8157-9bd1-4711-9571-8e4a22c2d2b5;22,3377;0;0;0;0,032
Textile;Matières;Matières recyclées;Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation, inventaire partiellement agrégé;221067ba-5c2f-4dad-b09a-dd5af0a9ae31;221067ba-5c2f-4dad-b09a-dd5af0a9ae31;6,99213;0;0;0;0,032
Textile;Matières;Matières recyclées;Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production, inventaire partiellement agrégé;41ee61c2-9a98-4eec-8949-9d9b54289bd0;41ee61c2-9a98-4eec-8949-9d9b54289bd0;8,55458;0;0;0;0,0319681
Textile;Matières;Matières recyclées;Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé;9671ae26-d772-4bb1-aad5-6b826555d0cd;9671ae26-d772-4bb1-aad5-6b826555d0cd;6,46416;0;0;0;0,137851
Textile;Matières;Matières recyclées;Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé;af5d130d-f18b-438c-9f19-d1ee49756960;af5d130d-f18b-438c-9f19-d1ee49756960;5,22649;0;0;0;0,137851
Textile;Matières;Matières recyclées;Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé;92dfabc7-9441-463e-bda8-7bc5943c0e9d;92dfabc7-9441-463e-bda8-7bc5943c0e9d;0,495013;0;0;0;0,1688
Textile;Matières;Matières recyclées;Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation, inventaire partiellement agrégé;4d23093d-1346-4018-8c0f-7aae33c67bcd;4d23093d-1346-4018-8c0f-7aae33c67bcd;1,02499;0;0;0;0,77305
Textile;Matières;Matières recyclées;Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé;2b24abb0-c1ec-4298-9b58-350904a26104;2b24abb0-c1ec-4298-9b58-350904a26104;1,42207;0;0;0;0,323
Textile;Matières;Matières recyclées;Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé;7603beaa-c555-4283-b9f8-4d5d231b8490;7603beaa-c555-4283-b9f8-4d5d231b8490;6,56515;0;0;0;0,137851
Textile;Matières;Matières recyclées;Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique), inventaire partiellement agrégé;ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f;ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f;0,250572;0;0;0;0,21
Textile;Mise en forme;Tricotage;Tricotage;9c478d79-ff6b-45e1-9396-c3bd897faa1d;9c478d79-ff6b-45e1-9396-c3bd897faa1d;0;0;0;8,64;0,0576
Textile;Mise en forme;Tissage;Tissage (habillement);f9686809-f55e-4b96-b1f0-3298959de7d0;f9686809-f55e-4b96-b1f0-3298959de7d0;0;0;0,0003145;0;0,0667
Textile;Ennoblissement;Teinture;Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées;cf001531-5f2d-48b1-b30a-4a17466a8b30;cf001531-5f2d-48b1-b30a-4a17466a8b30;0,420837;71,71;0;38,1;0
Textile;Ennoblissement;Teinture;Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées;fb4bea16-7ce1-43e2-9e03-462250214988;fb4bea16-7ce1-43e2-9e03-462250214988;0,397712;25,87;0;7,17;0
Textile;Mise en forme;Confection;Confection (jeans);1f428a50-73c0-4fc1-ab39-00fd312458ee;1f428a50-73c0-4fc1-ab39-00fd312458ee;0;0;0;9,612;0
Textile;Mise en forme;Confection;Confection (gilet, jupe, pantalon, pull);387059fc-72cb-4a92-b1e7-2ef9242f8380;387059fc-72cb-4a92-b1e7-2ef9242f8380;0;0;0;2,232;0
Textile;Mise en forme;Confection;Confection (débardeur, tee-shirt, combinaison);26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5;26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5;0;0;0;1,8;0
Textile;Mise en forme;Confection;Confection (chemisier, manteau, veste, cape, robe);7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe;7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe;0;0;0;3,204;0
Textile;Mise en forme;Confection;Confection (ceinture, châle, chapeau, sac, écharpe);0a260a3f-260e-4b43-a0df-0cf673fda960;0a260a3f-260e-4b43-a0df-0cf673fda960;0;0;0;1,512;0
Transport;Maritime;Flotte moyenne;Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO;8dc4ce62-ff0f-4680-897f-867c3b31a923;8dc4ce62-ff0f-4680-897f-867c3b31a923;0,0483042;0;0;0;0
Transport;Aérien;Flotte moyenne;Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO;839b263d-5111-4318-9275-7026937e88b2;839b263d-5111-4318-9275-7026937e88b2;1,20941;0;0;0;0
Transport;Routier;Flotte moyenne continentale;Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO;cf6e9d81-358c-4f44-5ab7-0e7a89440576;cf6e9d81-358c-4f44-5ab7-0e7a89440576;0,204544;0;0;0;0
Transport;Routier;Flotte moyenne continentale;Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER;c0397088-6a57-eea7-8950-1d6db2e6bfdb;c0397088-6a57-eea7-8950-1d6db2e6bfdb;0,156105;0;0;0;0
Transport;Routier;Flotte moyenne française;Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR;f49b27fa-f22e-c6e1-ab4b-e9f873e2e648;f49b27fa-f22e-c6e1-ab4b-e9f873e2e648;0,269575;0;0;0;0
"""


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "cat1", v.cat1 |> cat1ToString |> Encode.string )
        , ( "cat2", v.cat2 |> cat2ToString |> Encode.string )
        , ( "cat3", v.cat3 |> cat3ToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "uuid", v.uuid |> uuidToString |> Encode.string )
        , ( "climateChange", Encode.float v.climateChange )
        , ( "heat", v.heat |> Energy.inMegajoules |> Encode.float )
        , ( "elec_pppm", Encode.float v.elec_pppm )
        , ( "elec", v.elec |> Energy.inMegajoules |> Encode.float )
        , ( "waste", v.waste |> Mass.inKilograms |> Encode.float )
        ]


encodeAll : String
encodeAll =
    processes
        |> Encode.list encode
        |> Encode.encode 0
