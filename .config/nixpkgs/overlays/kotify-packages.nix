self: super:

{
  userPackages = super.userPackages or { } // {
    ### general
    direnv = self.direnv;
    docker-compose = self.docker-compose;
    geckodriver = self.geckodriver;
    gh = self.gitAndTools.gh;
    git = self.git;
    git-lfs = self.git-lfs;
    htop = self.htop;
    jq = self.jq;
    overmind = self.overmind;
    pre-commit = self.pre-commit;
    ripgrep = self.ripgrep;
    rsync = self.rsync;
    shellcheck = self.shellcheck;
    sqlite = self.sqlite;
    tmux = self.tmux;
    watchman = self.watchman;
    ### cloud
    ssm-session-manager-plugin = self.ssm-session-manager-plugin;
    amazon-ecr-credential-helper = self.amazon-ecr-credential-helper;
    aws-vault = self.aws-vault;
    awscli2 = self.awscli2;
    chamber = self.chamber;
    packer = self.packer;
    ### js
    nodejs-18_x = self.nodejs-18_x;
    pnpm = self.nodePackages.pnpm;
    ### python
    black = self.black;
    ruff = self.ruff;
    pip = self.python310Packages.pip;
    python310 = self.python310;
    chromedriver = super.chromedriver.overrideAttrs (oldAttrs: {
      installPhase = "install -m755 -D chromedriver $out/bin/chromedriver";
    });
  } // super.lib.optionalAttrs super.stdenv.isDarwin {
    ### macos only
    reattach-to-user-namespace = self.reattach-to-user-namespace;
    watch = self.watch;
    tree = self.tree;
  } // {
    ### system
    inherit (self) cacert nix;

    nix-rebuild = super.writeScriptBin "nix-rebuild" ''
      #!${super.stdenv.shell}
      set -e
      if ! command -v nix-env &>/dev/null; then
        echo "warning: nix-env was not found in PATH, add nix to userPackages" >&2
        PATH=${self.nix}/bin:$PATH
      fi
      IFS=- read -r _ oldGen _ <<<"$(readlink "$(readlink ~/.nix-profile)")"
      oldVersions=$(readlink ~/.nix-profile/package_versions || echo "/dev/null")
      nix-env -f '<nixpkgs>' -r -iA userPackages "$@"
      IFS=- read -r _ newGen _ <<<"$(readlink "$(readlink ~/.nix-profile)")"
      ${self.diffutils}/bin/diff --color -u --label "generation $oldGen" $oldVersions \
        --label "generation $newGen" ~/.nix-profile/package_versions \
        || true
    '';

    packageVersions =
      let
        versions = super.lib.attrsets.mapAttrsToList (_: pkg: pkg.name) self.userPackages;
        versionText = super.lib.strings.concatMapStrings (s: s + "\n") versions;
      in
      super.writeTextDir "package_versions" versionText;
  };
}
