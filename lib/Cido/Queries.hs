{-# LANGUAGE RankNTypes #-}

module Cido.Queries (runQuery) where

import Control.Monad.Trans (lift)
import Hasql
import Hasql.Postgres

import Cido.Types

runQuery :: (forall s. Tx Postgres s a) -> Api a
runQuery t = Api $ lift $ lift $ tx (Just (ReadCommitted, Just True)) t
