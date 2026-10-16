# The zigdoc package. The Zig dependencies come from build.zig.zon.nix
# (`just zon2nix` regenerates it after a dependency bump), so the build needs
# no network.
{
  lib,
  stdenv,
  callPackage,
  zig_0_16,
}:
stdenv.mkDerivation {
  pname = "zigdoc";
  version = "0.5.1";
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../build.zig
      ../build.zig.zon
      ../build_readme.zig
      ../src
    ];
  };
  nativeBuildInputs = [ zig_0_16.hook ];
  zigBuildFlags = [
    "--system"
    "${callPackage ../build.zig.zon.nix { }}"
  ];
  meta = {
    description = "A command-line tool to view documentation for Zig standard library symbols";
    homepage = "https://github.com/rockorager/zigdoc";
    license = lib.licenses.mit;
    mainProgram = "zigdoc";
    platforms = lib.platforms.unix;
  };
}
