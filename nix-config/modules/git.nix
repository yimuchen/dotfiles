{ pkgs, config, ... }: {
  # Configurations for git
  programs.git = {
    enable = true;
    ignores = [ "*~" "*.swp" "*.so" "__pycache__" "*.o" ];
    userEmail = "enochnotsocool@gmail.com";
    userName = ''Yi-Mu "Enoch" Chen'';
  };

  # Additional helper tools for working with git
  home.packages = [ pkgs.lazygit pkgs.tokei ];
}
