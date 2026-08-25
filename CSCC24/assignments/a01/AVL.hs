module AVL(insert) where

import AVLDef

-- | Update the height of a node based on the heights of its children.
updateHeight :: AVL k -> AVL k
updateHeight Empty = Empty
updateHeight (Node lt k rt _) = Node lt k rt (1 + max (height lt) (height rt))

-- | Perform a right rotation.
rotateRight :: AVL k -> AVL k
rotateRight Empty = Empty
rotateRight (Node (Node ltl lk ltr _) k r _) = updateHeight (Node ltl lk (updateHeight (Node ltr k r rh)) th)
    where 
        th = 2 + max (height ltr) (height r)
        rh = 1 + max (height ltr) (height r)

-- | Perform a left rotation.
rotateLeft :: AVL k -> AVL k
rotateLeft Empty = Empty
rotateLeft (Node l k (Node rtl rk rtr rh) _) = updateHeight (Node (updateHeight (Node l k rtl lh)) rk rtr th)
    where 
        th = 2 + max (height rtl) (height l)
        lh = 1 + max (height l) (height rtl)

-- | Balance a node.
balance :: AVL k -> AVL k
balance node@(Node l k r _)
  | balanceFactor node > 1 =
      if balanceFactor l >= 0
      then rotateRight node
      else rotateRight (Node (rotateLeft l) k r (1 + max (height (rotateLeft l)) (height r)))
  | balanceFactor node < -1 =
      if balanceFactor r <= 0
      then rotateLeft node
      else rotateLeft (Node l k (rotateRight r) (1 + max (height (rotateRight r)) (height l)))
  | otherwise = node


insert :: Ord k => k -> AVL k -> AVL k
insert m Empty = singleton m
insert m node@(Node l k r _)
    | m < k = balance (Node (insert m l) k r (1 + max (height (insert m l)) (height r)))
    | m > k = balance (Node l k (insert m r) (1 + max (height (insert m r)) (height l)))
    | otherwise = node


