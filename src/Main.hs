{-# LANGUAGE QuasiQuotes, OverloadedStrings #-}

module Main (main) where

import Happstack.Server.Internal.Monads (ununWebT)
import Data.ByteString.Char8 (pack)
import Control.Monad.Trans   (lift)
import Control.Concurrent    (forkIO, killThread)
import System.Environment    (getEnv)
import Data.Functor          ((<$>))
import Happstack.Server
import Hasql
import Hasql.Postgres

import Cido.Api              (api)
import Cido.Types            (Api(..), errorHandler, ApiError(..))

handle :: Pool Postgres -> ServerPartT IO Response
handle p = mapServerPartT' run (unApi api) where
    run r x = session p (spUnwrapErrorT (lift . errorHandler) r x) >>= go
    go = either (ununWebT . errorHandler . CustomInternalServerError . show)
                return

testQuery :: Session Postgres IO ()
testQuery = tx Nothing $ unitEx [stmt| SELECT null |]

main :: IO ()
main = do
    postgresSettings <- StringSettings . pack <$> getEnv "DATABASE_URL"

    settings <- maybe (fail "improper settings") return (poolSettings 6 30)

    pool <- acquirePool postgresSettings settings

    -- test postgres connection
    session pool testQuery >>= either (error . show) return

    tid <- forkIO $ simpleHTTP nullConf (handle pool)
    putStrLn "listening..."

    waitForTermination
    releasePool pool
    killThread tid
