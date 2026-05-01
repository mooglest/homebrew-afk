class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.8"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.8/afk-macos-arm64.tar.gz"
      sha256 "1f911f0def216d7e7cd4f409577cfba7427f2aead2927323b309bcc7fe822b4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.8/afk-linux-arm64.tar.gz"
      sha256 "ca17e3ae602a3f68771731c1a2b7902af9f5c4e48cfe3563296936d3f886e725"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.8/afk-linux-amd64.tar.gz"
      sha256 "53f50c5885d5751fa1ce2d246a7c63b852725589f6e4cf6ce4e900f7fec0b3eb"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.8/afk-linux-amd64.tar.gz"
    sha256 "53f50c5885d5751fa1ce2d246a7c63b852725589f6e4cf6ce4e900f7fec0b3eb"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.8/afk-linux-arm64.tar.gz"
    sha256 "ca17e3ae602a3f68771731c1a2b7902af9f5c4e48cfe3563296936d3f886e725"
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
