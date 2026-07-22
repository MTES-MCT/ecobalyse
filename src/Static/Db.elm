module Static.Db exposing (fromStaticFiles, fromStaticFilesWithImpactDetails)

import Data.Db as Db exposing (Db)
import Data.Impact as Impact
import Data.Process as Process
import Json.Decode as Decode
import Static.Json as StaticJson


{-| Build a Db from static file strings.

IMPORTANT NOTE: this module should _never_ be imported by the Main module (the Web app), as it imports
all the db JSON strings statically, which bloats the js build for no added value. The intended use of
this function is for Server, Tests and checks CLI commands.

-}
fromStaticFiles : String -> Result String Db
fromStaticFiles processesJson =
    Db.build (staticRawJsonStrings processesJson)


{-| Build a Db from base process metadata and detailed impacts, with id-matching validation.
-}
fromStaticFilesWithImpactDetails : String -> String -> Result String Db
fromStaticFilesWithImpactDetails processesJson impactDetailsJson =
    impactDetailsJson
        |> Decode.decodeString (Process.decodeImpactDetails Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\impactDetails ->
                staticRawJsonStrings processesJson
                    |> Db.buildWithImpactDetails impactDetails
            )


{-| Build a RawJsonStrings record from static json file strings.
-}
staticRawJsonStrings : String -> Db.RawJsonStrings
staticRawJsonStrings processesJson =
    { countries = Db.rawJsonString StaticJson.countriesJson
    , definitions = Db.rawJsonString StaticJson.impactsJson
    , food2Examples = Db.rawJsonString StaticJson.food2ExamplesJson
    , foodIngredients = Db.rawJsonString StaticJson.foodIngredientsJson
    , foodProductExamples = Db.rawJsonString StaticJson.foodProductExamplesJson
    , objectComponents = Db.rawJsonString StaticJson.rawJsonComponents.objectComponents
    , objectExamples = Db.rawJsonString StaticJson.objectExamplesJson
    , processes = Db.rawJsonString processesJson
    , textileComponents = Db.rawJsonString StaticJson.rawJsonComponents.textileComponents
    , textileMaterials = Db.rawJsonString StaticJson.textileMaterialsJson
    , textileProductExamples = Db.rawJsonString StaticJson.textileProductExamplesJson
    , textileProducts = Db.rawJsonString StaticJson.textileProductsJson
    , transports = Db.rawJsonString StaticJson.transportsJson
    , veliComponents = Db.rawJsonString StaticJson.rawJsonComponents.veliComponents
    , veliExamples = Db.rawJsonString StaticJson.veliExamplesJson
    }
