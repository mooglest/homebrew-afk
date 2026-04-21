class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.1.25"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.25/afk-macos-arm64.tar.gz"
      sha256 "62a403e54975334cb8ecab7f059798aa131814bd7785b0a64f419dcfc4f1bb4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.25/afk-linux-arm64.tar.gz"
      sha256 "914940a68b084c216b88931094645e0d81dad8610ca0c8f8948bb52de46f5289"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.25/afk-linux-amd64.tar.gz"
      sha256 "54303640120e2eef8dd59d263507e27098923d4675184a145a74d55f8d53c268"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.25/afk-linux-amd64.tar.gz"
    sha256 "54303640120e2eef8dd59d263507e27098923d4675184a145a74d55f8d53c268"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.1.25/afk-linux-arm64.tar.gz"
    sha256 "914940a68b084c216b88931094645e0d81dad8610ca0c8f8948bb52de46f5289"
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
