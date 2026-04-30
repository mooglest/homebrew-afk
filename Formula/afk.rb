class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.2/afk-macos-arm64.tar.gz"
      sha256 "fced26773a9ad798420e8dc2a1e29c1d8692b77e551a4206c6b382d7030753e5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.2/afk-linux-arm64.tar.gz"
      sha256 "73e95c8c10f36699b71d755db38f016eb0d9eb034d0ce487a8cc61e6cf032171"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.2/afk-linux-amd64.tar.gz"
      sha256 "df436e2c3f9056ed0a12dd03d57db5f60a2c05954c05af734ad54d297f31fdf0"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.2/afk-linux-amd64.tar.gz"
    sha256 "df436e2c3f9056ed0a12dd03d57db5f60a2c05954c05af734ad54d297f31fdf0"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.2/afk-linux-arm64.tar.gz"
    sha256 "73e95c8c10f36699b71d755db38f016eb0d9eb034d0ce487a8cc61e6cf032171"
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
