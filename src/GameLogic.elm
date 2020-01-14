module GameLogic exposing (..)

import Duration
import Length
import Quantity


playerSpeed =
    Length.meters 0.6 |> Quantity.per (Duration.seconds 1)
