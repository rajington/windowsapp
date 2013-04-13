require 'formula'

class Windows < Formula
  homepage 'https://github.com/sdegutis/windows'
  url 'https://github.com/sdegutis/Windows/archive/1.1.1.zip'
  sha1 '67dbee34e780221b31b85c372de3a2c73b528e32'

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
