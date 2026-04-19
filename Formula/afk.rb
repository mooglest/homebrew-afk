class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.12"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.12/afk-macos-arm64.tar.gz"
      sha256 "f6354b1fc0c2399f6c4f5f3259a540d34aea8ff4d957d618f1cb55964f439dc3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.12/afk-linux-arm64.tar.gz"
      sha256 "f664818beaea50de539218b2d6c24103905c9c572b0352ad326aaf91bede511f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.12/afk-linux-amd64.tar.gz"
      sha256 "a29aaeec976c339c91859aec5401388e24bfe8c953c277c794144bacdcec8398"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.12/afk-linux-amd64.tar.gz"
    sha256 "a29aaeec976c339c91859aec5401388e24bfe8c953c277c794144bacdcec8398"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.12/afk-linux-arm64.tar.gz"
    sha256 "f664818beaea50de539218b2d6c24103905c9c572b0352ad326aaf91bede511f"
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
