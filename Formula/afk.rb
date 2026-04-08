class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.53"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-macos-arm64.tar.gz"
      sha256 "bb2ac109348b56371e102b555c857852e6cc689c1c899b7d33d9c6aa302534b2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
      sha256 "6b8c0bdf13182460769f5623320591d706b7b42172056cbe75308417ab78e1be"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
      sha256 "6f55d9e55a032968dbcdc4fed31c80f5a1a77f9db7363e05474efb8836fef455"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
    sha256 "6f55d9e55a032968dbcdc4fed31c80f5a1a77f9db7363e05474efb8836fef455"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
    sha256 "6b8c0bdf13182460769f5623320591d706b7b42172056cbe75308417ab78e1be"
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
