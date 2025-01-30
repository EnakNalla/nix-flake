{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    teamviewer
    keepass
    teams
    openvpn
  ];
}
