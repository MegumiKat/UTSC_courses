{-
How to use: runghc testSplit.hs
-}

import TestLib
import Basic qualified

-- Re-assert desired type.
split :: [a] -> ([a], [a])
split = Basic.split

tests = [ "split empty" ~: split ([] :: [Bool]) ~?= ([], [])
        , "split singleton" ~: split [4] ~?= ([4], [])
        , "split two" ~: split [5, 3] ~?= ([5], [3])
        , "split longer even" ~:
          split [7, 32, 11, 1, 9, 20] ~?= ([7,11,9], [32,1,20])
        , "split longer odd" ~:
          split [7, 32, 11, 1, 9, 20, 15] ~?= ([7,11,9,15], [32,1,20])
        ]

main = testlibMain tests
