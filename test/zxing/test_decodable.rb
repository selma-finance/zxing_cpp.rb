require File.expand_path( File.dirname(__FILE__) + '/../test_helper')
require 'zxing/decodable'

class DecodableTest < Minitest::Test

  class Object::File
    include Decodable
  end

  class URL
    include Decodable
    def initialize(path)
      @path = path
    end
    def path; @path end
  end

  context "A Decodable module" do
    setup do
      @file = File.open( File.expand_path( File.dirname(__FILE__) + '/../qrcode.png' ))
      # Using QR Server API to generate a QR code
      @uri = URL.new "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=http://bbc.co.uk/programmes"
      # Using a text file (not an image) which should raise BadImageException
      @bad_uri = URL.new "https://www.google.com/robots.txt"
    end

    should "provide #decode to decode the return value of #path" do
      assert_equal @file.decode, ZXing.decode(@file.path)
      assert_equal @uri.decode, ZXing.decode(@uri.path)
      assert_nil @bad_uri.decode
    end

    should "provide #decode! as well" do
      assert_equal @file.decode!, ZXing.decode(@file.path)
      assert_equal @uri.decode!, ZXing.decode(@uri.path)
      assert_raises(ZXing::BadImageException) { @bad_uri.decode! }
    end
  end

end
