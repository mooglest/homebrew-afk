class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.87"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.87/afk-macos-arm64.tar.gz"
      sha256 "03f5a6b53e19c46643710061127240d8efb5f7f6592d4d34f9b35a1d9f4a8d0b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.87/afk-linux-arm64.tar.gz"
      sha256 "17e0f7c6bea87c58435bd746f9700ae4ce59856a66ac0e4eb262190ff2da43e6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.87/afk-linux-amd64.tar.gz"
      sha256 "dac295f8da5f78650502a27fcb9b9cf51edd0e3c82bd49eb22427b889d01aea8"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.87/afk-linux-amd64.tar.gz"
    sha256 "dac295f8da5f78650502a27fcb9b9cf51edd0e3c82bd49eb22427b889d01aea8"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.87/afk-linux-arm64.tar.gz"
    sha256 "17e0f7c6bea87c58435bd746f9700ae4ce59856a66ac0e4eb262190ff2da43e6"
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
