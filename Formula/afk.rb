class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.43"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.43/afk-macos-arm64.tar.gz"
      sha256 "20a506265e46ac5b9935a9049e623d19961e59a68b0539c39aa9209afb95b6cc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.43/afk-linux-arm64.tar.gz"
      sha256 "c036a4ae4ef2ce12d24e4b5185b66e948427cb2d94e315ad293b6c9290b7ec1d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.43/afk-linux-amd64.tar.gz"
      sha256 "c4af43ae768e7d1b4c6c4d7ea5dcc6b936abd124295799147f6f1f2c49055fb1"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.43/afk-linux-amd64.tar.gz"
    sha256 "c4af43ae768e7d1b4c6c4d7ea5dcc6b936abd124295799147f6f1f2c49055fb1"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.43/afk-linux-arm64.tar.gz"
    sha256 "c036a4ae4ef2ce12d24e4b5185b66e948427cb2d94e315ad293b6c9290b7ec1d"
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
