{-# LANGUAGE OverloadedStrings #-}

module Cido.Api.User (api) where

import Control.Monad.Error (throwError)
import Happstack.Server
import Control.Monad       (msum)
import Data.Aeson          (toJSON)

import Cido.Types
import Cido.Types.User
import Cido.Queries
import Cido.Queries.User

api :: Api Response
api = msum
    [ do method GET
         user <- path getUser
         nullDir
         flatten $ return $ toJSON $ user
    ]

getUser :: UserId -> Api User
getUser uid = runQuery (findUser uid) >>= go where
    go Nothing  = throwError NotFound
    go (Just u) = return u
