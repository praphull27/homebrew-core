class Mmseqs2 < Formula
  desc "Software suite for very fast protein sequence search and clustering"
  homepage "https://mmseqs.org/"
  url "https://github.com/soedinglab/MMseqs2/archive/2-23394.tar.gz"
  version "2-23394"
  sha256 "36763fff4c4de1ab6cfc37508a2ee9bd2f4b840e0c9415bd1214280f67b67072"
  revision 1

  bottle do
    cellar :any
    sha256 "6e492564e40f85bf54383aa6013c9683646b235d68491b17af6d3ac34f1e5c32" => :high_sierra
    sha256 "36c412cf77cad2bc556cb523e1c1b0a1bc32ce96197e196997d0f8b5c9c64d9a" => :sierra
    sha256 "f83839b18c21e254800a830be8774c3f20d2c570d930d4b4cc6b9ec56eadcc7d" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "gcc"

  cxxstdlib_check :skip

  fails_with :clang # needs OpenMP support

  resource "documentation" do
    url "https://github.com/soedinglab/MMseqs2.wiki.git",
        :revision => "fda4cf3f63e4c5b01be9d6b66f6666e81cc8ca99"
  end

  def install
    args = *std_cmake_args << "-DHAVE_TESTS=0" << "-DHAVE_MPI=0"
    args << "-DVERSION_OVERRIDE=#{version}"

    args << "-DHAVE_SSE4_1=1" if build.bottle?

    system "cmake", ".", *args
    system "make", "install"

    resource("documentation").stage { doc.install Dir["*"] }
    pkgshare.install "examples"
    bash_completion.install "util/bash-completion.sh" => "mmseqs.sh"
  end

  def caveats
    unless Hardware::CPU.sse4?
      "MMseqs2 requires at least SSE4.1 CPU instruction support. The binary will not work correctly."
    end
  end

  test do
    system "#{bin}/mmseqs", "createdb", "#{pkgshare}/examples/QUERY.fasta", "q"
    system "#{bin}/mmseqs", "cluster", "q", "res", "tmp", "-s", "1"
    assert_predicate testpath/"res", :exist?
    assert_predicate (testpath/"res").size, :positive?
    assert_predicate testpath/"res.index", :exist?
    assert_predicate (testpath/"res.index").size, :positive?
  end
end
