{-
How to use: runghc testMerge.hs
-}

import TestLib
import qualified Basic

-- Re-assert desired type.
merge :: [Integer] -> [Integer] -> [Integer]
merge = Basic.merge

tests = [ "handout" ~: merge [2, 3, 5] [1, 3, 4, 4, 7] ~?= [1, 2, 3, 3, 4, 4, 5, 7]
        ]

main = testlibMain tests
