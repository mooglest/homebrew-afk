class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.71"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.71/afk-macos-arm64.tar.gz"
      sha256 "88fd0acbc1ce4245f31bc3a2a4b3ad70e93b29165fed880c8e0ea0cc984e4019"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.71/afk-linux-arm64.tar.gz"
      sha256 "a1cead207336b1ca1b8cb9b01dda6127b54d9793beba30536675c0b1b0172c5d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.71/afk-linux-amd64.tar.gz"
      sha256 "923e42fcf43ac09425f0d2d689dbc9bb89061f2bf7830864d6be0d6616f981ef"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.71/afk-linux-amd64.tar.gz"
    sha256 "923e42fcf43ac09425f0d2d689dbc9bb89061f2bf7830864d6be0d6616f981ef"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.71/afk-linux-arm64.tar.gz"
    sha256 "a1cead207336b1ca1b8cb9b01dda6127b54d9793beba30536675c0b1b0172c5d"
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
