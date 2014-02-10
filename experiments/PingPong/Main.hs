module Main (main) where
import System.Environment (getArgs)
import System.Plugins
import Control.Monad

--remain :: Module -> IO ()
remain m v = forever $ do
  c <- hasChanged m
  case c of
    False -> do
      v reboot
    True -> do
      r <- recompileAll m []
      case r of
        MakeFailure msgs -> putStrLn "failed to make" >> print msgs
        MakeSuccess mc fp -> do
          putStrLn $ show $ mc
          -- unload m
          -- mv <- load fp [] [] "main"
          mv <- reload m "main"
          putStrLn "Loaded"
          case mv of
            LoadFailure msgs -> putStrLn "fail" >> print msgs
            LoadSuccess m v -> do
              putStrLn "success"
              v reboot
  putStrLn "Press y to reload"
  getChar

reboot :: IO ()
reboot = forever $ do
  putStrLn "Loading"
  r <- makeAll "PingPong.hs" []
  case r of
    MakeSuccess mc fp -> do
      mv <- load fp [] [] "main"
      putStrLn $ show $ mc
      putStrLn "Loaded"
      case mv of
        LoadFailure msgs -> putStrLn "fail" >> print msgs
        LoadSuccess m v -> do
        putStrLn "success"
        v reboot
        unloadAll m
    MakeFailure msgs -> putStrLn "failed to make" >> print msgs
  putStrLn "Press y to reload"
  getChar

type DynamicT = IO ()

main :: IO ()
main = do
  putStrLn "Loading"
  r <- makeAll "PingPong.hs" []
  case r of
    MakeFailure msgs -> putStrLn "failed to make" >> print msgs
    MakeSuccess mc fp -> do
      mv <- load fp [] [] "main"
      putStrLn $ show $ mc
      putStrLn "Loaded"
      case mv of
        LoadFailure msgs -> putStrLn "fail" >> print msgs
        LoadSuccess m v -> do
        putStrLn "success"
        s <- v reboot
        putStrLn "Press y to reload"
        getChar
--        remain m v
        reboot
        return ()
