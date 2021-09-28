class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/alexcb/earthly/archive/v0.5.1.tar.gz"
  sha256 "2355c565cc470a3fc17dc364116b8c29f0b3d23a38d37cac4bb74f330aea99dc"
  license "BUSL-1.1"
  head "https://github.com/earthly/earthly.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/alexcb/homebrew-earthly-1/releases/download/earthly-0.5.1"
    rebuild 2
    sha256 cellar: :any_skip_relocation, catalina:     "7da5623ed41e0f3b6756237b86f4065af1b5d07636dfddcd0307d37dd10cdda3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "753ec6790e7708770ac5573c6b935b19ba65112c135d5e1c8c7fcdad001d0428"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=bcf4a753b25602d8b9e3b84909169ab274c2c1af "
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
