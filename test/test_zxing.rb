require File.expand_path( File.dirname(__FILE__) + '/test_helper')
require 'zxing'

class ZXingTest < Minitest::Test
  context "A QR decoder singleton" do

    class Foo < Struct.new(:v); def to_s; self.v; end; end

    setup do
      @decoder = ZXing
      # Using QR Server API - generates QR code for "http://bbc.co.uk/programmes"
      @uri = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=http://bbc.co.uk/programmes"
      @path = File.expand_path( File.dirname(__FILE__) + '/qrcode.png')
      @file = File.new(@path)
      # Using Google logo as a non-QR image that should fail
      @google_logo = "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png"
      @uri_result = "http://bbc.co.uk/programmes"
      @path_result = "http://rubyflow.com"
    end

    should "decode a URL" do
      assert_equal @uri_result, @decoder.decode(@uri)
    end

    should "decode a file path" do
      assert_equal @decoder.decode(@path), @path_result
    end

    should "return nil if #decode fails" do
      assert_nil @decoder.decode(@google_logo)
    end

    should "raise an exception if #decode! fails" do
      assert_raises(ZXing::ReaderException,
                    ZXing::NotFoundException) { @decoder.decode!(@google_logo) }
    end

    should "decode objects that respond to #path" do
      assert_equal @decoder.decode(@file), @path_result
    end

    should "call #to_s to argument passed in as a last resort" do
      assert_equal @decoder.decode(Foo.new(@path)), @path_result
    end
  end

  context "A QR decoder module" do

    setup do
      class SpyRing; include ZXing end
      @ring = SpyRing.new
    end

    should "include #decode and #decode! into classes" do
      assert @ring.method(:decode)
      assert @ring.method(:decode!)
    end

  end
end
