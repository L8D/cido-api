module Main (main) where

import Control.Concurrent (forkIO, killThread)
import Happstack.Server

conf :: Conf
conf = Conf 3000 Nothing Nothing 60 Nothing

main :: IO ()
main = do
    tid <- forkIO $ simpleHTTP conf (notFound "404 Not Found")

    waitForTermination
    killThread tid
