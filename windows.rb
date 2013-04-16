require 'formula'

class Windows < Formula
  homepage 'https://github.com/sdegutis/windows'
  url 'https://github.com/sdegutis/Windows/archive/2.0.zip'
  version '2.0'
  sha1 'cdb1ab5729daff6adb0ab7068351cf37df3c0bb0'
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

    However, Spotlight won't see it. But `open -a windows` will.

    EOS
  end
end
