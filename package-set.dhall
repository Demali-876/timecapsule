let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.10.4-20240112/package-set.dhall sha256:7b24c36d46a2da005875922cb4425207ae4fae9214eb710f38a70ed69ce8146f
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  additions = [
      { name = "ICRC1"
      , version = "0.0.1"
      , repo = "https://github.com/icpi-icp/icrc1"
      , dependencies = [] : List Text
      }
  ] : List Package

let overrides = [] : List Package

in  upstream # additions # overrides
