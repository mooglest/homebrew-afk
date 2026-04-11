class Afk < Formula
  desc "Autonomous Flow Kit daemon and CLI"
  homepage "https://afk.mooglest.com"
  version "0.0.65"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.65/afk-macos-arm64.tar.gz"
      sha256 "fa182c14148175f8c5191310072ffdce6710f058f8cc53332620409726077c65"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.65/afk-linux-arm64.tar.gz"
      sha256 "0ceb9226f71ca1c895a1505fd4c06ce475a49ca997a4ab89317df1e5ea6ec506"
    else
      url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.65/afk-linux-amd64.tar.gz"
      sha256 "cda4089b2398f4dc01eaef430d51c1902fb0b674a1578d6e00eafe5f6881c6ad"
    end
  end

  resource "afk-linux-amd64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.65/afk-linux-amd64.tar.gz"
    sha256 "cda4089b2398f4dc01eaef430d51c1902fb0b674a1578d6e00eafe5f6881c6ad"
  end

  resource "afk-linux-arm64" do
    url "https://github.com/mooglest/homebrew-tap/releases/download/0.0.65/afk-linux-arm64.tar.gz"
    sha256 "0ceb9226f71ca1c895a1505fd4c06ce475a49ca997a4ab89317df1e5ea6ec506"
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
