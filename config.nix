#MC # config.nix
#MC
#MC 当初始化`nixpkgs`时，例如`pkgs = import <nixpkgs> {}`，
#MC `nixpkgs`的初始化代码会读取`~/.config/nixpkgs/config.nix`作为`nixpkgs.config`参数。
#MC 如果你对`nixpkgs`的初始化感兴趣，可以去看看这部分的源代码`<nixpkgs>/pkgs/top-level/impure.nix`。
#MC
#MC `config.nix`文件（即`nixpkgs.config`）接受的参数可以参考nixpkgs的官方文档的
#MC [config Options Reference](https://nixos.org/manual/nixpkgs/stable/#sec-config-options-reference)章节，
#MC 或是去看nixpkgs这部分的源码`<nixpkgs>/pkgs/top-level/config.nix`。
#MC
#MC 下面是添加了注解的我的`config.nix`：
{
  #MC 禁用安装非本地的包，比如禁止x86_64-linux的包被安装到aarch64-linux上。
  allowUnsupportedSystem = false;
  allowUnfree = true;
  packageOverrides = pkgs: rec {
    #MC 添加nix user repository (NUR)到nixpkgs里。
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      pkgs = pkgsu;
    };
    #MC 添加非稳定版的nixpkgs到nixpkgs里，
    #MC 比如非稳定版的hello可以通过`pkgs.pkgsu.hello`来访问。
    pkgsu = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {};
    #MC 添加flake-compat，用于在nix expression中使用flake的包
    flake-compat = import (builtins.fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/0f9255e01c2351cc7d116c072cb317785dd33b33.tar.gz";
      sha256 = "0m9grvfsbwmvgwaxvdzv6cmyvjnlww004gfxjvcl806ndqaxzy4j";
    });
  };
}
