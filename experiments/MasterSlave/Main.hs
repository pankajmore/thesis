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
  args <- getArgs
  r <- makeAll "SimpleLocalnet.hs" ["-package-db ../../../distributed-process-platform/.cabal-sandbox/x86_64-linux-ghc-7.6.3-packages.conf.d","-cpp","-optP  -DUSE_SIMPLELOCALNET"]
  case r of
    MakeSuccess mc fp -> do
      mv <- load fp [] [] "main'"
      putStrLn $ show $ mc
      putStrLn "Loaded"
      case mv of
        LoadFailure msgs -> putStrLn "fail" >> print msgs
        LoadSuccess m v -> do
        putStrLn "success"
        s <- v args
        unloadAll m
    MakeFailure msgs -> putStrLn "failed to make" >> print msgs
  putStrLn "Press y to reload"

  getChar
