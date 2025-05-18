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
  mkPreset = priority: cfg: addOverrides 1000 priority cfg;

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
