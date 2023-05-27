rec {
  stable = builtins.fetchGit {
    name = "nixos-22.11";
    url = "https://github.com/nixos/nixpkgs/";
    # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-19.09`
    ref = "refs/tags/22.11";
  };
  unstable = builtins.fetchGit {
    name = "nixos-unstable";
    url = "https://github.com/nixos/nixpkgs/";
    # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
    ref = "master";
  };
}
