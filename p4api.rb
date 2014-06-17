require "formula"

class P4api < Formula
  homepage "http://www.perforce.com/product/components/apis"
  url "http://filehost.perforce.com/perforce/r14.1/bin.darwin90x86_64/p4api.tgz"
  version "2014.1.821990"
  sha1 "fdb4db866eb9121e38001c834c091d34216a4d68"

  def install
    lib.install Dir['lib/*']
    (include + 'p4').install Dir['include/p4/*']
    doc.install Dir['sample/*']
  end
end
