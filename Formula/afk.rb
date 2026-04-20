class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.20-SNAPSHOT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.20-SNAPSHOT/afk-macos-arm64.tar.gz"
      sha256 "a640ee07fb3b9507e220fa133697e89f4bdf2d2f9acd26c7812fbc04837a380c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.20-SNAPSHOT/afk-linux-arm64.tar.gz"
      sha256 "6dff1af2c5fae2e06a90128c30248852d25b664877f4fd15a0671f45de9013ce"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.20-SNAPSHOT/afk-linux-amd64.tar.gz"
      sha256 "48028a743ff8b598e6f9d2da3b9eb3cea3ba2bc5cbf58e7acf99d832d65777c3"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.20-SNAPSHOT/afk-linux-amd64.tar.gz"
    sha256 "48028a743ff8b598e6f9d2da3b9eb3cea3ba2bc5cbf58e7acf99d832d65777c3"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.20-SNAPSHOT/afk-linux-arm64.tar.gz"
    sha256 "6dff1af2c5fae2e06a90128c30248852d25b664877f4fd15a0671f45de9013ce"
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
