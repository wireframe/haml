module Haml
  module Version
    # Returns a hash representing the version of Haml.
    # The :major, :minor, and :teeny keys have their respective numbers.
    # The :string key contains a human-readable string representation of the version.
    # If Haml is checked out from Git,
    # the :rev key will have the revision hash.
    def version
      return @@version if defined?(@@version)

      config = YAML.load_file(scope('VERSION.yml'))
      @@version = {
        :major => config['major'],
        :minor => config['minor'],
        :teeny => config['patch']
      }
      @@version[:string] = [:major, :minor, :teeny].map { |comp| @@version[comp] }.compact.join('.')

      if File.exists?(scope('REVISION'))
        rev = File.read(scope('REVISION')).strip
        rev = nil if rev !~ /^([a-f0-9]+|\(.*\))$/
      end

      if (rev.nil? || rev == '(unknown)') && File.exists?(scope('.git/HEAD'))
        rev = File.read(scope('.git/HEAD')).strip
        if rev =~ /^ref: (.*)$/
          rev = File.read(scope(".git/#{$1}")).strip
        end
      end

      if rev
        @@version[:rev] = rev
        unless rev[0] == ?(
          @@version[:string] << "."
          @@version[:string] << rev[0...7]
        end
      end

      @@version
    end

    # Returns the path of file relative to the Haml root.
    def scope(file) # :nodoc:
      File.expand_path File.join(File.dirname(__FILE__), '..', '..', file)
    end
  end
end
