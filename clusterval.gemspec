# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{clusterval}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Trevor Fountain"]
  s.date = %q{2010-06-30}
  s.default_executable = %q{clusterval}
  s.description = %q{Given two clusterings over a set of items, calculate an objective scoring (F-Score) for how well one matches the other. Uses the method described in "Semeval-2007 Task 02: Evaluating Word Sense Induction and Discrimination Systems", E. Agirre and A. Soroa.}
  s.email = %q{doches@gmail.com}
  s.executables = ["clusterval"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/clusterval",
     "clusterval.gemspec",
     "lib/clusterval.rb",
     "test/clusterval_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/doches/clusterval}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Unsupervised evaluation of clusters using F-Score}
  s.test_files = [
    "test/test_helper.rb",
     "test/clusterval_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
