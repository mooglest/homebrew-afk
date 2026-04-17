class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.104"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.104/afk-macos-arm64.tar.gz"
      sha256 "f847f1a152ef9504a8f86dfce6f01daf2b056cea457db9ddf85585ff24532440"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.104/afk-linux-arm64.tar.gz"
      sha256 "56df50b49a880cd4d6210e2c68227978f1e7e0cca5fae87be7039ecc033a03f0"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.104/afk-linux-amd64.tar.gz"
      sha256 "25bd59f2eb68067c4da902d3ecb606104a04847e1d533da2beb72b0c57ed3c6e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.104/afk-linux-amd64.tar.gz"
    sha256 "25bd59f2eb68067c4da902d3ecb606104a04847e1d533da2beb72b0c57ed3c6e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.104/afk-linux-arm64.tar.gz"
    sha256 "56df50b49a880cd4d6210e2c68227978f1e7e0cca5fae87be7039ecc033a03f0"
  end

  def install
    if OS.mac?
      libexec.install "afk" => "afk-macos"
      resource("afk-linux-amd64").stage do
        libexec.install "afk" => "afk-linux-amd64"
      end
      resource("afk-linux-arm64").stage do
        libexec.install "afk" => "afk-linux-arm64"
      end
      (bin/"afk").write_env_script libexec/"afk-macos",
        AFK_DOCKER_BINARY_AMD64: opt_libexec/"afk-linux-amd64",
        AFK_DOCKER_BINARY_ARM64: opt_libexec/"afk-linux-arm64",
        AFK_DOCKER_BINARY: opt_libexec/"afk-linux-amd64"
    else
      bin.install "afk"
    end
  end

  def caveats
    <<~EOS
      AFK stores user data in ~/.afk
      The directory will be created automatically on first run.

      Please login to https://afk.mooglest.com and update the api_key in ~/.afk/config
    EOS
  end

  service do
    run [opt_bin/"afk", "daemon"]
    keep_alive true
    log_path var/"log/afk.log"
    error_log_path var/"log/afk.log"
    working_dir ENV["HOME"]
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/afk --help")
  end
end
