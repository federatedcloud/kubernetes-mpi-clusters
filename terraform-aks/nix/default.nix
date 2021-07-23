with import <nixpkgs> {}; 
let 
  pkgs = import <nixpkgs> {}; 
in 
stdenv.mkDerivation {
  name = "gcpBuildEnv"; 
  buildInputs = [
  nix 
  bash 
  
  # terraform and kubernetes required packages
  azure-cli
  kubectl
  jq
  ];
  src = null; 
}
