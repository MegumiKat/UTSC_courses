module AVLDef where

-- | AVL defn.
data AVL k
  = Empty
  | Node{avlLeft :: AVL k,    -- left
         avlKey :: k,         -- key
         avlRight :: AVL k,   -- right
         avlHeight :: Int}    -- cached height
  deriving Eq

{-
The funny syntax above is "record syntax": data fields can have field names.

If you don't want to know, you can ignore, then it is just

data AVL k
  = Empty
  | Node (AVL k) k (AVL k) Int
    -- left, key, right, cached height

The height function below shows that.

But if you have time to learn Haskell record syntax, your code can be clearer
with less clutter. The balanceFactor function shows that.

Starter for record syntax:
https://en.wikibooks.org/wiki/Haskell/More_on_datatypes#Named_Fields_(Record_Syntax)
-}


-- Useful getters.

-- | Get cached height, or 0 if empty.
height :: AVL k -> Int
height Empty = 0
height (Node _ _ _ h) = h

-- | Balance factor = left height - right height
balanceFactor :: AVL k -> Int
balanceFactor Node{avlLeft, avlRight} = height avlLeft - height avlRight
balanceFactor Empty = 0


-- Trivial trees.

-- | The empty tree.
empty :: AVL k
empty = Empty

-- | Singleton.
singleton :: k -> AVL k
singleton k = Node Empty k Empty 1


-- Abuse of Show, but nicer for debugging this assignment and printing test
-- failures.
instance Show k => Show (AVL k) where
    show Empty = "(empty)"
    show t = (showChar '\n' . go 0 t) ""
      where
        go _ Empty = id 
        go n (Node lt key rt h) =
          go (n + 2) rt
          . showString (replicate n ' ') . shows key
          . showString " [" . shows h . showChar ']'
          . showChar '\n'
          . go (n + 2) lt

