module Cido.Api (api) where

import Happstack.Server
import Control.Monad       (msum)
import Control.Monad.Error (throwError)

import Cido.Types

import qualified Cido.Api.User as User

api :: Api Response
api = msum
    [ dir "users" User.api
    , throwError NotFound
    ]
