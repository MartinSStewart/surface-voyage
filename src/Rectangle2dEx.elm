module Rectangle2dEx exposing (positionAndSize)

import Point2d
import Rectangle2d


positionAndSize point vector =
    Rectangle2d.from point (Point2d.translateBy vector point)
