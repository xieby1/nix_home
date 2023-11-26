{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    file
    wget
    fzf
    linuxPackages.perf
  ];

  # neovim
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  # ssh
  services.openssh.enable = true;

  # refers to https://www.golinuxcloud.com/automount-file-system-systemd-rhel-centos-7-8/
  systemd.mounts = if "${config.networking.hostName}" == "jumper"
  then [{
    enable = true;
    # [Unit]
    description = "My SD Card";
    unitConfig = {
      DefaultDependencies = "no";
      Conflicts = "umount.target";
    };
    before = ["local-fs.target" "umount.target"];
    after = ["swap.target"];
    # [Mount]
    what = "/dev/disk/by-label/home";
    where = "/home";
    type = "ext4";
    options = "defaults";
    # [Install]
    wantedBy = ["multi-user.target"];
  }] else [];

  systemd.automounts = if "${config.networking.hostName}" == "jumper"
  then [{
    enable = true;
    # [Unit]
    description = "automount sdcard";
    # [Automount]
    where = "/home";
    # [Install]
    wantedBy = ["multi-user.target"];
  }] else [];

  boot.supportedFilesystems = [ "ntfs" ];

  virtualisation.podman.enable = true;

  boot.binfmt.registrations = {
    aarch64-linux = {
      interpreter = "${pkgs.qemu}/bin/qemu-aarch64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
      mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
    };
    riscv64-linux = {
      interpreter = "${pkgs.qemu}/bin/qemu-riscv64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'';
      mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    };
  };

  # Make sure devdoc outputs are installed.
  documentation.dev.enable = true;
  # Make sure legacy path is installed as well.
  environment.pathsToLink = [ "/share/gtk-doc" ];

  programs.adb.enable = true;
  users.users.xieby1.extraGroups = ["adbusers"];
}
