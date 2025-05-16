{ lib, ... }:
rec {
  # Recursively adds "mkDefault" to all leaf nodes in attrSet, for each preset.
  # This is so we can support nested options.
  mkDefaultLeaves =
    attrs:
    lib.mapAttrs (
      k: v:
      # if builtins.isAttrs v then
      # mkDefaultLeaves v
      # else lib.mkDefault v

      if builtins.isAttrs v then
        # If the value is an attribute set, check for _value and _priority before recursing
        if builtins.hasAttr "_value" v && builtins.hasAttr "_priority" v then
          # If _value and _priority are present, apply mkOverride with _priority and _value
          lib.mkOverride v._priority v._value
        else
          # Otherwise, recurse deeper into the attribute set
          mkDefaultLeaves v
      else
        # If it's a simple value (no attribute set), apply mkDefault
        lib.mkDefault v

    ) attrs;

}
