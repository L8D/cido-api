{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Cido.Types (Api(..)) where

import Control.Monad.Trans (MonadIO)
import Happstack.Server
import Control.Monad       (MonadPlus)
import Control.Applicative (Applicative)
import Hasql
import Hasql.Postgres

newtype Api a = Api { unApi :: ServerPartT (Session Postgres IO) a }
    deriving ( Monad
             , Functor
             , MonadIO
             , MonadPlus
             , Applicative
             )
