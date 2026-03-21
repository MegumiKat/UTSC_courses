-- How to use: runghc testInfSet.hs

import TestLib

import InfSetDef
import qualified InfSet as S

-- Re-assert polymorphic types.
union :: Ord a => [a] -> [a] -> [a]
union = S.union
setBinOp :: (Ord a, Ord b, Ord c) => (a -> b -> c) -> [a] -> [b] -> [c]
setBinOp = S.setBinOp

testUnion =
    [ "finite union" ~: union [3,6,9] [2,4,6,8] ~?= [2,3,4,6,8,9]
    , "infinite union" ~:
      take 10 (union [3, 6..] [4, 8..]) ~?= [3,4,6,8,9,12,15,16,18,20]
    ]

powers2 = iterate (* 2) 1
powers3 = iterate (* 3) 1

testBinOp =
    [ "finite setBinOp" ~:
      setBinOp (*) [1,2,4] [1,3,9] ~?= [1,2,3,4,6,9,12,18,36]
    , "infinite setBinOp" ~:
      take 20 (setBinOp (*) powers2 powers3) ~?=
      [1,2,3,4,6,8,9,12,16,18,24,27,32,36,48,54,64,72,81,96]
    ]

testTree =
    [ "B L (B L L)" ~:
      S.branch S.leaf (S.branch S.leaf S.leaf) ~?= S 3 (B L (B L L))
    ]

testAllSizedTrees =
    [ "allSizedTrees" ~:
      take 9 S.allSizedTrees
      ~?=
      [S 1 L,
       S 2 (B L L),
       S 3 (B L (B L L)), S 3 (B (B L L) L),
       S 4 (B L (B L (B L L))), S 4 (B L (B (B L L) L)),
       S 4 (B (B L L) (B L L)), S 4 (B (B L (B L L)) L),S 4 (B (B (B L L) L) L)]
    ]

tests = map Group [testUnion, testBinOp, testTree, testAllSizedTrees]

main = testlibMain tests
