{
  programs.alacritty = {
    enable = true;

    settings = {
      env.term = "xterm-256color";

      cursor.style.shape = "beam";
      cursor.vi_mode_style = {
        blinking = "off";
        shape = "Block";
      };

      window = {
        decorations = "buttonless";
        dynamic_title = true;
        dynamic_padding = true;
      };

      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";

      };
    };
  };
}
