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
  awscli2
  kubectl
  jq
  ];
  src = null; 
}
