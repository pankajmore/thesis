{-# LANGUAGE DeriveDataTypeable,ScopedTypeVariables #-}
module PingPong where
import Control.Concurrent ( threadDelay )
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport ( closeTransport )
import Network.Transport.TCP

server :: Process ()
server = do
    (cid,x) :: (ProcessId,Int) <- expect
    liftIO $ putStrLn $ "Got  a Ping with value : " ++ (show x)
    case x of
      5 -> do
        liftIO $ putStrLn $ "STOP"
        return ()
      _ -> do
        send cid x
        liftIO $ putStrLn $ "Sent a Pong with value : " ++ (show x)
        server

client :: Int -> ProcessId -> Process ()
client 10 sid = do
  liftIO $ putStrLn "DONE"
client c sid = do
  me <- getSelfPid
  send sid (me,c)
  liftIO $ putStrLn $ "Sent a Ping with value : " ++ (show c)
  (v :: Int) <- expect
  liftIO $ putStrLn $ "Got  a Pong with value : " ++ (show v)
  client (c+1) sid

ignition :: Process ()
ignition = do
    -- start the server
    sid <- spawnLocal server
    -- start the client
    cid <- spawnLocal $ client 0 sid
    return ()
    liftIO $ threadDelay 100000-- wait a while

main :: IO ()
main = do
    Right transport <- createTransport "127.0.0.1" "8080"
                            defaultTCPParameters
    node <- newLocalNode transport initRemoteTable
    runProcess node ignition
    closeTransport transport
