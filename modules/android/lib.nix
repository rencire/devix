rec {
  mergeTwoSets =
    {
      set1,
      set2,
      mergeFunc,
      prefix,
    }:
    builtins.foldl' (
      acc: key:
      acc
      // {
        # oldKey = set1.${key};
        ${key} = if set1 ? ${key} then mergeFunc prefix key set1.${key} set2.${key} else set2.${key};
        # ${key} = if set1 ? key then "lib.nix" else set2.${key};
        # ${key} = set1.${key};
        # ${key} = "${key}";
      }
    ) set1 (builtins.attrNames set2);

  mergeListOfSets =
    {
      attrSets,
      mergeFunc,
      prefix,
    }:
    builtins.foldl' (
      acc: current:
      mergeTwoSets {
        inherit mergeFunc prefix;
        set1 = acc;
        set2 = current;
      }
    ) { } attrSets;
}
