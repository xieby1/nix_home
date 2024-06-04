#MC # 🐳Nix Docker🐋 for Multiple ISAs
#MC
#MC This script is inspired by https://github.com/nix-community/docker-nixpkgs/images/nix
#MC
#MC TODO: support multiple ISAs (currently only riscv64)
#MC currently: this riscv64 nix docker can `nix-env -iA nixpkgs.hello`,
#MC which is completely built from source including toolchains (stdenv) in riscv64.
let
  pkgs = import <nixpkgs> {};
  # pkgsCross = import <nixpkgs> {};
  pkgsCross = pkgs.pkgsCross.riscv64;
  name = "nix-${pkgsCross.stdenv.system}";
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
      ]) ++ [
        ./imageFiles
      ];
    };
    extraCommands = ''
      # for /usr/bin/env
      mkdir usr
      ln -s bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp
    '';
    config = {
      Cmd = [ "/bin/bash" ];
      Env = [
        "NIX_BUILD_SHELL=/bin/bash"
        "PAGER=cat"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "USER=root"
      ];
    };
  };
in pkgs.writeShellScriptBin "nix-docker-riscv64" ''
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


  # TODO
  BINFMTS=""
  for binfmt in /run/binfmt/*; do
      BINFMTS+=" -v $(realpath $binfmt):$binfmt"
  done

  containerName=${name}-$outHash
  # run container
  podman run -it \
    --name=$containerName \
    -v $(realpath /run/binfmt/riscv64-linux):/run/binfmt/riscv64-linux \
    --network=host \
    $imageName
  podman commit $containerName $imageName
  podman rm $containerName
''
