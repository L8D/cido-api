{-# LANGUAGE QuasiQuotes, RankNTypes, OverloadedStrings #-}

module Cido.Queries where

import Data.Functor              ((<$>))
import Hasql
import Hasql.Postgres            (Postgres)

import Rest

import Cido.Types.User
import Cido.Types.Server

listUsers :: Range -> APIQuery [User]
listUsers (Range o l) = query $ map userFromRow <$> listEx [stmt|
        SELECT id, name, password
        FROM users
        OFFSET $o
        LIMIT $l
    |]

query :: (forall s. Tx Postgres s a) -> APIQuery a
query q = APIQuery $ tx (Just (ReadCommitted, Just True)) q
