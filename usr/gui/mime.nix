# https://nixos.org/manual/nixos/stable/#sec-writing-modules
# refers to syncthing module

# list options:
#   home-manager option xdg.mime.types.\"*\"
#   nixos option
{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.xdg.mime.types;
in
{
  options = {
    xdg.mime.types = mkOption {
      default = {};
      description = "Set MIME types and default applications.";
      example = ''
        xdg.mime.types.dot = {
          name = "graphviz-dot";
          type = "text/graphviz-dot";
          pattern = "*.dot";
          defaultApp = "xdot.desktop";
        };
      '';
      type = types.attrsOf (types.submodule ({name, ...}:
      {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            description = "The name of the xml file.";
          };
          type = mkOption {
            type = types.str;
            default = "";
            description = "The mime-type.";
          };
          pattern = mkOption {
            type = types.str;
            default = "";
            description = "The glob pattern.";
          };
          defaultApp = mkOption {
            type = types.str;
            default = "";
            description = "Default application for opening this MIME type.";
          };
        };
      }));
    };
  };

  # builtins.mapAttrs (n: v: {wang=v.miao;}) {file1={miao=1;}; file2={miao=2;};}
  # => {file1={wang=1;}; file2={wang=2;};}
  config = {
    home.file = builtins.mapAttrs (n: v: {
      text = ''
        <?xml version="1.0"?>
        <mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
          <mime-type type="${v.type}">
            <glob pattern="${v.pattern}"/>
          </mime-type>
        </mime-info>
      '';
      target = ".local/share/mime-types/${v.name}.xml";
      onChange = ''
        ${pkgs.xdg-utils}/bin/xdg-mime install ~/.local/share/mime-types/${v.name}.xml
        ${pkgs.xdg-utils}/bin/xdg-mime default ${v.defaultApp} ${v.type}
      '';
    }) cfg;
  };
}
