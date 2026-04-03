class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.37"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.37/afk-macos-arm64.tar.gz"
      sha256 "fc74de55e41cb9026c06b5a6d65caf794cee65e9b0896db90548e9e77ceffff7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.37/afk-linux-arm64.tar.gz"
      sha256 "dd29bdf5f8246f3871136e46e2588a3b641ddf1bbe7f3541441994c8be07666f"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.37/afk-linux-amd64.tar.gz"
      sha256 "03919dc220cd98cce4927ffc76328fa5feec40d877631fefa3ab1b84a0927846"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.37/afk-linux-amd64.tar.gz"
    sha256 "03919dc220cd98cce4927ffc76328fa5feec40d877631fefa3ab1b84a0927846"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.37/afk-linux-arm64.tar.gz"
    sha256 "dd29bdf5f8246f3871136e46e2588a3b641ddf1bbe7f3541441994c8be07666f"
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
