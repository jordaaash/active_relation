require 'active_relation/gem_version'

module ActiveRelation
  # Returns the version of the currently loaded ActiveRelation as a <tt>Gem::Version</tt>
  def self.version
    gem_version
  end
end
