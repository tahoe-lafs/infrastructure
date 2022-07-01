let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "eaf111ffa06ca80532e873180251e10a5b8fb837";
    sha256 = "Aa6jY4T1im4jhjHPZ22+zWeFgGXT0ehhynwn5tENX1M=";
  }
