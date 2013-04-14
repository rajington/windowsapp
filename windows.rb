require 'formula'

class Windows < Formula
  homepage 'https://github.com/sdegutis/windows'
  url 'https://github.com/sdegutis/Windows/archive/1.2.1.zip'
  sha1 '11ebaf4d65ea7c1cad917950bd3e0861f434d6ed'

  head 'https://github.com/sdegutis/Windows.git'

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

    EOS
  end
end
