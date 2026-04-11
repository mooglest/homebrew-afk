class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.66"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.66/afk-macos-arm64.tar.gz"
      sha256 "6f118562e756015b4279bc52773c95260bc7383a7c6b7083f0a7168ee0d5981c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.66/afk-linux-arm64.tar.gz"
      sha256 "a8889e24becb8df9bd64f2dcbbba5fb804837a522ca706704a9d13ba44b1f96c"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.66/afk-linux-amd64.tar.gz"
      sha256 "5bccdd27c3b0acec6323223e9a246326d5d4cd590796a166875641833983f5b7"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.66/afk-linux-amd64.tar.gz"
    sha256 "5bccdd27c3b0acec6323223e9a246326d5d4cd590796a166875641833983f5b7"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.66/afk-linux-arm64.tar.gz"
    sha256 "a8889e24becb8df9bd64f2dcbbba5fb804837a522ca706704a9d13ba44b1f96c"
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
