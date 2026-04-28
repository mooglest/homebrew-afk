class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.36"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.36/afk-macos-arm64.tar.gz"
      sha256 "08ca7759ab419da485dc41a7fe4095c27b5636837c01e5f82b550c73af88798e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.36/afk-linux-arm64.tar.gz"
      sha256 "14f0ad08930a64d7e4368010ad6cc9867e937000e3179a72bf66bb204e56302e"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.36/afk-linux-amd64.tar.gz"
      sha256 "b770a3cb65184a3ace506ad7e75579a2f57171031108fa81eead360d717bfafc"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.36/afk-linux-amd64.tar.gz"
    sha256 "b770a3cb65184a3ace506ad7e75579a2f57171031108fa81eead360d717bfafc"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.36/afk-linux-arm64.tar.gz"
    sha256 "14f0ad08930a64d7e4368010ad6cc9867e937000e3179a72bf66bb204e56302e"
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
