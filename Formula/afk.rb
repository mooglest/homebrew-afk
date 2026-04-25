class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.32"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.32/afk-macos-arm64.tar.gz"
      sha256 "476cf55969d534cf3712d35568fe0c21823b9f36393c0a67bd6130ac29d5763f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.32/afk-linux-arm64.tar.gz"
      sha256 "aacf1405442435f35c17575c9f406b6fdb84e282c3f7e7e5b5c93e1399beddce"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.32/afk-linux-amd64.tar.gz"
      sha256 "45af0c3ee9845f824db963039846b7004f6cb8133308c8e0d7d6e1cb1dabc9a7"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.32/afk-linux-amd64.tar.gz"
    sha256 "45af0c3ee9845f824db963039846b7004f6cb8133308c8e0d7d6e1cb1dabc9a7"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.32/afk-linux-arm64.tar.gz"
    sha256 "aacf1405442435f35c17575c9f406b6fdb84e282c3f7e7e5b5c93e1399beddce"
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
