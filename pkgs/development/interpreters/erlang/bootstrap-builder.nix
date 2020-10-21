{ pkgs, stdenv, fetchFromGitHub, makeWrapper, gawk, gnused, libxml2, libxslt
, perl, autoconf, parallelBuild ? false
, buildPackages }:

{ baseName ? "erlang", version, sha256 ? null, rev ? "OTP-${version}", src ?
  fetchFromGitHub {
    inherit rev sha256;
    owner = "erlang";
    repo = "otp";
  }, preUnpack ? "", postUnpack ? "", patches ? [ ], patchPhase ? ""
, prePatch ? "", postPatch ? "", configureFlags ? [ ], configurePhase ? ""
, preConfigure ? "", postConfigure ? "", buildPhase ? "", preBuild ? ""
, postBuild ? "", installPhase ? "", preInstall ? "", postInstall ? ""
, installTargets ? [ "bootstrap" ], checkPhase ? "", preCheck ? ""
, postCheck ? "", fixupPhase ? "", preFixup ? "", postFixup ? "", meta ? { } }:

let inherit (stdenv.lib) optional optionals optionalAttrs optionalString;

in stdenv.mkDerivation ({
  name = "${baseName}-${version}-bootstrap";

  inherit src version;

  nativeBuildInputs =
    [ autoconf makeWrapper buildPackages.perl buildPackages.libxslt libxml2 ];

  buildInputs = [ ];

  debugInfo = false;

  # On some machines, parallel build reliably crashes on `GEN    asn1ct_eval_ext.erl` step
  enableParallelBuilding = parallelBuild;

  postPatch = ''
    patchShebangs make
  '';

  preConfigure = ''
    ./otp_build autoconf
  '';

  configureFlags = [ "--enable-bootstrap-only" ] ++ configureFlags;

  postInstall = ''
    ln -s $out/lib/erlang/lib/erl_interface*/bin/erl_call $out/bin/erl_call
  '';

  # Some erlang bin/ scripts run sed and awk
  # postFixup = ''
  #   wrapProgram $out/lib/erlang/bin/erl --prefix PATH ":" "${gnused}/bin/"
  #   wrapProgram $out/lib/erlang/bin/start_erl --prefix PATH ":" "${
  #     stdenv.lib.makeBinPath [ gnused gawk ]
  #   }"
  # '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; ({
    homepage = "https://www.erlang.org/";
    downloadPage = "https://www.erlang.org/download.html";
    description = "Programming language used for massively scalable soft real-time systems";

    longDescription = ''
      Erlang is a programming language used to build massively scalable
      soft real-time systems with requirements on high availability.
      Some of its uses are in telecoms, banking, e-commerce, computer
      telephony and instant messaging. Erlang's runtime system has
      built-in support for concurrency, distribution and fault
      tolerance.
    '';

    platforms = platforms.unix;
    maintainers = with maintainers; [ sjmackenzie couchemar gleber ];
    license = licenses.asl20;
  } // meta);
}
// optionalAttrs (preUnpack != "")      { inherit preUnpack; }
// optionalAttrs (postUnpack != "")     { inherit postUnpack; }
// optionalAttrs (patches != [])        { inherit patches; }
// optionalAttrs (patchPhase != "")     { inherit patchPhase; }
// optionalAttrs (configurePhase != "") { inherit configurePhase; }
// optionalAttrs (preConfigure != "")   { inherit preConfigure; }
// optionalAttrs (postConfigure != "")  { inherit postConfigure; }
// optionalAttrs (buildPhase != "")     { inherit buildPhase; }
// optionalAttrs (preBuild != "")       { inherit preBuild; }
// optionalAttrs (postBuild != "")      { inherit postBuild; }
// optionalAttrs (checkPhase != "")     { inherit checkPhase; }
// optionalAttrs (preCheck != "")       { inherit preCheck; }
// optionalAttrs (postCheck != "")      { inherit postCheck; }
// optionalAttrs (installPhase != "")   { inherit installPhase; }
// optionalAttrs (installTargets != []) { inherit installTargets; }
// optionalAttrs (preInstall != "")     { inherit preInstall; }
// optionalAttrs (fixupPhase != "")     { inherit fixupPhase; }
// optionalAttrs (preFixup != "")       { inherit preFixup; }
// optionalAttrs (postFixup != "")      { inherit postFixup; }
)
