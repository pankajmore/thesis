{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE TemplateHaskell #-}
module MasterSlave where

import Control.Monad
import Control.Distributed.Process
import Control.Distributed.Process.Closure
import PrimeFactors

slave :: (ProcessId, Integer) -> Process ()
slave (pid, n) = do
  liftIO $ print $ "got " ++ show n
  send pid (numPrimeFactors n)

remotable ['slave]

-- | Wait for n integers and sum them all up
sumIntegers :: Integer -> Process Integer
sumIntegers = go 0
  where
    go :: Integer -> Integer -> Process Integer
    go !acc 0 = return acc
    go !acc n = do
      m <- expect
      go (acc + m) (n - 1)

data SpawnStrategy = SpawnSyncWithReconnect
                   | SpawnSyncNoReconnect
                   | SpawnAsync
  deriving (Show, Read)

master :: Integer -> SpawnStrategy -> [NodeId] -> Process Integer
master n spawnStrategy slaves = do
  liftIO $ print "started"
  us <- getSelfPid
  -- Distribute 1 .. n amongst the slave processes
  spawnLocal $ case spawnStrategy of
    SpawnSyncWithReconnect ->
      forM_ (zip [1 .. n] (cycle slaves)) $ \(m, there) -> do
        them <- spawn there ($(mkClosure 'slave) (us, m))
        reconnect them
    SpawnSyncNoReconnect ->
      forM_ (zip [1 .. n] (cycle slaves)) $ \(m, there) -> do
        _them <- spawn there ($(mkClosure 'slave) (us, m))
        return ()
    SpawnAsync ->
      forM_ (zip [1 .. n] (cycle slaves)) $ \(m, there) -> do
        spawnAsync there ($(mkClosure 'slave) (us, m))
        _ <- expectTimeout 0 :: Process (Maybe DidSpawn)
        return ()
  liftIO $ print "spawned"
  -- Wait for the result
  sumIntegers n
