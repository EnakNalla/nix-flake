{ config, ...}:
{
  home.file.".ideavimrc".source = ./ideavimrc;

  home.file.".config/sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };

  home.file.".config/aerospace/aerospace.toml".source = ./aerospace.toml;

  home.file.".config/wall.png".source = ./wall.png;

  # todo make my neovim config a git submodule and try this out of store symlink buisness
  # home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ./nvim;
}
