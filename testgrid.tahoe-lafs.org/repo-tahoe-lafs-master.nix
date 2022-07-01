let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "0d5144842878070cd4610f0a5643c1fd28d2889c";
    sha256 = "Aa6jY4T1im4jhjHPZ22+zWeFgGXT0ehhynwn5tENX1M=";
  }
