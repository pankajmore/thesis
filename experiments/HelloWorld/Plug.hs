module Plug (main') where
import Data.Numbers.Fibonacci
import Data.IORef

main' :: Int -> IO Int
main' v = do
  putStrLn "Hello World!"
  print $ length . show $ fib 10000000
  putStrLn $ show $ v
  putStrLn $ show $ thing
  return (v+1)

thing :: String
thing = "42"
