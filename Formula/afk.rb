class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.45"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.45/afk-macos-arm64.tar.gz"
      sha256 "e0c3a71b5f5014161bf34ed9847a603d66989c56f8c12c82956b7de212d9f094"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.45/afk-linux-arm64.tar.gz"
      sha256 "0fc909ba25ce25481b44e3f74160fa38387f5ab097ec4b761a4984dd76b486df"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.45/afk-linux-amd64.tar.gz"
      sha256 "9d7f1b016358338648630e23173f712e1cc75a89ce61fc2ad12be3a8c4519c62"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.45/afk-linux-amd64.tar.gz"
    sha256 "9d7f1b016358338648630e23173f712e1cc75a89ce61fc2ad12be3a8c4519c62"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.45/afk-linux-arm64.tar.gz"
    sha256 "0fc909ba25ce25481b44e3f74160fa38387f5ab097ec4b761a4984dd76b486df"
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
