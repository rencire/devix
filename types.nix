{ lib, ... }:
{
  debug = lib.mkOptionType {
    name = "debug";
    merge = loc: defs: defs.file;
  };
  version = lib.mkOptionType {
    name = "version";
    # TODO add a `isVersion` checker function
    # check = isVersion
    merge =
      loc: defs:
      let
        values = map (x: x.value) defs;
      in
      builtins.foldl' (a: b: if lib.versionOlder a b then b else a) (builtins.head values) (
        builtins.tail values
      );
  };
}
