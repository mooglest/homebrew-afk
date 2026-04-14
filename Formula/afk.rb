class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.72"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.72/afk-macos-arm64.tar.gz"
      sha256 "e623ce1aedbb61c2e8f98283b8bc79e9220e1538cd71216ccf9a5492c42d256e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.72/afk-linux-arm64.tar.gz"
      sha256 "6862ea1f1bbe19f9dad39437a4731f2464d8fce675b30436f998b2e88e54cdd8"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.72/afk-linux-amd64.tar.gz"
      sha256 "12fbfec5e1d96ef0f84654a42be345d6943d1c573a6a808db8555b62471e1b9f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.72/afk-linux-amd64.tar.gz"
    sha256 "12fbfec5e1d96ef0f84654a42be345d6943d1c573a6a808db8555b62471e1b9f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.72/afk-linux-arm64.tar.gz"
    sha256 "6862ea1f1bbe19f9dad39437a4731f2464d8fce675b30436f998b2e88e54cdd8"
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
