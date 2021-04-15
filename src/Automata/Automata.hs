module Automata.Automata where

import Automata.Types 
import Data.List (nub)
import Data.Maybe (listToMaybe)

states :: Automata -> [State]
states a = nub $ origins ++ dests
  where origins = origin <$> transitions a
        dests   = dest   <$> transitions a

-- Returns all symbols (no epsilon)
symbols :: Automata -> [Symbol]
symbols = filter (/= Epsilon) . nub . map symbol . transitions

stackSymbols :: Automata -> [StackSymbol]
stackSymbols a = nub $ newTops ++ tops
  where tops    = stackTop <$> transitions a
        newTops = transitions a >>= newStackTop

-- This is the δ(q, a, X) function
deltaTransitions :: Automata -> State -> Symbol -> StackSymbol -> [Transition]
deltaTransitions a orig sym stTop = 
  filter (\(Transition {origin, symbol, stackTop}) -> 
              origin   == orig &&
              symbol   == sym  &&
              stackTop == stTop
         ) $ transitions a

-- Use this with deterministic automatas guaranteed to have 0 or 1 transition
deltaTransition :: Automata -> State -> Symbol -> StackSymbol -> Maybe Transition
deltaTransition a st s ss = listToMaybe $ deltaTransitions a st s ss

isDeterministic :: Automata -> Bool
isDeterministic a = and [
    let f symbol = deltaTransitions a st symbol stSym in
    length (f sym ++ f Epsilon) <= 1 -- δ(q, a, X) + δ(q, ε, X)
    | st    <- states a, 
      sym   <- symbols a, 
      stSym <- stackSymbols a
  ]