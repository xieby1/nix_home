let
  flake-compat = import (builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/0f9255e01c2351cc7d116c072cb317785dd33b33.tar.gz";
    sha256 = "0m9grvfsbwmvgwaxvdzv6cmyvjnlww004gfxjvcl806ndqaxzy4j";
  });
  nix2nvchad = flake-compat {
    src=  builtins.fetchTarball {
      url = "https://github.com/nix-community/nix4nvchad/archive/360ff667893eab066b3db906a856de2956fc710e.tar.gz";
      sha256 = "01gvcg7nhzpizp4yzvww2x42i1ifsb7sygfwmqzrshqz47p1ir5y";
    };
  };
in nix2nvchad.defaultNix.packages."${builtins.currentSystem}".default
