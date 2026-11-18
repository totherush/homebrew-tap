class Qrup < Formula
  desc "Upload and download files over the local network via a QR code"
  homepage "https://github.com/totherush/qrup"
  version "0.2.2"
  license "MIT"

  # Standalone binaries from the GitHub release; they embed the Bun runtime and the web app.
  on_macos do
    on_arm do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-darwin-arm64.tar.gz"
      sha256 "fd5a374125cbfa2dcd9775d8fd351e50e67da48f5ae20c6c2b315190e9c428e3"
    end
    on_intel do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-darwin-x64.tar.gz"
      sha256 "f5b28ddd0f6049a5ea05fdc54ebc9fc6f2cf983f4a448a008ec831c9061f55ec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-linux-arm64.tar.gz"
      sha256 "030ec0a014c74601daa3e7c66dc47342837330aacb69735a272c750f07868780"
    end
    on_intel do
      url "https://github.com/totherush/qrup/releases/download/v#{version}/qrup-linux-x64.tar.gz"
      sha256 "eaeb249f640b23f2055ce3d41121fcd4b43509e71bb05208afa3bded871918a3"
    end
  end

  def install
    bin.install "qrup"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/qrup --version")

    port = free_port
    token = "brew-test-token"
    pid = spawn({ "QRUP_TOKEN" => token }, bin/"qrup", "--port", port.to_s, "--upload", testpath/"uploads")
    begin
      sleep 2
      url = "http://127.0.0.1:#{port}/api/files"
      # Requests need the access token from the QR code URL.
      assert_equal "401", shell_output("curl -s -o /dev/null -w '%{http_code}' #{url}")
      assert_match '"files"', shell_output("curl -s -H 'x-qrup-token: #{token}' #{url}")
      assert_path_exists testpath/"uploads"
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
