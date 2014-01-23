{-# LANGUAGE DeriveDataTypeable #-}
module PingPong where
import Control.Concurrent ( threadDelay )
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport
import Network.Transport.TCP

server :: ReceivePort Int-> Process ()
server rPing = do
    x <- receiveChan rPing
    liftIO $ putStrLn $ "Got a ping! " ++ (show x)

client :: SendPort Int -> Process ()
client sPing = do
    sendChan sPing 42
    liftIO $ putStrLn "Sent a Ping"

ignition :: Process ()
ignition = do
    -- start the server
    sPing <- spawnChannelLocal server
    -- start the client
    liftIO $ threadDelay 2000000 -- wait a while
    spawnLocal $ client sPing
    liftIO $ threadDelay 1000000 -- wait a while

main :: IO ()
main = do
    Right transport <- createTransport "127.0.0.1" "8080"
                            defaultTCPParameters
    node <- newLocalNode transport initRemoteTable
    runProcess node ignition
    closeTransport transport
