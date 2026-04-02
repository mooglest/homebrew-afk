class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.33"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.33/afk-macos-arm64.tar.gz"
      sha256 "5371fa14ceadf14db46a3c16e0cbed28e573cfaca8f57a099c77c77dc45faf04"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.33/afk-linux-arm64.tar.gz"
      sha256 "6d82d413a108f28571eeebe43e0bb21bdd8273c57fe560720a3a33b6298b048f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.33/afk-linux-amd64.tar.gz"
      sha256 "3019079cff176f56f54ba19bf2a09789d76a81d31925eb5637513e8005ec89dd"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.33/afk-linux-amd64.tar.gz"
    sha256 "3019079cff176f56f54ba19bf2a09789d76a81d31925eb5637513e8005ec89dd"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.33/afk-linux-arm64.tar.gz"
    sha256 "6d82d413a108f28571eeebe43e0bb21bdd8273c57fe560720a3a33b6298b048f"
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
