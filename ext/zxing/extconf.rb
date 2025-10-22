require 'mkmf'

ZXING_CPP = "#{File.dirname(__FILE__)}/zxing-cpp"
ZXING_CPP_BUILD = "#{ZXING_CPP}/build"

# Check for cmake (version 3.5 or later recommended)
cmake_version = `cmake --version 2>&1`.match(/cmake version (\d+\.\d+)/)
raise "zxing_cpp.rb installation requires cmake 3.5 or later" unless cmake_version && cmake_version[1].to_f >= 3.5

Dir.mkdir ZXING_CPP_BUILD unless File.exist? ZXING_CPP_BUILD

# Clean build directory if it exists but is incomplete
if File.exist?(ZXING_CPP_BUILD) && !File.exist?("#{ZXING_CPP_BUILD}/libzxing.a")
  require 'fileutils'
  FileUtils.rm_rf(ZXING_CPP_BUILD)
  Dir.mkdir ZXING_CPP_BUILD
end

Dir.chdir ZXING_CPP_BUILD do
  # Use modern cmake with explicit policy for compatibility
  cmake_cmd = "cmake -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_CXX_FLAGS=\"-fPIC\" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .."
  puts "Running: #{cmake_cmd}"
  system(cmake_cmd) || raise("CMake configuration failed")
end

Dir.chdir ZXING_CPP_BUILD do
  make_cmd = "make"
  puts "Running: #{make_cmd}"
  system(make_cmd) || raise("Make failed")
end

cpp_include = File.join File.expand_path("#{ZXING_CPP}/core/src")
lib = File.expand_path "#{ZXING_CPP_BUILD}/libzxing.a"

raise "libzxing.a not found at #{lib}" unless File.exist?(lib)

$CPPFLAGS = %(-I#{cpp_include})
$DLDFLAGS = %(-lstdc++ #{lib})

# Add iconv library (required on macOS and other systems)
if RbConfig::CONFIG['host_os'] =~ /darwin/
  # macOS - iconv is in system library
  $DLDFLAGS << %( -liconv)
elsif Dir["/usr/lib/libiconv.*"].size > 0
  $DLDFLAGS << %( -liconv)
end

create_makefile 'zxing/zxing'
