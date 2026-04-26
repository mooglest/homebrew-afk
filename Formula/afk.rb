class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.33"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.33/afk-macos-arm64.tar.gz"
      sha256 "3e21700ac51cf137ac1d4810674e0d7d288b3bc842c79263982dd3cb103a6ae6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.33/afk-linux-arm64.tar.gz"
      sha256 "a14d7b087cc3453349970df21c015c95e577b4337aac5cba1869cc263642196d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.33/afk-linux-amd64.tar.gz"
      sha256 "a3a84c4fe0d268ed983e9f67fcc95dfa427c2393cb094c9931f3d5fd534c2c2c"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.33/afk-linux-amd64.tar.gz"
    sha256 "a3a84c4fe0d268ed983e9f67fcc95dfa427c2393cb094c9931f3d5fd534c2c2c"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.33/afk-linux-arm64.tar.gz"
    sha256 "a14d7b087cc3453349970df21c015c95e577b4337aac5cba1869cc263642196d"
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
