{-
How to use: runghc testMergeSort.hs
-}

import TestLib
import qualified Basic

-- Re-assert desired type.
mergeSort :: ([Integer] -> ([Integer], [Integer]))
          -> ([Integer] -> [Integer] -> [Integer])
          -> [Integer] -> [Integer]
mergeSort = Basic.mergeSort

tests = [ "handout" ~:
          mergeSort Basic.split Basic.merge [13,17,18,20,15,13,14,15,19,20] ~?=
          [13,13,14,15,15,17,18,19,20,20]
        ]

main = testlibMain tests
