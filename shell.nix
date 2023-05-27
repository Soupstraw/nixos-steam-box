with import <nixpkgs> {};
mkShell {
  buildInputs = [
    nixops
    nix
  ];
  shellHook = ''
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
  '';
}
