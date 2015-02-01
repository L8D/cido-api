{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries where

import Data.Functor              ((<$>))
import Hasql
import Hasql.Postgres            (Postgres)

import Cido.Types.User
import Cido.Types.Server

listUsers :: Int -> Int -> forall s. Tx Postgres s [User]
listUsers o l = map toUser <$> listEx [stmt|
        SELECT id, username, password
        FROM users
        OFFSET $o
        LIMIT $l
    |] where toUser (uid, username, password) = User uid username password

query :: (forall s. Tx Postgres s a) -> APIQuery a
query q = APIQuery $ tx (Just (ReadCommitted, Just True)) q
