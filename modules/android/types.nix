{ lib, ... }:
{
  version = lib.mkOptionType {
    name = "version";
    merge =
      loc: defs:
      let
        values = map (x: x.value) defs;
        # test = builtins.break;
      in
      # test;
      # "9.9.9.9";
      # if builtins.length values == 0 then
      #   "latest"
      # else
      # Return the newest value
      builtins.foldl' (a: b: if lib.versionOlder a b then b else a) (builtins.head values) (
        builtins.tail values
      );
    # TODO handle case where no values are here, so we add "latest"
  };
}
