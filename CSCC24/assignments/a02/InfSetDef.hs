module InfSetDef where

data BinaryTree = L | B BinaryTree BinaryTree
    deriving (Eq, Ord, Show)

data SizedTree = S Integer BinaryTree
    deriving (Eq, Ord, Show)

unsize :: SizedTree -> BinaryTree
unsize (S _ t) = t
