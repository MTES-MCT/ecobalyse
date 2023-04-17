module Data.Food.Ingredient.Category exposing
    ( Category(..)
    , decode
    , isFromAnimalOrigin
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Category
    = AnimalProduct
    | DairyProduct
    | GrainRaw
    | GrainProcessed
    | Misc
    | NutOilseedRaw
    | NutOilseedProcessed
    | SpiceCondimentOrAdditive
    | VegetableFresh
    | VegetableProcessed


fromString : String -> Result String Category
fromString str =
    case str of
        "animal_product" ->
            Ok AnimalProduct

        "dairy_product" ->
            Ok DairyProduct

        "grain_raw" ->
            Ok GrainRaw

        "grain_processed" ->
            Ok GrainProcessed

        "nut_oilseed_raw" ->
            Ok NutOilseedRaw

        "nut_oilseed_processed" ->
            Ok NutOilseedProcessed

        "misc" ->
            Ok Misc

        "spice_condiment_additive" ->
            Ok SpiceCondimentOrAdditive

        "vegetable_fresh" ->
            Ok VegetableFresh

        "vegetable_processed" ->
            Ok VegetableProcessed

        _ ->
            Err <| "Categorie d'ingrédient invalide : " ++ str


isFromAnimalOrigin : Category -> Bool
isFromAnimalOrigin category =
    category == AnimalProduct || category == DairyProduct


toLabel : Category -> String
toLabel category =
    case category of
        AnimalProduct ->
            "Ingrédients animaux viandes, œufs, poissons, et dérivés"

        DairyProduct ->
            "Lait et ingrédients laitiers"

        GrainRaw ->
            "Céréales brutes"

        GrainProcessed ->
            "Céréales transformées"

        NutOilseedRaw ->
            "Fruits à coque et oléoprotéagineux bruts"

        NutOilseedProcessed ->
            "Graisses végétales et oléoprotéagineux transformés"

        Misc ->
            "Divers"

        SpiceCondimentOrAdditive ->
            "Condiments, épices, additifs"

        VegetableFresh ->
            "Fruits et légumes frais"

        VegetableProcessed ->
            "Fruits et légumes transformés"


toString : Category -> String
toString category =
    case category of
        AnimalProduct ->
            "animal_product"

        DairyProduct ->
            "dairy_product"

        GrainRaw ->
            "grain_raw"

        GrainProcessed ->
            "grain_processed"

        NutOilseedRaw ->
            "nut_oilseed_raw"

        NutOilseedProcessed ->
            "nut_oilseed_processed"

        Misc ->
            "misc"

        SpiceCondimentOrAdditive ->
            "spice_condiment_additive"

        VegetableFresh ->
            "vegetable_fresh"

        VegetableProcessed ->
            "vegetable_processed"


decode : Decoder Category
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)
