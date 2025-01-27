{ lib
, rustPlatform
, fetchFromGitHub
}:
rustPlatform.buildRustPackage {
  name = "clashctl";

  src = fetchFromGitHub {
    # owner = "https://github.com/George-Miao/clashctl";
    owner = "George-Miao";
    repo = "clashctl";
    rev = "b09e1faf80f1a25fa855499d8b34d36491e5a081";
    hash = "sha256-c7y64SsZEKdC8+umCY8+XBwxAHxn4YpqR48ASbHpkdM=";
  };

  cargoHash = "sha256-2d+phmMJeHZsJy300GwUAnh8KTGzpHCCIg8x4Wr8ytE=";

  doCheck = false;

  meta = with lib; {
    description = "CLI for interacting with clash";
    homepage = "https://github.com/George-Miao/clashctl";
    license = licenses.mit;
    maintainers = with maintainers; [ xieby1 ];
  };
}
