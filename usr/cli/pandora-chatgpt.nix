{ buildPythonPackage
, fetchPypi
, appdirs
, certifi
, flask
, flask-cors
, httpx
, loguru
, pyjwt
, pyperclip
, requests
, rich
, sentry-sdk
, waitress
, werkzeug
}:

buildPythonPackage rec {
  pname = "Pandora-ChatGPT";
  version = "1.2.5";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tfGqBRf/0VyaBuXsZEH8LwAuJYfk7oimY5Y0M1d/Qxs=";
  };
  doCheck = false;
  preBuild = ''
    # ignore version
    sed -i 's/\~=[^;]*//g' requirements.txt
  '';
  propagatedBuildInputs = [
    appdirs
    certifi
    flask
    flask-cors
    httpx
  ] ++ httpx.optional-dependencies.socks ++ [
    loguru
    pyjwt
  ] ++ pyjwt.optional-dependencies.crypto ++ [
    pyperclip
    requests
  ] ++ requests.optional-dependencies.socks ++ [
    rich
    sentry-sdk
    waitress
    werkzeug
    flask
  ] ++ flask.optional-dependencies.async;
}
