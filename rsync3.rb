require 'formula'

$rsync3_version = "3.1.0"

class Rsync3Patches < Formula
   url "http://rsync.samba.org/ftp/rsync/rsync-patches-#{$rsync3_version}.tar.gz"
   sha1 'ccfd068b10482ff98109d3a15d6834575d8ae856'
   version $rsync3_version

   def initialize
      super "rsync3-patches"
   end
end

class Rsync3 < Formula
   url "http://rsync.samba.org/ftp/rsync/rsync-#{$rsync3_version}.tar.gz"
   homepage 'http://rsync.samba.org/'
   sha1 'eb58ab04bcb6293da76b83f58327c038b23fcba3'

   def patches
      {:p1 => [
         "patches/fileflags.diff",
         "patches/crtimes.diff",
         "patches/hfs-compression.diff"
      ]}
   end

   def patch
      rsync3_dir = Pathname.new(Dir.pwd)
      Rsync3Patches.new.brew { rsync3_dir.install Dir['*'] }
      super
   end

   def install
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
      "--prefix=#{prefix}", "--with-rsync-path=rsync3"
      system "make"
      bin.install "rsync" => "rsync3"
      man1.install "rsync.1" => "rsync3.1"
      man5.install "rsyncd.conf.5" => "rsync3d.conf.5"
   end
end
