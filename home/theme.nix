{ pkgs, ... }: {
    home = {
        pointerCursor = {
            gtk.enable = true;
            name = "Dracula-cursors";
            package = pkgs.dracula-theme;
            size = 26;
        };
    };
}