{-# LANGUAGE ScopedTypeVariables #-}

module Main (main) where

import Control.Concurrent    (forkIO, killThread)
import Control.Monad.Trans   (liftIO)
import System.Environment    (getEnv)
import Data.ByteString.Char8 (pack)
import Happstack.Server
import Hasql
import Hasql.Postgres

import Rest.Driver.Happstack (apiToHandler')

import Cido.Api (api)
import Cido.Types.Server

conf :: Conf
conf = Conf 3000 Nothing Nothing 60 Nothing

handle :: Pool Postgres -> ServerPartT IO Response
handle pool = apiToHandler' run api where
    run a = session pool (unApi a) >>= getRidOfTheError
    getRidOfTheError (Left e) = do
        liftIO $ putStrLn $ "postgres failure: " ++ show e
        fail "500 Internal Error" -- omg guys we needz to fix dis
    getRidOfTheError (Right x) = return x

main :: IO ()
main = do
    postgresSettings <- fmap (StringSettings . pack) $ getEnv "DATABASE_URL"

    settings <- maybe (fail "improper settings") return (poolSettings 6 30)

    pool :: Pool Postgres <- acquirePool postgresSettings settings

    tid <- forkIO $ simpleHTTP conf (handle pool)

    waitForTermination
    releasePool pool
    killThread tid
