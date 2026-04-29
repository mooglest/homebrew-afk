class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.38"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.38/afk-macos-arm64.tar.gz"
      sha256 "00a6b838a0aa96b2c93a53d0f7ddf930d8f5b510382bd059d071e9a3107e9e30"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.38/afk-linux-arm64.tar.gz"
      sha256 "fcaedb0968d624678ab715c009b3464619396affc6ec62991b38d20ac945ce7c"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.38/afk-linux-amd64.tar.gz"
      sha256 "4da73f70f8b75c9a381b10a7f27d02a04a176568b30efd095a90e19344b10843"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.38/afk-linux-amd64.tar.gz"
    sha256 "4da73f70f8b75c9a381b10a7f27d02a04a176568b30efd095a90e19344b10843"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.38/afk-linux-arm64.tar.gz"
    sha256 "fcaedb0968d624678ab715c009b3464619396affc6ec62991b38d20ac945ce7c"
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
