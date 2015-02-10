module Cido.Api (api) where

import Happstack.Server
import Control.Monad       (msum)
import Cido.Types          (Api)

import qualified Cido.Api.User as User

api :: Api Response
api = msum
    [ dir "users" User.api
    ]
