{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User ( findById
                         , listRange
                         , insertNewUser
                         ) where

import Prelude hiding (id)
import Data.Functor   ((<$>))
import Data.Time      (UTCTime)
import Hasql
import Hasql.Postgres

import Cido.Types.User

import qualified Cido.Types.NewUser as N

findById :: UserId -> forall s. Tx Postgres s (Maybe User)
findById uid = fmap fromRow <$> maybeEx [stmt|
    SELECT id, username, password, created_at, updated_at
    FROM users
    WHERE id = $uid
|]

fromRow :: (UserId, Username, Password, UTCTime, UTCTime) -> User
fromRow (uid, usrn, pswd, crat, upat) = User
    { id         = uid
    , username   = usrn
    , password   = pswd
    , created_at = crat
    , updated_at = upat
    }

listRange :: Int -> Int -> forall s. Tx Postgres s [User]
listRange o l = fmap fromRow <$> listEx [stmt|
    SELECT id, username, password, created_at, updated_at
    FROM users
    OFFSET $o
    LIMIT $l
|]

insertNewUser :: N.NewUser -> forall s. Tx Postgres s (Maybe User)
insertNewUser (N.NewUser usrn pswd) = fmap fromRow <$> maybeEx [stmt|
    INSERT INTO users (username, password)
    VALUES ($usrn, crypt($pswd, gen_salt('bf', 8)))
    RETURNING id, username, password, created_at, updated_at
|]
