class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.52"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-macos-arm64.tar.gz"
      sha256 "a98cd2eaeca970544ed83320b198d28a22a0f9ce344f12401220549379549751"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-arm64.tar.gz"
      sha256 "4afd3d71e0cbca77fe545444033272c9902fd314cb0790df079d68351fd5c24d"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-amd64.tar.gz"
      sha256 "43db68cb59d19881c270c784b99b6b7206df2023578d59eccc63dd2514305940"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-amd64.tar.gz"
    sha256 "43db68cb59d19881c270c784b99b6b7206df2023578d59eccc63dd2514305940"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.52/afk-linux-arm64.tar.gz"
    sha256 "4afd3d71e0cbca77fe545444033272c9902fd314cb0790df079d68351fd5c24d"
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
