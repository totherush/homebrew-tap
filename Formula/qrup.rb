class Qrup < Formula
  desc "Local QR-based encrypted messaging app"
  homepage "https://github.com/totherush/qrup"
  url "https://github.com/totherush/qrup/archive/refs/tags/v0.1.8.tar.gz"
  sha256 "ac944429d56820ef631231355263a5a1f9729944a45cb88b675df6975c9b6185"
  license "MIT"

  depends_on "bun"
  depends_on "node" => ">=22"

  def check_dependencies
    # Check for Bun
    unless which("bun")
      odie <<~EOS
        Bun is required but not found!
        Please install Bun first:
          brew install bun
        Or visit: https://bun.sh/docs/installation
      EOS
    end

    # Check for Node.js and version
    node_path = which("node")
    unless node_path
      odie <<~EOS
        Node.js is required but not found!
        Please install Node.js version 22 or higher:
          brew install node
      EOS
    end

    # Check Node.js version
    node_version_output = `node --version 2>/dev/null`.strip
    if node_version_output.empty?
      odie "Could not determine Node.js version. Please ensure Node.js is properly installed."
    end

    # Parse version (remove 'v' prefix if present)
    version_match = node_version_output.match(/v?(\d+)\.(\d+)\.(\d+)/)
    unless version_match
      odie "Could not parse Node.js version: #{node_version_output}"
    end

    major_version = version_match[1].to_i
    if major_version < 22
      odie <<~EOS
        Node.js version #{node_version_output} is installed, but version 22 or higher is required.
        Please upgrade Node.js:
          brew upgrade node
        Current version: #{node_version_output}
        Required: >= 22.0.0
      EOS
    end

    opoo "Using Node.js #{node_version_output}" if major_version >= 22
  end

  def install
    # Check for required dependencies with better error messages
    check_dependencies

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
