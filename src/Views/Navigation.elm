module Views.Navigation exposing
    ( ActivePage(..)
    , MenuLink(..)
    )

import Data.Sector exposing (GenericSector)
import Html exposing (Html)
import Route


type ActivePage
    = Api
    | Auth
    | Editorial String
    | Explore
    | Food
    | Generic GenericSector
    | Home
    | Other
    | Stats
    | TextileSimulator


type MenuLink msg
    = External String String
    | Internal (List (Html msg)) Route.Route ActivePage
    | MailTo String String
    | SectorMenu
