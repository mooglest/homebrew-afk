class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.25"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-macos-arm64.tar.gz"
      sha256 "e80ded60b0cea0264dbf893a9dc3d7b23d5ef2a1a418d6d989b0e794e4c9ced4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
      sha256 "611f8575b8c964b680785dc9a5eb3852793ebca3c447a67bfb410eeec4b03745"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
      sha256 "63b9d00d634c75a588a979e7371d5a37d37d847fb710bc765bf2a908ad69a685"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-amd64.tar.gz"
    sha256 "63b9d00d634c75a588a979e7371d5a37d37d847fb710bc765bf2a908ad69a685"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.25/afk-linux-arm64.tar.gz"
    sha256 "611f8575b8c964b680785dc9a5eb3852793ebca3c447a67bfb410eeec4b03745"
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
