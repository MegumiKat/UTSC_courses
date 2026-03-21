{-
How to use: runghc testMerge.hs
-}

import TestLib
import Basic qualified

-- Re-assert desired type.
merge :: [Integer] -> [Integer] -> [Integer]
merge = Basic.merge

tests =
    [ "merge empty AB" ~: merge [] [] ~?= []
      ~&&
      "merge empty A" ~: merge [] [2,5,8] ~?= [2,5,8]
      ~&&
      "merge empty B" ~: merge [2,5,9] [] ~?= [2,5,9]
    , "merge singleton A" ~: merge [8] [1,5,10] ~?= [1,5,8,10]
      ~&&
      "merge singleton B" ~: merge [1,5,10] [8] ~?= [1,5,8,10]
    , "merge longer" ~:
      merge [1, 3, 3, 4, 7] [2, 3, 5, 8] ~?= [1, 2, 3, 3, 3, 4, 5, 7, 8]
    ]

main = testlibMain tests
