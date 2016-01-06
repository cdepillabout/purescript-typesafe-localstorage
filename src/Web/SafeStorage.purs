
module Web.SafeStorage where

import Prelude (Unit, bind, const, (>>=), pure, ($), show, (<<<))

import Browser.WebStorage (WebStorage(), localStorage)
import Browser.WebStorage as WebStorage
import Control.Monad.Eff (Eff)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (either)
import Data.Maybe (Maybe(..))

-----------------------------------------------------------------------------
-- datatypes representing keys to use to fetch things from the local store --
-----------------------------------------------------------------------------

class StorageKey a where
    storageKey :: a -> String

-------------------------------------------------------------------------------
-- Class for storing things to the localstore.  This makes sure certain keys --
-- are only used with certain objects.                                       --
-------------------------------------------------------------------------------

class CanStore a b where
    setItem :: forall eff . a -> b -> Eff (webStorage :: WebStorage | eff) Unit
    getItem :: forall eff . a -> Eff (webStorage :: WebStorage | eff) (Maybe b)

---------------------------------------------------------------------
-- Helper methods for writing the `getItem` and `setItem` methods. --
---------------------------------------------------------------------

setItemGeneric :: forall eff a b . (StorageKey a)
               => (b -> String) -> a -> b
               -> Eff (webStorage :: WebStorage | eff) Unit
setItemGeneric f x item =
    let string = storageKey x
        itemString = f item
    in WebStorage.setItem localStorage string itemString

setItemJson :: forall eff a b . (StorageKey a, EncodeJson b)
            => a -> b -> Eff (webStorage :: WebStorage | eff) Unit
setItemJson = setItemGeneric $ show <<< encodeJson

getItemGeneric :: forall eff a b . (StorageKey a)
               => (String -> Maybe b) -> a -> Eff (webStorage :: WebStorage | eff) (Maybe b)
getItemGeneric f x = do
    let string = storageKey x
    maybeStringItem <- WebStorage.getItem localStorage string
    case maybeStringItem of
        Nothing -> pure Nothing
        Just stringItem -> pure $ f stringItem

getItemJson :: forall eff a b . (StorageKey a, DecodeJson b)
            => a -> Eff (webStorage :: WebStorage | eff) (Maybe b)
getItemJson = getItemGeneric \stringItem ->
    let eitherItem = jsonParser stringItem >>= decodeJson
    in either (const Nothing) Just eitherItem
