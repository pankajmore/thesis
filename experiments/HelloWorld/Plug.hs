module Plug (main') where

main' :: Int -> IO Int
main' v = do
  putStrLn "Hello World!"
  putStrLn $ show $ v
  putStrLn $ show $ thing
  return (v+1)

thing :: String
thing = "41"
