{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Cido.Types.Server (APIQuery(..)) where

import Control.Applicative (Applicative)
import Control.Monad.Trans (MonadIO)
import Hasql               (Session)
import Hasql.Postgres      (Postgres)

newtype APIQuery s = APIQuery { unAPIQuery :: Session Postgres IO s }
    deriving ( Applicative
             , Functor
             , Monad
             , MonadIO
             )
