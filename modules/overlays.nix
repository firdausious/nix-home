{ pkgs-unstable }:

final: prev:

{
  # Use python314 from unstable, but disable PyAV's import check on Darwin.
  # The package builds successfully and is then killed during the
  # pythonImportsCheck phase after installation.
  python314 = (pkgs-unstable.python314 or prev.python314).override {
    packageOverrides = pyfinal: pyprev: {
      av = pyprev.av.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
        pythonImportsCheck = [ ];
        nativeCheckInputs = [ ];
      });
      imageio = pyprev.imageio.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
        pythonImportsCheck = [ ];
        nativeCheckInputs = [ ];
      });
      scikit-image = pyprev.scikit-image.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
        pythonImportsCheck = [ ];
        nativeCheckInputs = [ ];
      });
      plotly = pyprev.plotly.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
        pythonImportsCheck = [ ];
        nativeCheckInputs = [ ];
      });
    };
  };

  # Development tools
  neovim = pkgs-unstable.neovim;
  dbmate = pkgs-unstable.dbmate;

  # Go
  go = pkgs-unstable.go;

  # Rust
  rustup = pkgs-unstable.rustup;

  # Java
  maven = pkgs-unstable.maven;
  gradle = pkgs-unstable.gradle;
  zulu25 = pkgs-unstable.zulu25;

  # Node.js ecosystem
  nodejs_24 = pkgs-unstable.nodejs_24;
  bun = pkgs-unstable.bun;

  # Infrastructure tools
  opencode = pkgs-unstable.opencode;
  claude-code = pkgs-unstable.claude-code;
  rtk = pkgs-unstable.rtk;
  skills = pkgs-unstable.skills;
  # ghostty = pkgs-unstable.ghostty;
  # moon = pkgs-unstable.moon;
  minio-client = pkgs-unstable.minio-client;
  railway = pkgs-unstable.railway;
  azure-cli = pkgs-unstable.azure-cli;
  awscli2 = pkgs-unstable.awscli2;
}
