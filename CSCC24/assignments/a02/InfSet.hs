{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use infix" #-}
module InfSet where

import InfSetDef
import Text.XHtml (td)

union :: Ord a => [a] -> [a] -> [a]
union xs [] = xs
union [] ys = ys
union xs@(x : xt) ys@(y : yt) 
    | x > y = y : union xs yt
    | x < y = x : union xt ys
    | otherwise = x : union xt yt

delete :: Ord a => [a] -> [a]
delete [] = []
delete (x : xt)
    | x `notElem` xt = x : delete xt
    | otherwise = delete xt

setBinOp :: (Ord a, Ord b, Ord c) => (a -> b -> c) -> [a] -> [b] -> [c]
setBinOp _ [] _ = []
setBinOp _ _ [] = []
setBinOp f (x:xs) ys@(y:yt) = f x y : union (map (f x) yt) (setBinOp f xs ys)

leaf :: SizedTree
leaf = S 1 L

branch :: SizedTree -> SizedTree -> SizedTree
branch (S size1 tree1) (S size2 tree2) = S (size1 + size2) (B tree1 tree2)

allSizedTrees :: [SizedTree]
allSizedTrees = leaf : setBinOp branch allSizedTrees allSizedTrees
-- allSizedTrees = go [leaf]
--     where
--         go ts = ts ++ go td
--           where 
--             td = ts ++ setBinOp branch ts ts