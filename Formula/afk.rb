class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.35"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.35/afk-macos-arm64.tar.gz"
      sha256 "b6e8fee1a3305d10deb2945f0fdf0bf2ae5863a6a652c825213f5bac5de0ceaa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.35/afk-linux-arm64.tar.gz"
      sha256 "caadef0ce93fae17f81fd643832461f13c659ffe4e2b1c4fd62b3263efa2213f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.35/afk-linux-amd64.tar.gz"
      sha256 "f43df9f4b549ccb5101649776ff8fe5eb056cae9f62199ec3edc8e657604504b"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.35/afk-linux-amd64.tar.gz"
    sha256 "f43df9f4b549ccb5101649776ff8fe5eb056cae9f62199ec3edc8e657604504b"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.35/afk-linux-arm64.tar.gz"
    sha256 "caadef0ce93fae17f81fd643832461f13c659ffe4e2b1c4fd62b3263efa2213f"
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
