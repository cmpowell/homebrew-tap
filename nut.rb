require 'formula'

class Nut < Formula
  url 'http://www.networkupstools.org/source/2.7/nut-2.7.1.tar.gz'
  homepage 'http://www.networkupstools.org/'
  sha256 '71a6d73ad6d910808126ba7f217ec1142a0c6709c63a22a099e7338960b2c798'

  depends_on 'neon'
  depends_on 'libusb-compat' => :optional
  depends_on 'gd' => :optional

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--sysconfdir=#{etc}/#{name}",
            "--datarootdir=#{share}/#{name}",
            "--mandir=#{man}",
            "--with-drvpath=#{libexec}/#{name}",
            "--with-statepath=#{var}/run/#{name}",
            "--with-pidpath=#{var}/run/#{name}",
            "--with-user=nobody",
            "--with-group=nobody",
            "--with-macosx_ups"]
    args << "--with-usb" if build.with? 'libusb-compat'
    if build.with? 'gd'
      args << "--with-cgi"
      args << "--with-cgipath=#{lib}/cgi-bin/#{name}"
      args << "--with-htmlpath=#{share}/#{name}/www"
    end

    system "./configure", *args
    system "make install"

    (var+"run/#{name}").mkpath
    File.rename("#{libexec}/#{name}/upsdrvctl","#{prefix}/sbin/upsdrvctl")

    plist_path('upsdrvctl').write upsdrvctl_startup_plist('upsdrvctl')
    plist_path('upsdrvctl').chmod 0644
    plist_path('upsd').write upsd_startup_plist('upsd')
    plist_path('upsd').chmod 0644
    plist_path('upsmon').write upsmon_startup_plist('upsmon')
    plist_path('upsmon').chmod 0644
  end

  def caveats
    s = <<-EOS
The NUT config files live in #{etc}/#{name}

To run upsdrvctl and upsd at startup:

  sudo chown nobody:nobody #{HOMEBREW_PREFIX}/var/run/#{name}
  sudo cp -fv #{HOMEBREW_PREFIX}/opt/#{name}/#{plist_name('upsdrvctl')}.plist /Library/LaunchDaemons/
  sudo cp -fv #{HOMEBREW_PREFIX}/opt/#{name}/#{plist_name('upsd')}.plist /Library/LaunchDaemons/
  sudo launchctl load /Library/LaunchDaemons/#{plist_name('upsdrvctl')}.plist
  sudo launchctl load /Library/LaunchDaemons/#{plist_name('upsd')}.plist

To run upsmon at startup:

  sudo cp -fv #{HOMEBREW_PREFIX}/opt/#{name}/#{plist_name('upsmon')}.plist /Library/LaunchDaemons/
  sudo launchctl load /Library/LaunchDaemons/#{plist_name('upsmon')}.plist
EOS

    if build.with? 'gd'
      s << "\nThe CGI executable was installed to #{prefix}/cgi-bin/upsstats.cgi\n"
    end

    return s
  end

  plist_options :startup => true, :manual => "upsdrvctl start ; upsd ; upsmon"

  # Override Formula#plist_name
  def plist_name(extra = nil)
    (extra) ? super()+'-'+extra : super()+'-*'
  end

  # Override Formula#plist_path
  def plist_path(extra = nil)
    (extra) ? super().dirname+(plist_name(extra)+'.plist') : super()
  end

  def upsdrvctl_startup_plist(name)
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UserName</key>
    <string>nobody</string>
    <key>GroupName</key>
    <string>nobody</string>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>#{plist_name(name)}</string>
    <key>ProgramArguments</key>
    <array>
        <string>#{HOMEBREW_PREFIX}/sbin/upsdrvctl</string>
        <string>start</string>
    </array>
</dict>
</plist>
    EOPLIST
  end

  def upsd_startup_plist(name)
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UserName</key>
    <string>nobody</string>
    <key>GroupName</key>
    <string>nobody</string>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>#{plist_name(name)}</string>
    <key>ProgramArguments</key>
    <array>
        <string>#{HOMEBREW_PREFIX}/sbin/upsd</string>
    </array>
</dict>
</plist>
    EOPLIST
  end

  def upsmon_startup_plist(name)
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UserName</key>
    <string>nobody</string>
    <key>GroupName</key>
    <string>nobody</string>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>#{plist_name(name)}</string>
    <key>ProgramArguments</key>
    <array>
        <string>#{HOMEBREW_PREFIX}/sbin/upsmon</string>
    </array>
</dict>
</plist>
    EOPLIST
  end
end
