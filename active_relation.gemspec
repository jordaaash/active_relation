# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: active_relation 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_relation"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jordan Sexton"]
  s.date = "2015-09-08"
  s.description = "Arel-based ORM that abstracts ActiveRecord models for creating APIs."
  s.email = "jordan@jordansexton.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "active_relation.gemspec",
    "lib/active_relation.rb",
    "lib/active_relation/associations.rb",
    "lib/active_relation/create_update_destroy.rb",
    "lib/active_relation/empty_node.rb",
    "lib/active_relation/errors.rb",
    "lib/active_relation/execute.rb",
    "lib/active_relation/field_hash.rb",
    "lib/active_relation/fields.rb",
    "lib/active_relation/functions.rb",
    "lib/active_relation/gem_version.rb",
    "lib/active_relation/group.rb",
    "lib/active_relation/include.rb",
    "lib/active_relation/join.rb",
    "lib/active_relation/limit.rb",
    "lib/active_relation/model.rb",
    "lib/active_relation/order.rb",
    "lib/active_relation/query.rb",
    "lib/active_relation/regexp.rb",
    "lib/active_relation/relation.rb",
    "lib/active_relation/select.rb",
    "lib/active_relation/version.rb",
    "lib/active_relation/where.rb",
    "lib/arel/null_order_predications.rb",
    "test/helper.rb",
    "test/test_active_relation.rb"
  ]
  s.homepage = "http://github.com/jordansexton/active_relation"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Arel-based ORM that abstracts ActiveRecord models for creating APIs."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.2.21"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 3.2.21"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.2.21"])
      s.add_dependency(%q<activerecord>, ["~> 3.2.21"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.2.21"])
    s.add_dependency(%q<activerecord>, ["~> 3.2.21"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

