module Cido.Resources.User (resource) where

import Control.Monad.Error  (ErrorT, throwError)
import Control.Monad.Reader (ReaderT)
import Control.Monad.Trans  (lift)

import Rest
import qualified Rest.Resource as R

import Cido.Types.Server
import Cido.Types.User      (User)
import Cido.Queries.User

data Identifier = ById Int

type WithUser = ReaderT Identifier Api

resource :: Resource Api WithUser Identifier () Void
resource = mkResourceReader
  { R.name   = "users"
  , R.schema = withListing () $ named [("id", singleRead ById)]
  , R.list   = const listUsers
  , R.get    = Just getUser
  }

listUsers :: ListHandler Api
listUsers = mkListing (jsonO . someO) handler where
    handler (Range o l) = lift $ runQuery $ getAllUsers o l

getUser :: Handler WithUser
getUser = mkIdHandler (jsonO . someO) handler where
    handler :: () -> Identifier -> ErrorT Reason_ WithUser User
    handler _ (ById uid) = do
        r <- lift $ lift $ runQuery $ findUserById uid
        case r of
            Just u  -> return u
            Nothing -> throwError NotFound
