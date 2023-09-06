module Page.Textile.Simulator.ViewMode exposing
    ( ViewMode(..)
    , toggle
    )


type ViewMode
    = DetailedStep Int
    | Simple


toggle : Int -> ViewMode -> ViewMode
toggle index viewMode =
    case viewMode of
        DetailedStep current ->
            if index == current then
                Simple

            else
                DetailedStep index

        Simple ->
            DetailedStep index
