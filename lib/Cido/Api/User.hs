{-# LANGUAGE OverloadedStrings #-}

module Cido.Api.User (api) where

import Prelude hiding (show)

import Data.ByteString.Lazy (ByteString)
import Control.Monad.Error  (throwError)
import Control.Monad.Trans  (liftIO)
import Happstack.Server
import Control.Monad        (msum)
import Data.Functor         ((<$>))
import Data.Aeson

import Cido.Types
import Cido.Types.User
import Cido.Types.NewUser
import Cido.Queries
import qualified Cido.Queries.User as Q

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
    runQuery (Q.listRange 0 100)

show :: Api User
show = do
    method GET
    path $ (nullDir >>) . getUser

insert :: Api User
insert = do
    method POST
    nullDir
    askRq
        >>= takeRequestBody
        >>= maybe (throwError InternalServerError) (handleUserBody . unBody)

handleUserBody :: ByteString -> Api User
handleUserBody b = case decode b of
    Nothing -> throwError UnprocessableEntity
    Just u -> throwError InternalServerError -- TODO

getUser :: UserId -> Api User
getUser uid = runQuery (Q.findById uid) >>= go where
    go Nothing  = throwError NotFound
    go (Just u) = return u
