module Main (main) where

import System.Plugins
import Control.Monad

main :: IO ()
main = forever $ do
  putStrLn "Loading"
  make "Plug.hs" []
  mv <- load "Plug.o" [] [] "thing"   -- also try 'load' here
  putStrLn "Loaded"
  case mv of
    LoadFailure msgs -> putStrLn "fail" >> print msgs
    LoadSuccess m v -> do
      putStrLn "success"
      print (v::Integer)
      case hasChanged m of
        True -> unloadAll m
  putStrLn "Press y to reload"

  getChar
