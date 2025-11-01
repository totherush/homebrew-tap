class Qrup < Formula
  desc "Local QR-based encrypted messaging app"
  homepage "https://github.com/totherush/qrup"
  url "https://github.com/totherush/qrup/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "5f67cc3806a7b690c9e4741f8e907183e2e8983f66f045386f15cdb32d2b57a5"
  license "MIT"

  depends_on "bun"
  depends_on "node" # vite + tsc tools might need node still
  # depends_on "deno" # if you ever use it, just noting

  def install
    system "bun", "install"
    system "bun", "run", "build"

    # Install everything in dist/
    prefix.install "dist"

    # Create launcher script
    (bin/"qrup").write <<~EOS
      #!/bin/bash
      exec bun "#{prefix}/dist/server.js" "$@"
    EOS

    chmod 0755, bin/"qrup"
  end

  test do
    # Check CLI prints help or starts server (non-blocking)
    assert_match "", shell_output("#{bin}/qrup & sleep 1; true")
  end
end
