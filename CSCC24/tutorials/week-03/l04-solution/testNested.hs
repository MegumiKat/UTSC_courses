-- The test is that this file loads without error.

import Nested (NestedListItem(..))

flatten :: [NestedListItem a] -> [a]
flatten lst = concat (map flattenItem lst)

flattenItem :: NestedListItem a -> [a]
flattenItem (Item a) = [a]
flattenItem (List lst) = flatten lst

main = return ()
