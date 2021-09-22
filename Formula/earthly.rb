class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/alexcb/earthly/archive/v0.5.1.tar.gz"
  sha256 "e4abc7b84546c7f102bbded6c82568b895c2a829c89e8ab4509915283dc6c51d"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/alexcb/homebrew-earthly-1/releases/download/earthly-0.5.1"
    sha256 cellar: :any_skip_relocation, catalina:     "bba2a1b7f68307da47750b66148dbf949379c6b118cb842834be972ae145f8fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a0c59d6d164227fa70b7a28dce04dd5bc5c3e35938d989da13900e7f391a7b4a"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=621b40e30067fdc1c4b7c2ed1292a7122a349db3"
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc"
    system "go", "build",
        "-tags", tags,
        "-ldflags", ldflags,
        *std_go_args,
        "./cmd/earthly/main.go"

    bash_output = Utils.safe_popen_read("#{bin}/earthly", "bootstrap", "--source", "bash")
    (bash_completion/"earthly").write bash_output
    zsh_output = Utils.safe_popen_read("#{bin}/earthly", "bootstrap", "--source", "zsh")
    (zsh_completion/"_earthly").write zsh_output
  end

  test do
    (testpath/"build.earthly").write <<~EOS

      default:
      \tRUN echo homebrew-earthly
    EOS

    output = shell_output("#{bin}/earthly --version").strip
    assert output.start_with?("earthly version")
  end
end
