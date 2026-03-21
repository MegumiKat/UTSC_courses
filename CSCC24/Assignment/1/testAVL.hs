-- How to use: runghc tesAVL.hs

import AVL qualified (insert)
import AVLDef
import TestLib

insert :: Ord k => k -> AVL k -> AVL k
insert = AVL.insert

sampleInput :: AVL Integer
sampleInput =
    Node
      (Node
        (singleton 10)
        20
        (Node
          (singleton 30)
          40
          (singleton 50)
          2)
        3)
      60
      (Node
        Empty
        70
        (singleton 80)
        2)
      4

-- If insert 35 into sample input. Triggers a double-rotation.
sampleOutput :: AVL Integer
sampleOutput =
    Node
      (Node
        (Node
          (singleton 10)
          20
          Empty
          2)
        30
        (Node
          (singleton 35)
          40
          (singleton 50)
          2)
        3)
      60
      (Node
        Empty
        70
        (singleton 80)
        2)
      4

tests =
    [ "sample" ~: insert 35 sampleInput ~?= sampleOutput
    ]

main = testlibMain tests
