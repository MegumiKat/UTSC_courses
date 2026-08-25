{-
How to use: runghc testFolds.hs
-}

import Folds (BoolX(..))
import Folds qualified as F (myFilter)
import TestLib

-- Re-assert desired type.
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter = F.myFilter

testFilter =
    [ "myFilter (\\_ -> True) []"
      ~: myFilter (\_ -> True) [] ~?= ([] :: [Int])  -- 1 mark
    , "myFilter (\\_ -> False) ['x', 'y', 'z']"
      ~: myFilter (\_ -> False) ['x', 'y', 'z'] ~?= []  -- 1 mark
    , "myFilter handout" ~: myFilter (\x -> x > 0) [1, -2, 3] ~?= [1, 3]
      ~&&
      "myFilter even [43,14,49,18,12]"
      ~: myFilter even [43,14,49,18,12] ~?= [14,18,12]  -- 1 mark
    ]

testXOR =
    [ "0 xor 0" ~: MkBoolX False <> MkBoolX False ~?= MkBoolX False
    , "0 xor 1" ~: MkBoolX False <> MkBoolX True ~?= MkBoolX True
    , "1 xor 0" ~: MkBoolX True <> MkBoolX False ~?= MkBoolX True
    , "1 xor 1" ~: MkBoolX True <> MkBoolX True ~?= MkBoolX False
    ]
-- 0.5 marks x 4

tests = [Group testFilter, Group testXOR]

main = testlibMain tests
