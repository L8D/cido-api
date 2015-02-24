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

show :: Api User
show = do
    method GET
    path $ \uid -> nullDir >> findById uid

insert :: Api User
insert = do
    method POST
    nullDir
    let err = ApiError InternalServerError Nothing
    askRq >>= takeRequestBody >>= maybe (throwError err)
                                        (handleUserBody . unBody)

handleUserBody :: ByteString -> Api User
handleUserBody b = case decode b of
    Nothing -> throwError (ApiError UnprocessableEntity Nothing) -- TODO
    Just n  -> insertNewUser n
