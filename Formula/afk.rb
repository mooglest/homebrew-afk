class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://github.com/mooglest/afk"
  version "0.0.14"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.14/afk-macos-arm64.tar.gz"
      sha256 "08fe525e801c025e36cbbedaae32f3db410b1efb9add6a31b8e3ac0269b37388"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.14/afk-linux-arm64.tar.gz"
      sha256 "977649d4661999d4d5382002156779813ec4577285e6dbf0d1858ff97e188f4e"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.14/afk-linux-amd64.tar.gz"
      sha256 "d9a62fe4a3a40c947edb8343a82cca90b58ffe691fab45df3d38743a13149183"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.14/afk-linux-amd64.tar.gz"
    sha256 "d9a62fe4a3a40c947edb8343a82cca90b58ffe691fab45df3d38743a13149183"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.14/afk-linux-arm64.tar.gz"
    sha256 "977649d4661999d4d5382002156779813ec4577285e6dbf0d1858ff97e188f4e"
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
