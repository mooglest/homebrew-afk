class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.70"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.70/afk-macos-arm64.tar.gz"
      sha256 "c4893dae390fce70fe1ca9dd296f129f790724ff6b4ac45fa6e4e264a9ea1251"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.70/afk-linux-arm64.tar.gz"
      sha256 "4d9f38051272f7b5a6bd0a430d49b89b00c68b42e6632c5c4ad1ded420aadef6"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.70/afk-linux-amd64.tar.gz"
      sha256 "6ae8b80c5428dad1988872788ca47a5a925606b7a06e812adbd4e14969b2b8eb"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.70/afk-linux-amd64.tar.gz"
    sha256 "6ae8b80c5428dad1988872788ca47a5a925606b7a06e812adbd4e14969b2b8eb"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.70/afk-linux-arm64.tar.gz"
    sha256 "4d9f38051272f7b5a6bd0a430d49b89b00c68b42e6632c5c4ad1ded420aadef6"
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
