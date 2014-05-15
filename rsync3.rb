require 'formula'

class Rsync3 < Formula
  homepage 'https://rsync.samba.org/'
  url 'https://rsync.samba.org/ftp/rsync/src/rsync-3.1.0.tar.gz'
  sha1 'eb58ab04bcb6293da76b83f58327c038b23fcba3'

  depends_on :autoconf

  def patches
    %W[
      https://gitweb.samba.org/?p=rsync-patches.git;a=blob_plain;f=fileflags.diff;hb=v3.1.0
      https://gitweb.samba.org/?p=rsync-patches.git;a=blob_plain;f=crtimes.diff;hb=v3.1.0
      https://gitweb.samba.org/?p=rsync-patches.git;a=blob_plain;f=hfs-compression.diff;hb=v3.1.0
    ]
  end

  def install
    system "./prepare-source"
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-rsync-path=rsync3",
                          "--with-rsyncd-conf=#{etc}/rsync3d.conf",
                          "--enable-ipv6"
    system "make"
    bin.install "rsync" => "rsync3"
    man1.install "rsync.1" => "rsync3.1"
    man5.install "rsyncd.conf.5" => "rsync3d.conf.5"
  end
end
