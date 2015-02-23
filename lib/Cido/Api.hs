module Cido.Api (api) where

import Happstack.Server
import Control.Monad.Error (throwError)
import Control.Monad       (msum)

import Cido.Types

import qualified Cido.Api.User as User

api :: Api Response
api = fmap toResponse $ msum
    [ dir "users" User.api
    , throwError NotFound
    ]
