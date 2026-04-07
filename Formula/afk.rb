class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.49"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-macos-arm64.tar.gz"
      sha256 "899cedee6f91518ee1dc23204f9c4f4dd03ef6ecc4d8c028a4e164fecef4259f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-arm64.tar.gz"
      sha256 "c2a01d9b8934bc7b31b34f6a4c487c9ef01ab3a76a3549aa230688cf92b6ea15"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-amd64.tar.gz"
      sha256 "ed1a17675b915401e1fdb8b6b8d58153eca8ab6e514bace71b05827729023d35"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-amd64.tar.gz"
    sha256 "ed1a17675b915401e1fdb8b6b8d58153eca8ab6e514bace71b05827729023d35"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.49/afk-linux-arm64.tar.gz"
    sha256 "c2a01d9b8934bc7b31b34f6a4c487c9ef01ab3a76a3549aa230688cf92b6ea15"
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
