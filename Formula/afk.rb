class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.6/afk-macos-arm64.tar.gz"
      sha256 "2a31dcdca1355662fa0489361284c510dd7a30b2839fc2ff1513695d45d38f3e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/0.0.6/afk-linux-arm64.tar.gz"
      sha256 "9222ff1e301c68c3eb31b499baef261a9a01ec307520126ad48e6ab5b9bc49a8"
    else
      url "https://github.com/mooglest/afk/releases/download/0.0.6/afk-linux-amd64.tar.gz"
      sha256 "c0765eb337fceab5728e322fe92edd2715bd0bc03d5a9c2318702d62d98be271"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.6/afk-linux-amd64.tar.gz"
    sha256 "c0765eb337fceab5728e322fe92edd2715bd0bc03d5a9c2318702d62d98be271"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/afk/releases/download/0.0.6/afk-linux-arm64.tar.gz"
    sha256 "9222ff1e301c68c3eb31b499baef261a9a01ec307520126ad48e6ab5b9bc49a8"
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
