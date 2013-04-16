require 'formula'

class Windows < Formula
  homepage 'https://github.com/sdegutis/windows'
  url 'https://github.com/sdegutis/Windows/archive/2.0.zip'
  version '2.0'
  sha1 'd459205fda3241f52cd3112d131aa0a7ee880f47'
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
