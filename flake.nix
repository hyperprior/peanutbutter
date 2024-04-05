{
  description = "nix flake for pocket size fund development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        pythonVersion = "3.12.2";
        pythonPackages = ps:
          with ps; [
          ];
        commonPackages = with pkgs; [
          git
          (python3.withPackages pythonPackages)
          python311Packages.pip
          python311Packages.setuptools
          python311Packages.ray
          uv
          starship
        ];

        darwinPackages = with pkgs; [];
        linuxPackages = with pkgs; [];

        pipelineExitHook = ''
          ${pip-freeze}/bin/pip-freeze
        '';

        pip-freeze = pkgs.writeShellScriptBin "pip-freeze" ''
          uv pip freeze | uv pip compile - -o requirements.txt
        '';

        scripts = [
          pip-freeze
        ];

        mkDevShell = pkgs.mkShell {
          nativeBuildInputs =
            commonPackages
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin darwinPackages
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxPackages;

          buildInputs = scripts;
          shellHook = ''
            alias pip="uv pip"
            cd pipelines
            uv venv
            source .venv/bin/activate
            uv pip install -r requirements.txt
          '';

          exitHook = ''
            pip-freeze
          '';

        };
      in {
        devShells.default = mkDevShell;
      }
    );
}
