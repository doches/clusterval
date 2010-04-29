require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "clusterval"
    gem.summary = %Q{Unsupervised evaluation of clusters using F-Score}
    gem.description = %Q{Given two clusterings over a set of items, calculate an objective scoring (F-Score) for how well one matches the other. Uses the method described in "Semeval-2007 Task 02: Evaluating Word Sense Induction and Discrimination Systems", E. Agirre and A. Soroa.}
    gem.email = "doches@gmail.com"
    gem.homepage = "http://github.com/doches/clusterval"
    gem.authors = ["Trevor Fountain"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

gem 'rdoc'
require 'rdoc'
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "clusterval #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.main = "README.rdoc"
  rdoc.options += %w{-SHN -f darkfish}
end
