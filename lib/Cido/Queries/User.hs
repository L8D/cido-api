{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User ( findUser
                         , listUsers
                         ) where

import Prelude hiding (id)
import Data.Functor   ((<$>))
import Data.Time      (UTCTime)
import Hasql
import Hasql.Postgres

import Cido.Types.User

findUser :: UserId -> forall s. Tx Postgres s (Maybe User)
findUser uid = fmap fromRow <$> maybeEx [stmt|
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

listUsers :: forall s. Tx Postgres s [User]
listUsers = fmap fromRow <$> listEx [stmt|
    SELECT id, username, password, created_at, updated_at
    FROM users
|]
