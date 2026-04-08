class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.53"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-macos-arm64.tar.gz"
      sha256 "886011948f171d07d3d047f65d6235b81eb70f621835d22e20a386658b926348"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
      sha256 "bd68037b447afb1756ce42fc7805682d36764f47c35c59d51556dbe0aaa55399"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
      sha256 "baa367035aec498e8584445e2e8507856d0f75df9c1b6310dd5ab53e2b1e79b9"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-amd64.tar.gz"
    sha256 "baa367035aec498e8584445e2e8507856d0f75df9c1b6310dd5ab53e2b1e79b9"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.53/afk-linux-arm64.tar.gz"
    sha256 "bd68037b447afb1756ce42fc7805682d36764f47c35c59d51556dbe0aaa55399"
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
