{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE OverloadedStrings, MultiParamTypeClasses #-}

module Util () where

import Data.ByteString.Builder (toLazyByteString)
import Text.Email.Validate
import Data.Text.Encoding
import Data.Aeson.Encode       (encodeToByteStringBuilder)
import Data.Aeson.Types
import Happstack.Server
import Data.UUID.Aeson         ()
import Hasql.Postgres
import Hasql.Backend
import Data.Text

instance ToMessage Value where
    toContentType _ = "application/json; charset=utf-8"
    toMessage = toLazyByteString . encodeToByteStringBuilder
    toResponse x = toResponseBS (toContentType x) (toMessage x)

instance ToJSON EmailAddress where
    toJSON e = String (decodeUtf8 $ toByteString e)

instance FromJSON EmailAddress where
    parseJSON v = withText name (go . emailAddress . encodeUtf8) v where
        go Nothing  = typeMismatch name v
        go (Just x) = return x

        name = "EmailAddress"

instance CxValue Postgres EmailAddress where
    encodeValue = encodeValue . decodeUtf8 . toByteString
    decodeValue v = decodeValue v >>= \x -> case validate (encodeUtf8 x) of
        Left l -> Left (pack $ l ++ show x)
        Right r -> Right r
