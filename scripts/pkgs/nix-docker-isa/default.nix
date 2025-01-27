#MC # 🐳Nix Docker🐋 for Multiple ISAs
#MC
#MC This script is inspired by https://github.com/nix-community/docker-nixpkgs/images/nix
#MC
#MC currently: this riscv64 nix docker can `nix-env -iA nixpkgs.hello/tmux` and so on,
#MC which is completely built from source including toolchains (stdenv) in x86/aarch64/riscv64/...
{ pkgs ? import <nixpkgs> {}
, pkgsCross ? pkgs
, useTmux ? true
}:
let
  name = "nix-docker-${pkgsCross.stdenv.system}";
  image = pkgs.dockerTools.buildImageWithNixDb {
    inherit name;
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = (with pkgsCross; [
        bashInteractive
        cacert
        coreutils
        file
        gitMinimal
        gnutar
        nix
        openssh
        vim
        wget
      ]
      ++ lib.optional useTmux (tmux.override {withSystemd=false;})
      ) ++ [
        ./imageFiles
      ];
    };
    extraCommands = ''
      # for /usr/bin/env
      mkdir usr
      ln -s bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp

      # need a HOME
      mkdir -vp root
    '';
    config = {
      Cmd = if useTmux
        then [ "/bin/tmux" ]
        else [ "/bin/bash" ];
      Env = [
        "NIX_BUILD_SHELL=/bin/bash"
        "PAGER=cat"
        "PATH=/bin"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "USER=root"
      ];
    };
  };
in pkgs.writeShellScriptBin name ''
  command -v podman &> /dev/null || echo "podman not found TODO: install" || exit 1

  outName="$(basename ${image})"
  outHash=$(echo "$outName" | cut -d - -f 1)
  imageName=localhost/${name}:$outHash

  # check whether image has been loaded
  podman images $imageName | grep ${name} | grep $outHash &> /dev/null
  # image has not been loaded, then load it
  if [[ $? != 0 ]]; then
    podman load -i ${image}
  fi

  BINFMTS=""
  for binfmt in /run/binfmt/*; do
      BINFMTS+=" -v $(realpath $binfmt):$binfmt"
  done

  containerName=${name}-$outHash
  # run container
  OPTS=(
    "--name=$containerName"
    "$BINFMTS"
    "--network=host"
    "-it"
    "$imageName"
  )
  eval "podman run ''${OPTS[@]}"
  podman commit $containerName $imageName
  podman rm $containerName
''
