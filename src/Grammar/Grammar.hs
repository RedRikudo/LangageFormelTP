module Grammar.Grammar where

import Grammar.Types
import Data.List (nub)
import Data.Either (lefts, rights)

isCNF :: Grammar -> Bool
isCNF Grammar {rules, entryVar} = all valid rules where 
  valid (Rule _ [Right _]        )                              = True
  valid (Rule _ [Left v, Left v']) | entryVar `notElem` [v, v'] = True
  valid (Rule v []               ) | v == entryVar              = True
  valid _ = False

vars :: Grammar -> [Var]
vars g = nub $ entryVar g 
             : map from (rules g) 
             ++ (rules g >>= lefts . to)

terminals :: Grammar -> [Terminal]
terminals g = rules g >>= rights . to