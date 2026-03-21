{-
How to use: runghc testInorder.hs
-}

import TestLib
import Basic (ITree(..), inorder)

sample :: ITree
sample = INode
           (INode
             IEmpty
             76
             (INode IEmpty 55 IEmpty))
           25
           (INode
             (INode IEmpty 20 IEmpty)
             32
             (INode IEmpty 41 IEmpty))

tests =
    [ "inorder handout" ~: inorder sample ~?= [76, 55, 25, 20, 32, 41]
    ]

main = testlibMain tests
