# typed: false
# frozen_string_literal: true

class Afk < Formula
  desc "Autonomous Flow Kit — self-hostable, model-agnostic coding agent"
  homepage "https://github.com/mooglest/afk"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mooglest/afk/releases/download/v#{version}/afk-macos-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "https://github.com/mooglest/afk/releases/download/v#{version}/afk-macos-x86_64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    url "https://github.com/mooglest/afk/releases/download/v#{version}/afk-linux-x86_64"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  def install
    bin.install stable.url.split("/").last => "afk"
  end

  service do
    # Before starting the service, configure your API keys in ~/.config/afk/config.
    # The daemon requires at least one of:
    #   ANTHROPIC_API_KEY=sk-ant-...
    #   OPENAI_API_KEY=sk-...
    # You can also set AFK_PROVIDER, AFK_MODEL, AFK_BASE_URL there.
    # Example ~/.config/afk/config:
    #   ANTHROPIC_API_KEY=sk-ant-...
    #   AFK_PROVIDER=anthropic
    run [opt_bin/"afk", "daemon"]
    keep_alive true
    log_path var/"log/afk.log"
    error_log_path var/"log/afk.log"
  end

  def caveats
    <<~EOS
      Before starting the AFK daemon, set your server token in ~/.afk/config:

        server_token=<your-token>

      Then start the service (auto-starts on login):

        brew services start afk

      The AFK web UI is available at http://afk.mooglest.com

      NOTE: The binary is currently unsigned. If macOS blocks it, run:

        xattr -dr com.apple.quarantine #{opt_bin}/afk
    EOS
  end

  test do
    system "#{bin}/afk", "--version"
  end
end
