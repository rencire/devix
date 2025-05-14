rec {
  mergeTwoSets =
    {
      set1,
      set2,
      mergeFunc,
    }:
    builtins.foldl' (
      acc: key:
      acc
      // {
        # oldKey = set1.${key};
        ${key} = if set1 ? ${key} then mergeFunc key set1.${key} set2.${key} else set2.${key};
        # ${key} = if set1 ? key then "lib.nix" else set2.${key};
        # ${key} = set1.${key};
        # ${key} = "${key}";
      }
    ) set1 (builtins.attrNames set2);

  mergeListOfSets =
    { attrSets, mergeFunc }:
    builtins.foldl' (
      acc: current:
      mergeTwoSets {
        inherit mergeFunc;
        set1 = acc;
        set2 = current;
      }
    ) { } attrSets;
}
