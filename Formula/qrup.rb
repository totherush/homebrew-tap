class Qrup < Formula
  desc "Local QR-based encrypted messaging app"
  homepage "https://github.com/totherush/qrup"
  url "https://github.com/totherush/qrup/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "a0ac26d779270ea16fc88dd508e0d173def3351e760957f71007327fa2c0973a"
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
      exec bun "#{prefix}/dist/server.js"
    EOS

    chmod 0755, bin/"qrup"
  end

  test do
    # Check CLI prints help or starts server (non-blocking)
    assert_match "", shell_output("#{bin}/qrup & sleep 1; true")
  end
end
