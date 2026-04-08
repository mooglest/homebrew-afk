class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.53"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-macos-arm64.tar.gz"
      sha256 "4afb03c8780b5eb111bd91e7f3129a9bf7e883ea2bb0099fedf029dab3b4f206"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
      sha256 "4127fb04b904bc75f26615b4075e8b9f46a762deaad5fd7d4b23e3fc716c28c3"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
      sha256 "f75c6e9276b0e021875d41225e1189a0e6754ec06f45681733cdccd531fed3fb"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
    sha256 "f75c6e9276b0e021875d41225e1189a0e6754ec06f45681733cdccd531fed3fb"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
    sha256 "4127fb04b904bc75f26615b4075e8b9f46a762deaad5fd7d4b23e3fc716c28c3"
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
