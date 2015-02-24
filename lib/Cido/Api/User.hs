{-# LANGUAGE OverloadedStrings #-}

module Cido.Api.User (api) where

import Prelude hiding (show)

import Data.ByteString.Lazy (ByteString)
import Control.Monad.Error  (throwError)
import Happstack.Server
import Control.Monad        (msum)
import Data.Functor         ((<$>))
import Data.Aeson

import Cido.Types
import Cido.Types.User
import Cido.Queries.User

api :: Api Value
api = msum
    [ toJSON <$> index
    , toJSON <$> show
    , toJSON <$> insert
    ]

index :: Api [User]
index = do
    method GET
    nullDir
    listUsers
    -- runQuery (Q.listRange 0 100)

show :: Api User
show = do
    method GET
    path $ \uid -> nullDir >> findById uid

insert :: Api User
insert = do
    method POST
    nullDir
    askRq >>= takeRequestBody >>= maybe (throwError InternalServerError)
                                        (handleUserBody . unBody)

handleUserBody :: ByteString -> Api User
handleUserBody b = case decode b of
    Nothing -> throwError UnprocessableEntity
    Just n  -> insertNewUser n
        -- go Nothing  = throwError UnprocessableEntity
        -- go (Just u) = return u

-- getUser :: UserId -> Api User
-- getUser uid = runQuery (Q.findById uid) >>= go where
    -- go Nothing  = throwError NotFound
    -- go (Just u) = return u
