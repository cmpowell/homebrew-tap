require "formula"

class P4python < Formula
  homepage "http://www.perforce.com/product/components/apis"
  url "http://filehost.perforce.com/perforce/r14.1/bin.tools/p4python.tgz"
  version "2014.1.831633"
  sha1 "d9d3467b4ab36c97f1ae210f4ea76eb08a4510ce"

  depends_on 'p4api' => :build
  depends_on :python => :optional
  depends_on :python3 => :recommended

  def install
    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "build",
             "--apidir", "#{HOMEBREW_PREFIX}/opt/p4api"
      system python, "setup.py", "install",
             "--apidir", "#{HOMEBREW_PREFIX}/opt/p4api",
             "--prefix=#{prefix}"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import P4; p4 = P4.P4()"
    end
  end
end
