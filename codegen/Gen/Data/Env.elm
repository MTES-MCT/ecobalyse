module Gen.Data.Env exposing (betagouvUrl, contactEmail, gitbookUrl, githubRepository, githubUrl, mattermostUrl, maxMakingWasteRatio, maxMaterials, minMakingWasteRatio, moduleName_, values_)

{-| 
@docs moduleName_, maxMaterials, maxMakingWasteRatio, minMakingWasteRatio, mattermostUrl, githubUrl, githubRepository, gitbookUrl, contactEmail, betagouvUrl, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Data", "Env" ]


{-| maxMaterials: Int -}
maxMaterials : Elm.Expression
maxMaterials =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "maxMaterials"
        , annotation = Just Type.int
        }


{-| maxMakingWasteRatio: Split -}
maxMakingWasteRatio : Elm.Expression
maxMakingWasteRatio =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "maxMakingWasteRatio"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| minMakingWasteRatio: Split -}
minMakingWasteRatio : Elm.Expression
minMakingWasteRatio =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "minMakingWasteRatio"
        , annotation = Just (Type.namedWith [] "Split" [])
        }


{-| mattermostUrl: String -}
mattermostUrl : Elm.Expression
mattermostUrl =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "mattermostUrl"
        , annotation = Just Type.string
        }


{-| githubUrl: String -}
githubUrl : Elm.Expression
githubUrl =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "githubUrl"
        , annotation = Just Type.string
        }


{-| githubRepository: String -}
githubRepository : Elm.Expression
githubRepository =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "githubRepository"
        , annotation = Just Type.string
        }


{-| gitbookUrl: String -}
gitbookUrl : Elm.Expression
gitbookUrl =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "gitbookUrl"
        , annotation = Just Type.string
        }


{-| contactEmail: String -}
contactEmail : Elm.Expression
contactEmail =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "contactEmail"
        , annotation = Just Type.string
        }


{-| betagouvUrl: String -}
betagouvUrl : Elm.Expression
betagouvUrl =
    Elm.value
        { importFrom = [ "Data", "Env" ]
        , name = "betagouvUrl"
        , annotation = Just Type.string
        }


values_ :
    { maxMaterials : Elm.Expression
    , maxMakingWasteRatio : Elm.Expression
    , minMakingWasteRatio : Elm.Expression
    , mattermostUrl : Elm.Expression
    , githubUrl : Elm.Expression
    , githubRepository : Elm.Expression
    , gitbookUrl : Elm.Expression
    , contactEmail : Elm.Expression
    , betagouvUrl : Elm.Expression
    }
values_ =
    { maxMaterials =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "maxMaterials"
            , annotation = Just Type.int
            }
    , maxMakingWasteRatio =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "maxMakingWasteRatio"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , minMakingWasteRatio =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "minMakingWasteRatio"
            , annotation = Just (Type.namedWith [] "Split" [])
            }
    , mattermostUrl =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "mattermostUrl"
            , annotation = Just Type.string
            }
    , githubUrl =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "githubUrl"
            , annotation = Just Type.string
            }
    , githubRepository =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "githubRepository"
            , annotation = Just Type.string
            }
    , gitbookUrl =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "gitbookUrl"
            , annotation = Just Type.string
            }
    , contactEmail =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "contactEmail"
            , annotation = Just Type.string
            }
    , betagouvUrl =
        Elm.value
            { importFrom = [ "Data", "Env" ]
            , name = "betagouvUrl"
            , annotation = Just Type.string
            }
    }