class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.46"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.46/afk-macos-arm64.tar.gz"
      sha256 "604c1b0f54a5da002bd1074e156f8672d298f93f208076301fb77cf351f8fb0f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.46/afk-linux-arm64.tar.gz"
      sha256 "7ad5d37e6afb632d3e9f53f348acf291489cf38de7e248c9c0712db52e905a7f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.46/afk-linux-amd64.tar.gz"
      sha256 "b3edb1fc5e79792a3aa31fce6a0ad8c4918f0d4b3555307d2347e1fc2777cd4e"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.46/afk-linux-amd64.tar.gz"
    sha256 "b3edb1fc5e79792a3aa31fce6a0ad8c4918f0d4b3555307d2347e1fc2777cd4e"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.46/afk-linux-arm64.tar.gz"
    sha256 "7ad5d37e6afb632d3e9f53f348acf291489cf38de7e248c9c0712db52e905a7f"
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
