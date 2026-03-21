-- How to use: runghc testRIVS.hs

import RIVSDef
import RIVS
import TestLib

tests = r2 ++ r5l

a, b, c :: R2
a = MkR2 (-9) 4
b = MkR2 6 (-2)
c = MkR2 (-3) 2

r2 =
    [ "R2 zero" ~: zero ~?= MkR2 0 0
    , "R2 plus" ~: plus a b ~?= c
    , "R2 minus" ~: minus c b ~?= a
       ~&&
       "R2 neg" ~: neg b ~?= MkR2 (-6) 2
    , "R2 scale" ~: scale (-0.5) a ~?= MkR2 4.5 (-2)
    , "R2 dot" ~: dot a b ~?= -62
    ]

u, v, w :: R5L
u = MkR5L [0, 6, 0, -9, 3]
v = MkR5L [-6, -8, -7, 9, -7]
w = MkR5L [-6, -2, -7, 0, -4]

r5l =
    [ "R5L zero" ~: zero ~?= MkR5L [0, 0, 0, 0, 0]
    , "R5L plus" ~: plus u v ~?= w
    , "R5L minus" ~: minus w v ~?= u
       ~&&
       "R5L neg" ~: neg v ~?= MkR5L [6, 8, 7, -9, 7]
    , "R5L scale" ~: scale (-0.5) u ~?= MkR5L [0, -3, 0, 4.5, -1.5]
    , "R5L dot" ~: dot u v ~?= -150
    ]

main = testlibMain tests
