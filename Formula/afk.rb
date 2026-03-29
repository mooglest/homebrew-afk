class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.12"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.12/afk-macos-arm64.tar.gz"
      sha256 "4b98b6125e27c05cd7a269843f82b144e37d5ce03fa4b492531b1868ed4ce888"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.12/afk-linux-arm64.tar.gz"
      sha256 "76fa46b9da54dc656600bf05f97fb40c7c40b4286cc27baa09e7911b109e81fa"
    else
      url "https://github.com/mooglest/homebrew-tapreleases/download/0.0.12/afk-linux-amd64.tar.gz"
      sha256 "d91956ececc894de0f04608b465c92fc2d62d26520c5d288b16dc561b1ec3122"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.12/afk-linux-amd64.tar.gz"
    sha256 "d91956ececc894de0f04608b465c92fc2d62d26520c5d288b16dc561b1ec3122"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.12/afk-linux-arm64.tar.gz"
    sha256 "76fa46b9da54dc656600bf05f97fb40c7c40b4286cc27baa09e7911b109e81fa"
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
