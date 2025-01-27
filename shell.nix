#MC # shell.nix
#MC
#MC 这个shell.nix用于创建编译我的[nix_config仓库](https://github.com/xieby1/nix_config)的
#MC [GitHub Pages](https://xieby1.github.io/nix_config/)的环境。
#MC GitHub Pages的构建主要由`markcode`和`mdbook`这两个工具支持。
#MC
#MC * [`markcode`](https://github.com/xieby1/markcode)
#MC   是我为了方便在源文件里内嵌文档，写的一个小工具。
#MC   它能将源文件中带有特殊标记的注释抽取出，成为markdown文件。
#MC   nix_config仓库的几乎所有文档都内嵌在.nix文件中，
#MC   并都是通过`markcode`从.nix文件抽取出来。
#MC * [`mdbook`](https://github.com/rust-lang/mdBook)
#MC   是一个非常纯粹且好用的静态网页生成框架，负责将markdown转换成网页。
#MC   因为第一次阅读[nix官方文档](https://nixos.org/manual/nix/stable/introduction.html)时就喜欢上了这个文档框架，
#MC   所以我也采用的`mdbook`作为我的nix_config的文档框架。

let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
  markcode = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "xieby1";
      repo = "markcode";
      rev = "1c414aca28db7f2727f6da118f4e914743780ad0";
      hash = "sha256-B5kmpAIyUihlBqk7oNAdqBmdfCajCmleKBTgLyy0NqU=";
    }
  ) {};
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    mdbook
    markcode
  ];
}
