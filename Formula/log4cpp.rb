class Log4cpp < Formula
  desc "Configurable logging for C++"
  homepage "https://log4cpp.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/log4cpp/log4cpp-1.1.x%20%28new%29/log4cpp-1.1/log4cpp-1.1.4.tar.gz"
  sha256 "696113659e426540625274a8b251052cc04306d8ee5c42a0c7639f39ca90c9d6"
  license "LGPL-2.1"

  livecheck do
    url :stable
    regex(%r{url=.*?/log4cpp[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "4249d830f5c4e58d77d76a7cdf0eb84cd02a3c1150606e7795022ca8ba4b7abd"
    sha256 cellar: :any,                 arm64_monterey: "7ef34de1a9e3603252d924f37dc222b427287b26843603ca329bc395d3a0c4d2"
    sha256 cellar: :any,                 arm64_big_sur:  "6d5fcedb4afd7681c3ed5e6e65b300487527789144183e854d846a335c26b545"
    sha256 cellar: :any,                 ventura:        "60b1a66382660e797f3bb510043edc25dcab2b3512f1c9d11d2042d0980ae319"
    sha256 cellar: :any,                 monterey:       "8a710781fbbb6e0bf127e73411aefc490e63f2e17830f269039e0d865601974c"
    sha256 cellar: :any,                 big_sur:        "ff54331ebc21d9e5bcc75faf5af6750ce944485bd6cac293bd879c04c762dc7c"
    sha256 cellar: :any,                 catalina:       "3e08cff5384ae60222e67b63aadfda07534daa4d962b66167c5ffd8c1a55edf7"
    sha256 cellar: :any,                 mojave:         "0e0950a9b99a406b035e13c8acae673ce190a436920940d8150abe0c90cf1e84"
    sha256 cellar: :any,                 high_sierra:    "a80304325ab0f551054b169320c6f726f1c8a78d56eb56e7f14793c0f8cc8836"
    sha256 cellar: :any,                 sierra:         "db55c3b9dff2f2248d96c71672cb6032efc16a4803ce12dd52c278bd14b9abc8"
    sha256 cellar: :any,                 el_capitan:     "dee0bf8b96b1d0de3beb5f2d23cf1e868e6dfd3ec9814e2c4c5eab21432d73e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "fa93ce1f4cce44107a131667b2350814eb79a762c63c8bd4f35d283f21a25a10"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  def install
    ENV.cxx11
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"log4cpp.cpp").write <<~EOS
      #include <log4cpp/Category.hh>
      #include <log4cpp/PropertyConfigurator.hh>
      #include <log4cpp/OstreamAppender.hh>
      #include <log4cpp/Priority.hh>
      #include <log4cpp/BasicLayout.hh>
      #include <iostream>
      #include <memory>

      int main(int argc, char* argv[]) {
        log4cpp::OstreamAppender* osAppender = new log4cpp::OstreamAppender("osAppender", &std::cout);
        osAppender->setLayout(new log4cpp::BasicLayout());

        log4cpp::Category& root = log4cpp::Category::getRoot();
        root.addAppender(osAppender);
        root.setPriority(log4cpp::Priority::INFO);

        root.info("This is an informational log message");

        // Clean up
        root.removeAllAppenders();
        log4cpp::Category::shutdown();

        return 0;
      }
    EOS
    system ENV.cxx, "log4cpp.cpp", "-L#{lib}", "-llog4cpp", "-o", "log4cpp"
    system "./log4cpp"
  end
end
