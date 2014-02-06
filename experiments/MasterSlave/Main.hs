{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where
import System.Environment (getArgs)
import System.Plugins
import Control.Monad

main :: IO ()
main = forever $ do
  putStrLn "Loading"
  r <- makeAll "SimpleLocalnet.hs" []
  case r of
    MakeSuccess mc fp -> do
      mv <- load fp [] [] "main"
      putStrLn $ show $ mc
      putStrLn "Loaded"
      case mv of
        LoadFailure msgs -> putStrLn "fail" >> print msgs
        LoadSuccess m v -> do
        putStrLn "success"
        s <- v
        unloadAll m
    MakeFailure msgs -> putStrLn "failed to make" >> print msgs
  putStrLn "Press y to reload"

  getChar
