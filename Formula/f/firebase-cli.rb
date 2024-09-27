class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-13.20.0.tgz"
  sha256 "60087f481b0a98cdeb22bb788fe3497093c1d1c6eda1032f618231ef53256ccf"
  license "MIT"
  head "https://github.com/firebase/firebase-tools.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ca05a15ecfe7bfa33f221439b0fc37a61b76c229d3ed5d5c9201dd69dd4a9f22"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ca05a15ecfe7bfa33f221439b0fc37a61b76c229d3ed5d5c9201dd69dd4a9f22"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "ca05a15ecfe7bfa33f221439b0fc37a61b76c229d3ed5d5c9201dd69dd4a9f22"
    sha256 cellar: :any_skip_relocation, sonoma:        "39a1527a1cad8f251a1ad5f99db5a066cbbd6127aa9e738902adf45ab571320a"
    sha256 cellar: :any_skip_relocation, ventura:       "39a1527a1cad8f251a1ad5f99db5a066cbbd6127aa9e738902adf45ab571320a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "59545c6a4f9df11ae96b3030af9ea1bcccfcf1b037923e24d65d687f1246513b"
  end

  depends_on "node"

  uses_from_macos "expect" => :test

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
