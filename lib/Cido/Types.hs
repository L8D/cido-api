{-# LANGUAGE GeneralizedNewtypeDeriving, OverloadedStrings #-}

module Cido.Types ( Api(..)
                  , ApiError(..)
                  , demystify
                  , errorHandler
                  ) where

import Control.Monad.Trans (MonadIO)
import Control.Monad.Error (ErrorT)
import Control.Applicative (Applicative)
import Happstack.Server
import Control.Monad       (MonadPlus)
import Data.Aeson
import Data.Text           (pack)
import Util                ()
import Hasql
import Hasql.Postgres
import Control.Monad.Trans.Error (Error(..))
import Control.Monad.Error.Class (MonadError)

newtype Api a = Api
    { unApi :: ServerPartT (ErrorT ApiError (Session Postgres IO)) a }
    deriving ( Monad
             , Functor
             , MonadIO
             , MonadPlus
             , Applicative
             , ServerMonad
             , MonadError ApiError
             , HasRqData
             )

errorHandler :: ApiError -> ServerPartT (Session Postgres IO) Response
errorHandler x = setResponseCode c >> (flatten $ return $ toJSON x)
    where (c, _) = demystify x

data ApiError
    = NotFound
    | InternalServerError
    | UnprocessableEntity
    | CustomInternalServerError String

instance Error ApiError where
    noMsg  = InternalServerError
    strMsg = CustomInternalServerError

instance ToJSON ApiError where
    toJSON err = object
        [ "error" .= object
            [ "code" .= code
            , "message" .= pack message
            ]
        ] where (code, message) = demystify err

demystify :: ApiError -> (Int, String)
demystify NotFound                      = (404, "Not Found")
demystify InternalServerError           = (500, "Internal Server Error")
demystify UnprocessableEntity           = (422, "Unprocessable Entity")
demystify (CustomInternalServerError s) = (500, s)
