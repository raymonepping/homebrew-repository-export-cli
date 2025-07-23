class RepositoryExportCli < Formula
  desc "Export, document, and manage your GitHub repositories with a single CLI"
  homepage "https://github.com/raymonepping/homebrew-repository-export-cli"
  url "https://github.com/raymonepping/homebrew-repository-export-cli/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "4dee7b539d7634c22e629e9ef5d39825baf83bd4f31d2ceb8c4f92b4a5db906f"
  license "MIT"
  version "1.0.4"

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
