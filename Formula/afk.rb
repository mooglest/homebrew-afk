class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.60"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.60/afk-macos-arm64.tar.gz"
      sha256 "2b7702b18996c58df97ed4983f6cabbed89623e9dd75d993703ed242d5988b99"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.60/afk-linux-arm64.tar.gz"
      sha256 "0ad87d5e6a674b5d06e3a0a52183b99a33fadba332e3a6ac34e01580e2e73c6f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.60/afk-linux-amd64.tar.gz"
      sha256 "a42cd30cf0752118eca6d69bb8b38013e055bb7718b1b4e05e866c17cae3f2e2"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.60/afk-linux-amd64.tar.gz"
    sha256 "a42cd30cf0752118eca6d69bb8b38013e055bb7718b1b4e05e866c17cae3f2e2"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.60/afk-linux-arm64.tar.gz"
    sha256 "0ad87d5e6a674b5d06e3a0a52183b99a33fadba332e3a6ac34e01580e2e73c6f"
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
