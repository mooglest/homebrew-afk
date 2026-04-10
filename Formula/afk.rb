class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.63"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.63/afk-macos-arm64.tar.gz"
      sha256 "120c739d79a69a467cede1d003880e3026f606615d132e7ca1bf890a604929e1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.63/afk-linux-arm64.tar.gz"
      sha256 "a8768e94ae4a723934d02573041fd0d58334c65eba81f2077059ea0d66be46e3"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.63/afk-linux-amd64.tar.gz"
      sha256 "2f3cebbcefeeb0e2b3a9a1cca400a0dbae94b76001d1f3afb3455d87485e36fb"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.63/afk-linux-amd64.tar.gz"
    sha256 "2f3cebbcefeeb0e2b3a9a1cca400a0dbae94b76001d1f3afb3455d87485e36fb"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.63/afk-linux-arm64.tar.gz"
    sha256 "a8768e94ae4a723934d02573041fd0d58334c65eba81f2077059ea0d66be46e3"
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
