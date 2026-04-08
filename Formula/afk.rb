class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.54"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.54/afk-macos-arm64.tar.gz"
      sha256 "c2db1d3b5fd6ec0511d5368741d798e6383566920f0c262a1cd9355bfbfc1d2a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.54/afk-linux-arm64.tar.gz"
      sha256 "9a795b61fe1662efa60c0e809c48f4aa2c5f73b90d6830792b9b7bf9d3b6371d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.54/afk-linux-amd64.tar.gz"
      sha256 "af376ed90b4dccd0211135c4a18c60b71b5bf6069ce7389ad289ffc01b3e2038"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.54/afk-linux-amd64.tar.gz"
    sha256 "af376ed90b4dccd0211135c4a18c60b71b5bf6069ce7389ad289ffc01b3e2038"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.54/afk-linux-arm64.tar.gz"
    sha256 "9a795b61fe1662efa60c0e809c48f4aa2c5f73b90d6830792b9b7bf9d3b6371d"
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
