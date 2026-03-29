class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.9"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.9/afk-macos-arm64.tar.gz"
      sha256 "f682007b48c17c72cc24acc1f5a47dc3c930a44cbf81e0634b1e1a2d918cd572"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.9/afk-linux-arm64.tar.gz"
      sha256 "86e81a6a9053ace0c70e2f33cd06bc180297d42baad4816ad72fcd64ccb8ccb0"
    else
      url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.9/afk-linux-amd64.tar.gz"
      sha256 "280acd2574c7614112d133d2efdb33838104810a55a850269e66584f4391ebfd"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.9/afk-linux-amd64.tar.gz"
    sha256 "280acd2574c7614112d133d2efdb33838104810a55a850269e66584f4391ebfd"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-afk/releases/download/0.0.9/afk-linux-arm64.tar.gz"
    sha256 "86e81a6a9053ace0c70e2f33cd06bc180297d42baad4816ad72fcd64ccb8ccb0"
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
