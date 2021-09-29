let
  pkgs = import <nixpkgs> {};
in
  pkgs.fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "49df402f0762b34c88b01d183b9d217da117cc79";
    sha256 = "0fpvznwgb35fz1i7n76y3kx5mf8qafr5xma087a5hjj3ksxmbgmn";
  }