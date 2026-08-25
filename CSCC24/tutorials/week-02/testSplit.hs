{-
How to use: runghc testSplit.hs
-}

import TestLib
import qualified Basic

-- Re-assert desired type.
split :: [a] -> ([a], [a])
split = Basic.split

tests = [ "handout even" ~: split [3,1,2,9] ~?= ([3,2], [1,9])
        , "handout odd" ~: split [3,1,2,9,7] ~?= ([3,2,7], [1,9])
        , "handout singleton" ~: split [3] ~?= ([3], [])
        ]

main = testlibMain tests
