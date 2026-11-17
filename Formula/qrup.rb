class Qrup < Formula
  desc "Upload and download files over the local network via a QR code"
  homepage "https://github.com/totherush/qrup"
  version "0.2.1"
  license "MIT"

  # Standalone binaries from the GitHub release; they embed the Bun runtime and the web app.
  on_macos do
    on_arm do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-darwin-arm64.tar.gz"
      sha256 "c859495a6f276af92ebc7e7d21811accd39f6889ff045acfc221b71badbf8057"
    end
    on_intel do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-darwin-x64.tar.gz"
      sha256 "8fe8a2edd9e42fd410bb5a0ef6ccbb9ae60780150ffc8a4bd7a5f1d0ea9f3f1d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-linux-arm64.tar.gz"
      sha256 "37abfec11a6e30afd54079e6b32d6b260de63ac57a6d3042062cdae30f137a61"
    end
    on_intel do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-linux-x64.tar.gz"
      sha256 "bb8b0ba16da19018e1ece9fd4c639cc0784200656070ba4e01f8d41a1d8855a6"
    end
  end

  def install
    bin.install "qrup"
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
