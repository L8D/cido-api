module Cido.Resources.User (resource) where

import Control.Monad.Reader (ReaderT)
import Control.Monad.Trans  (lift)

import Rest
import qualified Rest.Resource   as R

import Cido.Types.Server
import Cido.Queries.User

data UserId = ById Int

type WithUserId = ReaderT UserId Api

resource :: Resource Api WithUserId UserId () Void
resource = mkResourceReader
  { R.name   = "users"
  , R.schema = withListing () $ named [("id", singleRead ById)]
  , R.list   = const listUsers
  }

listUsers :: ListHandler Api
listUsers = mkListing (jsonO . someO) handle where
    handle (Range o l) = lift $ runQuery $ getAllUsers o l