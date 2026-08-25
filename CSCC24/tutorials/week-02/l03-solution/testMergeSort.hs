{-
How to use: runghc testMergeSort.hs
-}

import TestLib
import Basic qualified

-- Re-assert desired type.
mergeSort :: ([Integer] -> ([Integer], [Integer]))
          -> ([Integer] -> [Integer] -> [Integer])
          -> [Integer] -> [Integer]
mergeSort = Basic.mergeSort

-- A correct pair of split and merge.
split (x1 : x2 : xt) = (x1 : r1 , x2 : r2)
  where
    (r1, r2) = split xt
split xs = (xs, [])
merge [] ys = ys
merge xs [] = xs
merge xs@(x : xt) ys@(y : yt) =
    if x <= y
    then x : merge xt ys
    else y : merge xs yt

tests = [ "mergeSort empty" ~:
          mergeSort split merge [] ~?= []
        , "mergeSort singleton" ~:
          mergeSort split merge [37] ~?= [37]
        , "mergeSort longer" ~:
          mergeSort split merge [72,73,71,79,75,70,70,73,79,79,75,79,78,73] ~?=
          [70,70,71,72,73,73,73,75,75,78,79,79,79,79]
        ]

main = testlibMain tests
