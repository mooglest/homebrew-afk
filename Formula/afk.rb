class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.23-SNAPSHOT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23-SNAPSHOT/afk-macos-arm64.tar.gz"
      sha256 "848cc3582ba63c55f2d2d5ea5fbc2a1a21e02d26c1406f66e036418b2ca8c715"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23-SNAPSHOT/afk-linux-arm64.tar.gz"
      sha256 "c42356aa451adadc3be94770620fd8913e571ee6c4e212e70011868b62b87019"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23-SNAPSHOT/afk-linux-amd64.tar.gz"
      sha256 "961159696b391237fde2f8aea2ca39a35fb1d09feb030699e280fc4324a7c825"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23-SNAPSHOT/afk-linux-amd64.tar.gz"
    sha256 "961159696b391237fde2f8aea2ca39a35fb1d09feb030699e280fc4324a7c825"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.23-SNAPSHOT/afk-linux-arm64.tar.gz"
    sha256 "c42356aa451adadc3be94770620fd8913e571ee6c4e212e70011868b62b87019"
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
