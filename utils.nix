{ lib, ... }:
rec {
  # addOverrides wraps the values of a configuration (attribute set) with
  # a call to mkOverride.
  # i.e., it transforms the leaf nodes of the attrset tree
  # from `<some_value>` to `mkOverride <priority> <some_value>`.
  #
  # ```
  #
  # p1 = {
  #   "a" = 1;
  #   "b" = {
  #       "c" = 2;
  #    }
  # }
  #
  # p2 = addOverrides 100 p1
  #
  # # value of p2:
  # {
  #    "a" = mkOverride 100 1;
  #    "b" = {
  #       "c" = mkOverride 100 2;
  #    };
  # }
  #
  #
  # ```
  #
  # We can also specify specific priorities for value, instead of using
  # `priority` for all the values. See usage of `_priority`:
  #
  # ```
  # p3 = {
  #   "d" = 1;
  #   "e" = {
  #       _value = 2;
  #       _priority = 50;
  #    }
  # }
  #
  # p4 = addOverrides 100 p1
  #
  # # value of p4:
  # {
  #    "d" = mkOverride 100 1;
  #    "e" = mkOverride 50 2;
  # }
  #
  # ```

  addOverrides =
    nullPriority: nonNullPriority: cfg:
    lib.mapAttrs (
      k: v:
      if builtins.isAttrs v then
        # If the value is an attribute set, check for _value and _priority before recursing
        if builtins.hasAttr "_value" v && builtins.hasAttr "_priority" v then
          # If _value and _priority are present, apply mkOverride with _priority and _value.
          lib.mkOverride v._priority v._value
        else
          # Otherwise, recurse deeper into the attribute set
          addOverrides nullPriority nonNullPriority v
      else
      # If it's a simple value (no attribute set), apply mkOverride at `priority` level
      if v == null then
        lib.mkOverride nullPriority v
      else
        lib.mkOverride nonNullPriority v

    ) cfg;

  # Note:
  # Set null to relatively low priority of 1000 (same as mkDefault)
  mkPresetWithNulls = priority: cfg: addOverrides 1000 priority cfg;

  # Inteneded to ttake in cfg that doesn't have nulls.
  mkPreset =
    priority: cfg:
    lib.mapAttrs (
      k: v:
      if builtins.isAttrs v then
        # If the value is an attribute set, check for _value and _priority before recursing
        if builtins.hasAttr "_value" v && builtins.hasAttr "_priority" v then
          # If _value and _priority are present, apply mkOverride with _priority and _value.
          lib.mkOverride v._priority v._value
        else
          # Otherwise, recurse deeper into the attribute set
          mkPreset priority v
      else
        lib.mkOverride priority v

    ) cfg;

  removeNullsAndEmptySets =
    attrs:
    lib.filterAttrs (_: v: v != null && (!lib.isAttrs v || v != { })) (
      lib.mapAttrs (_: v: if lib.isAttrs v then removeNullsAndEmptySets v else v) attrs
    );

  # Takes in an typical options set from a module, and creates a duplicate
  # of the options, with addition of making it nullable.
  makeNullableOptionsRecursive =
    opts:
    let
      isOption = v: lib.isAttrs v && (v._type or null) == "option";
      isNullableType = type: type.name == "nullOr";

      makeNullableOption =
        opt:
        let
          newType = if isNullableType opt.type then opt.type else lib.types.nullOr opt.type;
        in
        opt
        // {
          type = newType;
          default = null;
        };
    in
    lib.mapAttrs (
      _name: val:
      if isOption val then
        makeNullableOption val
      else if lib.isAttrs val then
        makeNullableOptionsRecursive val
      else
        val
    ) opts;

  # # Recursively adds "mkDefault" to all leaf nodes in attrSet, for each preset.
  # # This is so we can support nested options.
  # mkDefaultLeaves =
  #   attrs:
  #   lib.mapAttrs (
  #     k: v:
  #     # if builtins.isAttrs v then
  #     # mkDefaultLeaves v
  #     # else lib.mkDefault v

  #     if builtins.isAttrs v then
  #       # If the value is an attribute set, check for _value and _priority before recursing
  #       if builtins.hasAttr "_value" v && builtins.hasAttr "_priority" v then
  #         # If _value and _priority are present, apply mkOverride with _priority and _value
  #         lib.mkOverride v._priority v._value
  #       else
  #         # Otherwise, recurse deeper into the attribute set
  #         mkDefaultLeaves v
  #     else
  #       # If it's a simple value (no attribute set), apply mkDefault
  #       lib.mkDefault v

  #   ) attrs;

}
