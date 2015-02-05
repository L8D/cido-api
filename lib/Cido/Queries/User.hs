{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries.User (getAllUsers) where

import Data.Functor ((<$>))
import Hasql
import Data.Text    (Text)

import Cido.Types.User
import Cido.Types.Server

getAllUsers :: Int -> Int -> forall s. Query s [User]
getAllUsers o l = map fromRow <$> listEx [stmt|
        SELECT id, username
        FROM users
        OFFSET $o
        LIMIT $l
    |]

fromRow :: (Int, Text) -> User
fromRow (uid, username) = User uid username
