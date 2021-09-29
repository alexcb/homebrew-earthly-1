class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/alexcb/earthly/archive/v0.5.10.tar.gz"
  sha256 "5522d27df871fc5957214c9c43ef1f86827443e17853b308d59cae86148e1c4c"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/alexcb/homebrew-earthly-1/releases/download/earthly-0.5.10"
    sha256 cellar: :any_skip_relocation, catalina:     "ddb2017e99472d169f707a48072a22e1532b78ef2789777c68bbff4a87721712"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "70d90a7a0e7466af1c65d464f12c8d1cd2c3a558ed35dc5740b3cdc932b14ad7"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=1f62727b6c2fb570b945cc0dfd7172612910bcf0 "
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
