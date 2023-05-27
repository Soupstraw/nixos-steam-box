{
  network.description = "telku";
  network.enableRollback = true;
  machine = 
    { config, pkgs, ... }:
    { imports = [
        ./configuration.nix
      ];
    deployment.targetHost = "telku.lan";
    };
}
