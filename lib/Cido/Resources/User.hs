module Cido.Resources.User (resource) where

import Control.Monad.Reader (ReaderT)
import Control.Monad.Trans  (lift)

import Rest
import qualified Rest.Resource   as R

import Cido.Types.Server
import qualified Cido.Queries    as Q

data UserId = ById Int

type WithUserId = ReaderT UserId APIQuery

resource :: Resource APIQuery WithUserId UserId () Void
resource = mkResourceReader
  { R.name   = "users"
  , R.schema = withListing () $ named [("id", singleRead ById)]
  , R.list   = const listUsers
  }

listUsers :: ListHandler APIQuery
listUsers = mkListing (jsonO . someO) handle where
    handle (Range o l) = lift (Q.query $ Q.listUsers o l)
