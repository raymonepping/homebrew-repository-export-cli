class RepositoryExportCli < Formula
  desc "Export, document, and manage your GitHub repositories with a single CLI"
  homepage "https://github.com/raymonepping/homebrew-repository-export-cli"
  url "https://github.com/raymonepping/homebrew-repository-export-cli/archive/refs/tags/v1.0.9.tar.gz"
  sha256 "8813c317022cf0644c1253610fa18e965629c9a7fbdcb8f0c1317decc9ca67fe"
  license "MIT"
  version "1.0.9"

  depends_on "bash"
  depends_on "jq"
  depends_on "gh" # For GitHub API

  def install
    bin.install "bin/repository_export" => "repository_export"
    share.install Dir["lib"], Dir["tpl"]
  end

  def caveats
    <<~EOS
      To get started, run:
        repository_export --help

      This CLI exports and documents your GitHub repositories to Markdown, CSV, or JSON.

      Example usage:
        repository_export --output md --output-file repos.md
        repository_export --output csv --output-dir ./exports

      Docs & updates: https://github.com/raymonepping/homebrew-repository-export-cli
    EOS
  end

  test do
    assert_match "repository_export", shell_output("#{bin}/repository_export --help")
  end
end
