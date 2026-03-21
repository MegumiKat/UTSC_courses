{-
How to use: runghc testInorder.hs
-}

import TestLib
import Basic (ITree(..), inorder)

tests =
    [ "inorder empty" ~: inorder IEmpty ~?= []
    , "inorder singleton" ~: inorder (INode IEmpty 58 IEmpty) ~?= [58]
    , "inorder bigger" ~: inorder bigger ~?= [43,60,13,54,39,55,68,12,82,56]
    ]

bigger :: ITree
bigger = INode (INode IEmpty 43 (INode IEmpty 60 IEmpty)) 13 (INode (INode (INode IEmpty 54 IEmpty) 39 (INode (INode IEmpty 55 IEmpty) 68 IEmpty)) 12 (INode (INode IEmpty 82 IEmpty) 56 IEmpty))

main = testlibMain tests
