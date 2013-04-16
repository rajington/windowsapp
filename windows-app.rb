require 'formula'

class WindowsApp < Formula
  homepage 'https://github.com/sdegutis/windows.app'
  url 'https://github.com/sdegutis/windows.app/archive/2.0.3.zip'
  version '2.0.3'
  sha1 '0c33a5cb3c1ad90f994aa38d3b6d5bae609ee02e'
  head 'https://github.com/sdegutis/windows.app.git'

  depends_on :xcode

  def install
    system 'xcodebuild'
    prefix.install 'build/Release/Windows.app'
  end

  def caveats; <<-EOS

    Windows.app was installed in:
      #{prefix}

    To symlink into ~/Applications, you can do:
      brew linkapps

    However, Spotlight won't see it. But `open -a windows` will.

    EOS
  end
end
