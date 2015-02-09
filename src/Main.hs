{-# LANGUAGE ScopedTypeVariables #-}

module Main (main) where

import Control.Concurrent    (forkIO, killThread)
import Control.Monad.Trans   (liftIO)
import System.Environment    (getEnv)
import Data.ByteString.Char8 (pack)
import Happstack.Server
import qualified Hasql as H
import qualified Hasql.Postgres as H

import Rest.Driver.Happstack (apiToHandler')

import Cido.Api (api)
import Cido.Types.Server

conf :: Conf
conf = Conf 3000 Nothing Nothing 60 Nothing

handle :: H.Pool H.Postgres -> ServerPartT IO Response
handle pool = apiToHandler' (liftIO . run) api where
        run a = H.session pool (unApi a) >>= go
        go (Left  e) = fail $ "session failed: " ++ show e
        go (Right x) = return x

main :: IO ()
main = do
    postgresSettings <- fmap (H.StringSettings . pack) $ getEnv "DATABASE_URL"

    poolSettings <- maybe (fail "Improper session settings") return $
                    H.poolSettings 6 30

    pool :: H.Pool H.Postgres <- H.acquirePool postgresSettings poolSettings

    tid <- forkIO $ simpleHTTP conf (handle pool)

    waitForTermination
    H.releasePool pool
    killThread tid
