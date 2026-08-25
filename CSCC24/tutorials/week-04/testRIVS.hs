-- How to use: runghc testRIVS.hs

import RIVSDef
import RIVS
import TestLib

tests = r2 ++ r5l

r2 =
    [ "R2 plus" ~: plus (MkR2 3 1) (MkR2 2 (-5)) ~?= MkR2 5 (-4)
    , "R2 minus" ~: minus (MkR2 5 (-4)) (MkR2 2 (-5)) ~?= MkR2 3 1
    , "R2 scale" ~: scale (-0.5) (MkR2 2 (-4)) ~?= MkR2 (-1) 2
    , "R2 dot" ~: dot (MkR2 7 (-3)) (MkR2 (-2) (-4)) ~?= -2
    ]

u, v, w :: R5L
u = MkR5L [9, 2, 4, 1, 0]
v = MkR5L [-6, -1, 0, 0, 5]
w = MkR5L [3, 1, 4, 1, 5]

r5l =
    [ "R5L plus" ~: plus u v ~?= w
    , "R5L minus" ~: minus w v ~?= u
    , "R5L scale" ~: scale (-0.5) v ~?= MkR5L [3, 0.5, 0, 0, -2.5]
    , "R5L dot" ~: dot u v ~?= -56
    ]

main = testlibMain tests
