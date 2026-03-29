class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.17"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.17/afk-macos-arm64.tar.gz"
      sha256 "6098160ba401d6f95f2bf56fdbfa619dc2fc8164b318bf0a4c96a298676e3f4f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.17/afk-linux-arm64.tar.gz"
      sha256 "0d2aae02b981d22f828934a54e5ab0728a4920909b5094fde70d81b60ddb8d79"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.17/afk-linux-amd64.tar.gz"
      sha256 "17465fc603e3483a073a2c0fc4ae3b21174c7a97bf128bdb5ad0627e952c9721"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.17/afk-linux-amd64.tar.gz"
    sha256 "17465fc603e3483a073a2c0fc4ae3b21174c7a97bf128bdb5ad0627e952c9721"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.17/afk-linux-arm64.tar.gz"
    sha256 "0d2aae02b981d22f828934a54e5ab0728a4920909b5094fde70d81b60ddb8d79"
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
