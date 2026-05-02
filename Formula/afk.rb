class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.2.10"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.10/afk-macos-arm64.tar.gz"
      sha256 "e80a55e02eaaa36f1125ee36dd38c5b3e126e0ad6bd0dd496bc49d25f76adf6c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.10/afk-linux-arm64.tar.gz"
      sha256 "5ef9b757b073793e11421b4e7724467d3fc33793ce50dae8f0a54a4ce35b0769"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.10/afk-linux-amd64.tar.gz"
      sha256 "9959c1f2514ac2585b10455d67dce64fb6477b89914254214e536fe439b7217f"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.10/afk-linux-amd64.tar.gz"
    sha256 "9959c1f2514ac2585b10455d67dce64fb6477b89914254214e536fe439b7217f"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.2.10/afk-linux-arm64.tar.gz"
    sha256 "5ef9b757b073793e11421b4e7724467d3fc33793ce50dae8f0a54a4ce35b0769"
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
