{-# LANGUAGE GeneralizedNewtypeDeriving, RankNTypes #-}

module Cido.Types.Server (Api(..), Query, runQuery) where

import Control.Applicative (Applicative)
import Control.Monad.Trans (MonadIO)
import Hasql
import Hasql.Postgres      (Postgres)

newtype Api s = Api { unApi :: Session Postgres IO s }
    deriving ( Applicative
             , Functor
             , Monad
             , MonadIO
             )

type Query s a = Tx Postgres s a

runQuery :: (forall s. Query s a) -> Api a
runQuery q = Api $ tx (Just (ReadCommitted, Just True)) q
