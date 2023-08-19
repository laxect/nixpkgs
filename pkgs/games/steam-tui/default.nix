{ lib
, rustPlatform
, steamcmd
, fetchFromGitHub
, steam-run
, runtimeShell
, withWine ? false
, wine
}:

rustPlatform.buildRustPackage rec {
  pname = "steam-tui";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "dmadisetti";
    repo = pname;
    rev = version;
    sha256 = "sha256-01vWrtpH4vP9EZ4/YEdUNFldcPqntqH5Pb8j5ovBvc8=";
  };

  cargoSha256 = "sha256-MN5x1b0kFJrxETZJhtI6qCRUpGPj0y+0XKW1VvIVFHk=";

  buildInputs = [ steamcmd ]
    ++ lib.optional withWine wine;

  preFixup = ''
    mv $out/bin/steam-tui $out/bin/.steam-tui-unwrapped
    cat > $out/bin/steam-tui <<EOF
    #!${runtimeShell}
    export PATH=${steamcmd}/bin:\$PATH
    exec ${steam-run}/bin/steam-run $out/bin/.steam-tui-unwrapped '\$@'
    EOF
    chmod +x $out/bin/steam-tui
  '';

  meta = with lib; {
    description = "Rust TUI client for steamcmd";
    homepage = "https://github.com/dmadisetti/steam-tui";
    license = licenses.mit;
    maintainers = with maintainers; [ lom ];
    # steam only supports that platform
    platforms = [ "x86_64-linux" ];
  };
}
