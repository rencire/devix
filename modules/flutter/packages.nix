{
  packages = {
    flutter-proxy =
      pkgs:
      pkgs.stdenv.mkDerivation {
        pname = "my-escript";
        version = "1.0";
        src = ./.; # includes flutter-proxy.sh
        buildInputs = [ pkgs.flutter327 ];
        phases = [ "installPhase" ];
        installPhase = ''

          # Add flutter-proxy.sh
          mkdir -p $out/bin
          cp $src/flutter-proxy.sh $out/bin/
          chmod +x $out/bin/flutter-proxy.sh

          # Create main script that proxies to flutter-proxy.sh
          cat > $out/bin/flutter <<EOF
          #!${pkgs.bash}/bin/bash
          export PATH="${pkgs.flutter327}/bin:\$PATH"
          exec $out/bin/flutter-proxy.sh "\$@"
          EOF

          chmod +x $out/bin/flutter
        '';
      };

    # pkgs.writeShellScriptBin "flutter" ''
    #   export PATH="${pkgs.flutter327}/bin:$PATH"
    #   exec ${./flutter-proxy.sh} "$@"
    # '';
  };
}
