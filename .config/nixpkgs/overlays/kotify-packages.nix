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
    pgformatter = self.pgformatter;
    pre-commit = self.pre-commit;
    ripgrep = self.ripgrep;
    rsync = self.rsync;
    shellcheck = self.shellcheck;
    sqlite = self.sqlite;
    tmux = self.tmux;
    watchman = self.watchman;
    ### cloud
    amazon-ecr-credential-helper = self.amazon-ecr-credential-helper;
    aws-vault = self.aws-vault;
    awscli2 = self.awscli2;
    chamber = self.chamber;
    ### js
    nodejs-16_x = self.nodejs-16_x;
    npm-check-updates = self.nodePackages.npm-check-updates;
    yarn = self.yarn;
    pnpm = self.nodePackages.pnpm;
    ### python
    black = self.black;
    flake8 = self.python39Packages.flake8;
    isort = self.python39Packages.isort;
    pip = self.python39Packages.pip;
    python39 = self.python39;
    chromedriver = super.chromedriver.overrideAttrs (oldAttrs: {
      # in original deriviation linux version is linked to dependencies
      # that leads to installation of lot's of basic linux libraries
      # we skip that and just use original binary as we do on macos
      installPhase = "install -m755 -D chromedriver $out/bin/chromedriver";
    });
  } // super.lib.optionalAttrs (super.stdenv.isx86_64 || !super.stdenv.isDarwin) {
    ### broken on Apple Silicon
    packer = self.packer;
    ssm-session-manager-plugin = self.ssm-session-manager-plugin;
  } // super.lib.optionalAttrs super.stdenv.isDarwin {
    ### macos only
    reattach-to-user-namespace = self.reattach-to-user-namespace;
    watch = self.watch;
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
