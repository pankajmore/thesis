module Main (main) where

import System.Plugins
import Control.Monad

main :: IO ()
main = forever $ do
  putStrLn "Loading"
  make "Plug.hs" []
--  mv <- load "Plug.o" [] ["/usr/lib/ghc-7.6.3/package.conf.d","/home/pankajm/.ghc/x86_64-linux-7.6.3/package.conf.d"] "main'"
  mv <- load "Plug.o" [] [] "main'"
  putStrLn "Loaded"
  case mv of
    LoadFailure msgs -> putStrLn "fail" >> print msgs
    LoadSuccess m v -> do
      putStrLn "success"
      st <- v (0 :: Int)
      st <- v (st :: Int)
      st <- v (st :: Int)
      unloadAll m
  putStrLn "Press y to reload"

  getChar
