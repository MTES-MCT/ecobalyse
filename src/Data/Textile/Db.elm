module Data.Textile.Db exposing
    ( Db
    , buildFromJson
    )

-- import Data.Food.Ingredient as Ingredient exposing (Ingredient)

import Data.Country as Country exposing (Country)
import Data.Food.Process as FoodProcess
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as TextileProcess
import Data.Textile.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type alias Db =
    { impactDefinitions : Definitions
    , textileProcesses : List TextileProcess.Process
    , countries : List Country
    , textileMaterials : List Material
    , textileProducts : List Product
    , transports : Distances
    , foodProcesses : List FoodProcess.Process
    , textileWellKnown : TextileProcess.WellKnown

    -- , foodIngredients : List Ingredient
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decode json
        |> Result.mapError Decode.errorToString


decode : Decoder Db
decode =
    Decode.field "impacts" Definition.decode
        |> Decode.andThen
            (\definitions ->
                Decode.field "processes" (TextileProcess.decodeList definitions)
                    |> Decode.andThen
                        (\processes ->
                            Decode.map5 (Db definitions processes)
                                (Decode.field "countries" (Country.decodeList processes))
                                (Decode.field "materials" (Material.decodeList processes))
                                (Decode.field "products" (Product.decodeList processes))
                                (Decode.field "transports" Transport.decodeDistances)
                                (Decode.field "foodProcesses" (FoodProcess.decodeList definitions))
                                |> Decode.andThen
                                    (\partiallyLoaded ->
                                        TextileProcess.loadWellKnown processes
                                            |> Result.map partiallyLoaded
                                            |> DE.fromResult
                                    )
                        )
            )
