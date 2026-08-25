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
    [ "myFilter (\\_ -> True) []" ~: myFilter (\_ -> True) [] ~?= ([] :: [Int])
    , "myFilter handout" ~: myFilter (\x -> x > 0) [1, -2, 3] ~?= [1, 3]
    ]

testXOR =
    [ "0 xor 1" ~: MkBoolX False <> MkBoolX True ~?= MkBoolX True
    ]

tests = testFilter ++ testXOR

main = testlibMain tests
