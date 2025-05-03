pkgs:
pkgs.writeShellScriptBin "flutter" ''
  export PATH="${pkgs.flutter327}/bin:$PATH"
  exec ${./flutter-proxy.sh} "$@"
''
