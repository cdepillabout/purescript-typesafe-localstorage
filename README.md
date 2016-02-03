
purescript-typesafe-localstorage
================================

[![Build
Status](https://travis-ci.org/cdepillabout/purescript-typesafe-localstorage.svg)](https://travis-ci.org/cdepillabout/purescript-typesafe-localstorage)

Typesafe wrappers about the localstorage api.

### Installing

```sh
$ npm install bower
$ ./node_modules/.bin/bower install --save purescript-typesafe-localstorage
```

### Building / Testing

```sh
$ pulp build
$ pulp test
```

### Usage

```purescript
newtype Token = Token String

unToken :: Token -> String
unToken (Token t) = t

data TokenKey = TokenKey

instance storageKeyTokenKey :: StorageKey TokenKey where storageKey TokenKey = "token"

instance canStoreToken :: CanStore TokenKey Token where
    -- setItem :: forall eff . TokenKey -> Token -> Eff (webStorage :: WebStorage | eff) Unit
    setItem = setItemGeneric unToken

    -- getItem :: forall eff . TokenKey -> Eff (webStorage :: WebStorage | eff) (Maybe Token)
    getItem = getItemGeneric (Just <<< Token)
```
