let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "45c564f3c8d3f4353c55dc357b349e522285bace";
    sha256 = "1jqymapsznwijr1b2jpn94vsr0vrq5dgj5ykkfpd9kh2m37yg13l";
  }