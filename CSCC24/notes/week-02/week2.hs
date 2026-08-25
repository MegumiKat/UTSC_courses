module HaskellTypes1 where

import Data.Char (ord)

-- Copied from previous lecture, so you can try atFourPlusAtSeven (diffSq 10) below
diffSq :: Integer -> Integer -> Integer
diffSq x y = (x - y) * (x + y)

atFourPlusAtSeven :: (Integer -> Integer) -> Integer
atFourPlusAtSeven f = f 4 + f 7
-- Sample usages:
-- atFourPlusAtSeven (\x -> x*2)
-- atFourPlusAtSeven (diffSq 10)
-- atFourPlusAtSeven (\x -> diffSq x 2)


appendIntegers :: [Integer] -> [Integer] -> [Integer]
appendIntegers [] ys = ys
appendIntegers (x:xt) ys = x : appendIntegers xt ys

append :: [a] -> [a] -> [a]
append [] ys = ys
append (x:xt) ys = x : append xt ys


xyx :: a -> a -> [a]
xyx x y = [x, y, x]

insertionSort :: (a -> a -> Bool) -> [a] -> [a]
insertionSort _ [] = []
insertionSort leq (x:xt) = insert x (insertionSort leq xt)
  where
    -- insert e xs = assuming xs is already sorted, insert e at "the right place"
    insert e [] = [e]
    insert e xs@(x:xt)
        | leq e x = e : xs
        | otherwise = x : insert e xt

exampleInsertionSort = insertionSort (<=) [3,1,4]


data Tetrastratan
    = Monarch
    | Lord String String Integer
    | Knight String
    | Peasant String
    deriving (Eq, Show)

-- Examples making Tetrastratan values.

theOneAndOnly,  edmondDantès :: Tetrastratan
theOneAndOnly = Monarch
edmondDantès = Lord "Count" "Monte Cristo" 1

mkDuke :: String -> Integer -> Tetrastratan
mkDuke terr n = Lord "Duke" terr n
-- Can also be cute, partial application:
-- mkDuke = Lord "Duke"

-- Pattern-matching example: How to address a Tetrastratan:
addressTetra :: Tetrastratan -> String
addressTetra Monarch = "H.M. The Monarch"
addressTetra (Lord d t i) = "The " ++ show i ++ "th " ++ d ++ " of " ++ t
addressTetra (Knight n) = "Sir/Dame " ++ n
addressTetra (Peasant n) = n

-- Pattern-matching example: Social order:
superior :: Tetrastratan -> Tetrastratan -> Bool
superior Monarch (Lord _ _ _) = True
superior Monarch (Knight _) = True
superior Monarch (Peasant _) = True
superior (Lord _ _ _) (Knight _) = True
superior (Lord _ _ _) (Peasant _) = True
superior (Knight _) (Peasant _) = True
superior _ _ = False


data MyIntegerList = INil | ICons Integer MyIntegerList
    deriving (Show, Eq)

exampleMyIntegerList = ICons 4 (ICons (-10) INil)

-- `from0to n` builds a MyIntegerList from 0 to n-1
from0to :: Integer -> MyIntegerList
from0to n = make 0
  where
    make i | i >= n = INil
           | otherwise = ICons i (make (i+1))

myISum :: MyIntegerList -> Integer
myISum INil = 0
myISum (ICons x xs) = x + myISum xs


data IntegerBST = IEmpty | INode IntegerBST Integer IntegerBST
    deriving Show

exampleIntegerBST = INode (INode IEmpty 3 IEmpty) 7 (INode IEmpty 10 IEmpty)

ibstInsert :: Integer -> IntegerBST -> IntegerBST
ibstInsert k IEmpty =
    -- Base case: empty tree plus k = singleton tree with k
    INode IEmpty k IEmpty

ibstInsert k inp@(INode left key right)
    -- Induction step: The input tree has the form INode left key right.
    -- Induction hypothesis (strong induction):
    --   If t is a smaller tree than the input tree, e.g., t=left or t=right,
    --   then ibstInsert k t computes t plus k.
    -- Can you use this to help compute inp plus k?

    -- If k<key, the correct answer is a node consisting of:
    -- new left child = left plus k = ibstInsert k left (by IH)
    -- new key = key
    -- new right child = right

    | k < key = INode (ibstInsert k left) key right

    -- If k>key, mirror image of the above.

    | k > key = INode left key (ibstInsert k right)

    -- If k==key, nothing new to compute, the correct answer is the input tree.
    | otherwise = inp   -- INode left key right


data MyList a = Nil | Cons a (MyList a) deriving (Eq, Show)

exampleMyListI :: MyList Integer
exampleMyListI = Cons 4 (Cons (-10) Nil)

exampleMyListS :: MyList String
exampleMyListS = Cons "albert" (Cons "bart" Nil)

myRev :: MyList a -> MyList a
myRev xs = myRevHelper xs Nil

myRevHelper Nil acc = acc
myRevHelper (Cons x xt) acc = myRevHelper xt (Cons x acc)


data BST a = Empty | Node (BST a) a (BST a)
    deriving Show

exampleBSTChar :: BST Char
exampleBSTChar = Node (Node Empty 'c' Empty) 'g' (Node Empty 'j' Empty)

bstInsert :: Ord a => a -> BST a -> BST a
-- "Ord a =>" to be explained later under Type Classes. For now it means I can
-- do "<", "<=" comparisons.
bstInsert k Empty = Node Empty k Empty
bstInsert k inp@(Node left key right)
    | k < key = Node (bstInsert k left) key right
    | k > key = Node left key (bstInsert k right)
    | otherwise = inp