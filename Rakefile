require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.rubyforge_project = gem.name = "haml"
    gem.version = '2.1.0'
    gem.summary = "An elegant, structured XHTML/XML templating engine.\nComes with Sass, a similar CSS templating engine."
    gem.homepage = "http://github.com/wireframe/haml"
    gem.authors = ['Nathan Weizenbaum', 'Hampton Catlin']
    gem.email = 'haml@googlegroups.com'
    gem.description = <<-END
        Haml (HTML Abstraction Markup Language) is a layer on top of XHTML or XML
        that's designed to express the structure of XHTML or XML documents
        in a non-repetitive, elegant, easy way,
        using indentation rather than closing tags
        and allowing Ruby to be embedded with ease.
        It was originally envisioned as a plugin for Ruby on Rails,
        but it can function as a stand-alone templating engine.
      END
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

# ----- Benchmarking -----

desc <<END
Benchmark haml against ERb.
  TIMES=n sets the number of runs. Defaults to 1000.
END
task :benchmark do
  sh "ruby test/benchmark.rb #{ENV['TIMES']}"
end

# ----- Default: Testing ------

if ENV["RUN_CODE_RUN"] == "true"
  task :default => :"test:rails_compatibility"
else
  task :default => :test
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  test_files = FileList['test/**/*_test.rb']
  test_files.exclude('test/rails/*')
  t.test_files = test_files
  t.verbose = true
end
Rake::Task[:test].send(:add_comment, <<END)
To run with an alternate version of Rails, make test/rails a symlink to that version.
END

# ----- Documentation -----

begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

Rake::RDocTask.new do |rdoc|
  rdoc.title    = 'Haml/Sass'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include(*FileList.new('*') do |list|
                            list.exclude(/(^|[^.a-z])[a-z]+/)
                            list.exclude('TODO')
                          end.to_a)
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('TODO')
  rdoc.rdoc_files.exclude('lib/haml/buffer.rb')
  rdoc.rdoc_files.exclude('lib/sass/tree/*')
  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc'
end

# ----- Coverage -----

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts << '-x' << '"^\/"'
    if ENV['NON_NATIVE']
      t.rcov_opts << "--no-rcovrt"
    end
    t.verbose = true
  end
rescue LoadError; end

# ----- Profiling -----

begin
  require 'ruby-prof'

  desc <<END
Run a profile of haml.
  ENGINE=str sets the engine to be profiled. Defaults to Haml.
  TIMES=n sets the number of runs. Defaults to 1000.
  FILE=str sets the file to profile.
    Defaults to 'standard' for Haml and 'complex' for Sass.
  OUTPUT=str sets the ruby-prof output format.
    Can be Flat, CallInfo, or Graph. Defaults to Flat. Defaults to Flat.
END
  task :profile do
    engine = (ENV['ENGINE'] || 'haml').downcase
    times  = (ENV['TIMES'] || '1000').to_i
    file   = ENV['FILE']

    if engine == 'sass'
      require 'lib/sass'

      file = File.read("#{File.dirname(__FILE__)}/test/sass/templates/#{file || 'complex'}.sass")
      result = RubyProf.profile { times.times { Sass::Engine.new(file).render } }
    else
      require 'lib/haml'

      file = File.read("#{File.dirname(__FILE__)}/test/haml/templates/#{file || 'standard'}.haml")
      obj = Object.new
      Haml::Engine.new(file).def_method(obj, :render)
      result = RubyProf.profile { times.times { obj.render } }
    end

    RubyProf.const_get("#{(ENV['OUTPUT'] || 'Flat').capitalize}Printer").new(result).print 
  end
rescue LoadError; end

# ----- Testing Multiple Rails Versions -----

rails_versions = [
  "v2.3.0",
  "v2.2.2",
  "v2.1.2",
  "v2.0.5"
]

namespace :test do
  desc "Test all supported versions of rails. This takes a while."
  task :rails_compatibility do
    `rm -rf test/rails`
    puts "Checking out rails. Please wait."
    `git clone git://github.com/rails/rails.git test/rails` rescue nil
    begin
      rails_versions.each do |version|
        Dir.chdir "test/rails" do
          `git checkout #{version}`
        end
        puts "Testing Rails #{version}"
        Rake::Task['test'].reenable
        Rake::Task['test'].execute
      end
    ensure
      `rm -rf test/rails`
    end
  end
end
