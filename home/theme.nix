{ pkgs, ... }:
{
  # TODO: doesn't seem to be correct
  home = {
    pointerCursor = {
      gtk.enable = true;
      name = "Catppuccin-Frappe-Dark";
      package = pkgs.catppuccin-cursors;
      size = 26;
    };
  };
}
