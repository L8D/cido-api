{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User where

import Data.Functor              ((<$>))
import Hasql

import Cido.Types.User
import Cido.Types.Server

getAllUsers :: Int -> Int -> forall s. Query s [User]
getAllUsers o l = map toUser <$> listEx [stmt|
        SELECT id, username, password
        FROM users
        OFFSET $o
        LIMIT $l
    |] where toUser (uid, username, password) = User uid username password
