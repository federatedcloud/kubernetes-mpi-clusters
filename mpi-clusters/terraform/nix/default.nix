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
  kubectl
  google-cloud-sdk
  jq
  ];
  src = null; 
}
