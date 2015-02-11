{-# LANGUAGE OverloadedStrings #-}

module Cido.Api.User (api) where

import Prelude hiding (show)

import Control.Monad.Error (throwError)
import Happstack.Server
import Control.Monad       (msum)
import Data.Aeson          (ToJSON(..))

import Cido.Types
import Cido.Types.User
import Cido.Queries
import qualified Cido.Queries.User as Q

api :: Api Response
api = msum
    [ fix index
    , fix show
    ] where fix :: ToJSON a => Api a -> Api Response
            fix = fmap (toResponse . toJSON)

index :: Api [User]
index = do
    method GET
    nullDir
    runQuery (Q.listRange 0 100)

show :: Api User
show = do
    method GET
    path $ (nullDir >>) . getUser

getUser :: UserId -> Api User
getUser uid = runQuery (Q.findById uid) >>= go where
    go Nothing  = throwError NotFound
    go (Just u) = return u
