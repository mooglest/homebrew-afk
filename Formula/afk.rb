class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.27"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.27/afk-macos-arm64.tar.gz"
      sha256 "3dab1fcc258a6f5a558a56cc7d7b05c4e8834cf8f4162c54830bb366142c76b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.27/afk-linux-arm64.tar.gz"
      sha256 "6e1c25d232933b4a6dae3679dd78df49837c84d6da5c03f89c9a0d5d42ec6766"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.27/afk-linux-amd64.tar.gz"
      sha256 "501be7eb7bc8476c4ad8e2e9cda3dcde31b0c812c1f1dcd67a454882a77830d8"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.27/afk-linux-amd64.tar.gz"
    sha256 "501be7eb7bc8476c4ad8e2e9cda3dcde31b0c812c1f1dcd67a454882a77830d8"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.27/afk-linux-arm64.tar.gz"
    sha256 "6e1c25d232933b4a6dae3679dd78df49837c84d6da5c03f89c9a0d5d42ec6766"
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
