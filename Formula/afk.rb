class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.1/afk-macos-arm64.tar.gz"
      sha256 "acd4f2cef026b33db6d9518c64d5a8f4827dfffda4558f0be1db1c60c79af1eb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.1/afk-linux-arm64.tar.gz"
      sha256 "f82d5b254ef018f1a21f5a35b7673e5b60c8219c56b0bbd44fdd591f99c10b26"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.1/afk-linux-amd64.tar.gz"
      sha256 "c490bbbf643bd158889778dd69c424bfd77e3d2a4c31c558eb35c89b8ff9757c"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.1/afk-linux-amd64.tar.gz"
    sha256 "c490bbbf643bd158889778dd69c424bfd77e3d2a4c31c558eb35c89b8ff9757c"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.1/afk-linux-arm64.tar.gz"
    sha256 "f82d5b254ef018f1a21f5a35b7673e5b60c8219c56b0bbd44fdd591f99c10b26"
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
