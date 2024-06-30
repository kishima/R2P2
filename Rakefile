require "fileutils"

PICO_SDK_TAG = "1.5.1"

def mruby_config
  if ENV['BOARD']&.downcase == 'pico_w'
    if ENV['NETWORK']&.downcase == 'yes'
      'r2p2_w_network-cortex-m0plus'
    else
      'r2p2_w-cortex-m0plus'
    end
  else
    'r2p2-cortex-m0plus'
  end
end

def select_flags
  flags = []
  flags << (ENV['MSC']&.downcase == 'sd' ? "PICORUBY_MSC_SD=yes" : "PICORUBY_MSC_FLASH=yes")
  if ENV['BOARD']&.downcase == 'pico_w'
    flags << "PICO_W=yes"
    if ENV['NETWORK']&.downcase == 'yes'
      flags << "PICO_W_NETWORK=yes"
    end
  end
  flags.join(" ")
end

def def_board
  ENV['BOARD']&.downcase == 'pico_w' ? '-DPICO_BOARD=pico_w' : ''
end

task :default => :all

desc "build production"
task :all => [:libmruby, :cmake_production, :build]

desc "clean then build debug"
task :debug => [:clean, :libmruby, :cmake_debug, :build]

file "lib/picoruby" do
  sh "git submodule update --init --recursive"
end

task :libmruby => "lib/picoruby" do
  FileUtils.cd "lib/picoruby" do
    sh "rake test"
    sh "MRUBY_CONFIG=#{mruby_config} rake"
  end
end

def cmake_cmd(env)
  "#{select_flags} cmake #{def_board} -DCMAKE_BUILD_TYPE=#{env} -B build"
end

task :cmake_debug do
  sh cmake_cmd("Debug")
end

task :cmake_production do
  sh cmake_cmd("Release")
end

task :check_pico_sdk => :check_pico_sdk_path do
  %w(PICO_SDK_PATH PICO_EXTRAS_PATH).each do |env|
    FileUtils.cd ENV[env] do
      unless `git status --branch`.split("\n")[0].end_with?(PICO_SDK_TAG)
        raise <<~MSG
          pico-sdk #{PICO_SDK_TAG} is not checked out!\n
          Tips for dealing with:\n
          cd $PICO_SDK_PATH && git pull && git checkout #{PICO_SDK_TAG} && git submodule update --recursive\n
        MSG
      end
    end
  end
end

task :check_pico_sdk_path do
  %w(PICO_SDK_PATH PICO_EXTRAS_PATH).each do |env|
    unless ENV[env]
      raise <<~MSG
        Environment variable `#{env}` does not exist!
      MSG
    end
  end
end

desc "build without cmake preparation"
task :build => :check_pico_sdk do
  sh "cmake --build build"
end

desc "deep clean built"
task :deep_clean do
  FileUtils.cd "lib/picoruby" do
    sh "MRUBY_CONFIG=#{mruby_config} rake deep_clean"
  end
  FileUtils.cd "build" do
    FileUtils.rm_rf "*"
  end
end

desc "clean built"
task :clean do
  FileUtils.cd "lib/picoruby" do
    sh "MRUBY_CONFIG=#{mruby_config} rake clean"
  end
  FileUtils.cd "build" do
    FileUtils.rm_rf Dir.glob("R2P2*.*")
  end
  begin
    sh "cmake --build build --target clean"
  rescue => e
    puts "Ignoring an error: #{e.message}"
  end
end
