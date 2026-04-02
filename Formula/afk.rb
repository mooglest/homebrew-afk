class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.34"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.34/afk-macos-arm64.tar.gz"
      sha256 "e33414e7b99e669006e0aa2b58ef3da0e98893275fcf7513d925e44f43db96d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.34/afk-linux-arm64.tar.gz"
      sha256 "2bb562100ab7959f89d982622a479b0c2f80367f576eb720b3c4c7e76d3103b5"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.34/afk-linux-amd64.tar.gz"
      sha256 "d8dcb0d5f8304df5d711cf0b03607b2f0dc6ece3fb138461655db0db13ee4d63"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.34/afk-linux-amd64.tar.gz"
    sha256 "d8dcb0d5f8304df5d711cf0b03607b2f0dc6ece3fb138461655db0db13ee4d63"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.34/afk-linux-arm64.tar.gz"
    sha256 "2bb562100ab7959f89d982622a479b0c2f80367f576eb720b3c4c7e76d3103b5"
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
