class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.30"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.30/afk-macos-arm64.tar.gz"
      sha256 "77a58387fca4ff7115e08022067f99fe286d7fb87d291204c84e76f5e0c6cab8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.30/afk-linux-arm64.tar.gz"
      sha256 "eec35100e4381807a8b8ca46acc1883598589fad3102d8e5a6eb68b9dcb4ecfb"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.30/afk-linux-amd64.tar.gz"
      sha256 "92d6fbb682211e225b979979ca6ebdca046c4f11f074b5f922b30c840839d768"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.30/afk-linux-amd64.tar.gz"
    sha256 "92d6fbb682211e225b979979ca6ebdca046c4f11f074b5f922b30c840839d768"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.30/afk-linux-arm64.tar.gz"
    sha256 "eec35100e4381807a8b8ca46acc1883598589fad3102d8e5a6eb68b9dcb4ecfb"
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
