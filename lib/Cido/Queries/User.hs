{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User ( findById
                         , listUsers
                         , insertNewUser
                         ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Control.Monad.Error (throwError)
import Control.Monad       (join)
import Happstack.Server
import Data.Functor        ((<$>))
import Data.Time           (UTCTime)
import Hasql

import Cido.Types
import Cido.Types.User
import Cido.Queries

import qualified Cido.Types.NewUser as N

findById :: UserId -> Api User
findById uid = runQuery (fmap fromRow <$> maybeEx q) >>= go where
    q = [stmt|
        SELECT id, email, password, created_at, updated_at
        FROM users
        WHERE id = ?
    |] (unUserId uid)

    go Nothing  = throwError NotFound
    go (Just u) = return u

fromRow :: (UserId, EmailAddr, HashedPassword, UTCTime, UTCTime) -> User
fromRow (uid, emil, pswd, crat, upat) = User
    { id         = uid
    , email      = emil
    , password   = pswd
    , created_at = crat
    , updated_at = upat
    }

listUsers :: Api [User]
listUsers = join $ liftA2 listRange getOffset getLimit

getOffset :: Api Int
getOffset = go <$> queryString (lookReads "offset") where
    go []    = 0
    go (x:_) = min x 0

getLimit :: Api Int
getLimit = go <$> queryString (lookReads "limit") where
    go []    = 100
    go (x:_) = max x 100

listRange :: Int -> Int -> Api [User]
listRange o l = runQuery $ fmap fromRow <$> listEx [stmt|
    SELECT id, email, password, created_at, updated_at
    FROM users
    OFFSET $o
    LIMIT $l
|]

insertNewUser :: N.NewUser -> Api User
insertNewUser (N.NewUser n p) = runQuery (fmap fromRow <$> q) >>= go where
    q = maybeEx $ [stmt| SELECT insert_user(?, ?) |] n p

    go Nothing  = throwError BadRequest
    go (Just u) = return u
