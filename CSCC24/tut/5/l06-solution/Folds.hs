module Folds where

{-
"filter pred lst" selects the list items that satisfy the predicate. It can
be implemented as:

filter pred [] = []
filter pred (x:xs) = if pred x then x : filter pred xs
                               else filter pred xs

E.g., filter (\x -> x > 0) [1, -2, 3] = [1, 3]

filter is in the standard library, if you want to try it.

Write a new version that uses foldr to replace the recursion.

Note: Please stick the the given format. More details below.

Note 2: The list parameter is deliberately absent. This is legal. Also you
absolutely don't need it.
-}

-- Please don't change the following 3 lines.
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter pred = foldr op z
  where
-- Please don't change the 3 lines above.
-- Below, changing the format is OK, e.g., "op x r = ...", or using guards.
    z = []
    op x r = if pred x then x : r else r


{-
Make BoolX below an instance of Semigroup and Monoid. The <> operator should do
logical xor. mempty should be the corresponding identity element.
-}

data BoolX = MkBoolX Bool deriving (Eq, Show)

instance Semigroup BoolX where
    (<>) :: BoolX -> BoolX -> BoolX
    MkBoolX False <> b = b
    MkBoolX True <> MkBoolX c = MkBoolX (not c)

instance Monoid BoolX where
    mempty :: BoolX
    mempty = MkBoolX False

{-
In Data.Semigroup, you can find similar wrapper types:
All wraps Bool and makes <> do logical-and
Any wraps Bool and makes <> do logical-or
Sum wraps a Num instance and makes <> do addition
Product wraps a Num instance and makes <> do multiplication
-}
