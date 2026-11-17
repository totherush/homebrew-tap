class Qrup < Formula
  desc "Upload and download files over the local network via a QR code"
  homepage "https://github.com/totherush/qrup"
  url "https://github.com/totherush/qrup/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "9062a0282529da17b7a7568a628a2b4a92577a8a76ff77d033a7f1e20118c954"
  license "MIT"

  depends_on "bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    system "bun", "run", "build"

    # dist/server.js bundles all server dependencies; dist/client is the built web app.
    libexec.install "dist"

    (bin/"qrup").write <<~EOS
      #!/bin/bash
      exec "#{Formula["bun"].opt_bin}/bun" "#{libexec}/dist/server.js" "$@"
    EOS
  end

  test do
    port = free_port
    pid = spawn bin/"qrup", "--port", port.to_s, "--upload", testpath/"uploads"
    begin
      sleep 2
      assert_match '"files"', shell_output("curl -s http://127.0.0.1:#{port}/api/files")
      assert_path_exists testpath/"uploads"
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
