class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.6/afk-macos-arm64.tar.gz"
      sha256 "e44340f1edbf6c2ab0d28bf51b078a41f09ccabcc6545d840f3abe31bf0c5ba1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.6/afk-linux-arm64.tar.gz"
      sha256 "a5f3938bab1ec35c028ad865ed8416426808ec97cc20ca6d04458d78b18d7d44"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.6/afk-linux-amd64.tar.gz"
      sha256 "6f1f7a43ce2c79bbcd13f16d5328e8d19ebcf884b25f6ee981259b1e5eb7c31e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.6/afk-linux-amd64.tar.gz"
    sha256 "6f1f7a43ce2c79bbcd13f16d5328e8d19ebcf884b25f6ee981259b1e5eb7c31e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.6/afk-linux-arm64.tar.gz"
    sha256 "a5f3938bab1ec35c028ad865ed8416426808ec97cc20ca6d04458d78b18d7d44"
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
