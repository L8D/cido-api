{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User ( getAllUsers
                         , authenticateUser
                         , findUserById
                         ) where

import Data.Functor      ((<$>))
import Hasql
import Data.Text         (Text)

import Cido.Types.Server
import Cido.Types.User   hiding (id, username)

getAllUsers :: Int -> Int -> forall s. Query s [User]
getAllUsers o l = map fromRow <$> listEx [stmt|
        SELECT id, username
        FROM users
        OFFSET $o
        LIMIT $l
    |]

findUserById :: Id -> forall s. Query s (Maybe User)
findUserById uid = fmap fromRow <$> maybeEx [stmt|
        SELECT id, username
        FROM users
        WHERE id = $uid
    |]

fromRow :: (Id, Username) -> User
fromRow (uid, username) = User uid username

authenticateUser :: User -> Text -> forall s. Query s (Maybe AuthenticatedUser)
authenticateUser (User uid _) p = fmap auth <$> maybeEx [stmt|
        SELECT id, username
        FROM users
        WHERE id = $uid AND crypt($p, password) = password
    |] where auth = AuthenticatedUser . fromRow
