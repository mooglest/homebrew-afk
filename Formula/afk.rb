class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.73"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.73/afk-macos-arm64.tar.gz"
      sha256 "53fc4c870c4c7e337e9328666ee744232ba8d8430ca6c83f69bc8d0a5e69fa43"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.73/afk-linux-arm64.tar.gz"
      sha256 "6f7ad05502500d8edf7a86887a78df1d79ff138d799622c8ecaec05328b5c7b7"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.73/afk-linux-amd64.tar.gz"
      sha256 "ee4dfe6c876b8cba1c6566abf1320ce9f32e6bb4521152c2297a862a69f128fe"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.73/afk-linux-amd64.tar.gz"
    sha256 "ee4dfe6c876b8cba1c6566abf1320ce9f32e6bb4521152c2297a862a69f128fe"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.73/afk-linux-arm64.tar.gz"
    sha256 "6f7ad05502500d8edf7a86887a78df1d79ff138d799622c8ecaec05328b5c7b7"
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
