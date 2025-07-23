class RepositoryExportCli < Formula
  desc "Export, document, and manage your GitHub repositories with a single CLI"
  homepage "https://github.com/raymonepping/homebrew-repository-export-cli"
  url "https://github.com/raymonepping/homebrew-repository-export-cli/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "05be6a60dab4bd12433cc0aaac45ec92b87b845b08cf944bc26fa1f0fef776f0"
  license "MIT"
  version "1.0.5"

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
