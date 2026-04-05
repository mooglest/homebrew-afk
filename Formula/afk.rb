class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.40"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.40/afk-macos-arm64.tar.gz"
      sha256 "82092dc3d495163cf0b9f21a918a728c16b95d0f4df95e360659f83254a36d1d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.40/afk-linux-arm64.tar.gz"
      sha256 "c632fbf5a039e9f63a27f731df80668df9e1666b9e0383ca63b144333a3d80a4"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.40/afk-linux-amd64.tar.gz"
      sha256 "9ceb55b7f05f3a767e0dd8029f34f7392bc01b465f4adbe80b5d274fd0d0d41c"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.40/afk-linux-amd64.tar.gz"
    sha256 "9ceb55b7f05f3a767e0dd8029f34f7392bc01b465f4adbe80b5d274fd0d0d41c"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.40/afk-linux-arm64.tar.gz"
    sha256 "c632fbf5a039e9f63a27f731df80668df9e1666b9e0383ca63b144333a3d80a4"
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
