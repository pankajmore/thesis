module Main (main) where
import System.Environment (getArgs)
import System.Plugins
import Control.Monad

main :: IO ()
main = forever $ do
  putStrLn "Loading"
  r <- makeAll "PingPong.hs" []
  case r of
    MakeSuccess mc fp -> do
      mv <- load fp [] ["/usr/lib/ghc-7.6.3/package.conf.d","/home/pankajm/.ghc/x86_64-linux-7.6.3/package.conf.d"] "main'"
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