# frozen_string_literal: true

require 'vernier'
require 'fileutils'

# rubocop:disable Style/Documentation
class Profile
  # rubocop:enable Style/Documentation
  class << self
    def call(&block)
      raise ArgumentError, 'Block required' unless block_given?

      profile_file = '/tmp/profile.json'
      FileUtils.rm_f(profile_file)

      Vernier.profile(out: profile_file) do
        block.call
      end

      raise 'Profiling failed - profile.json was not created' unless File.exist?(profile_file)

      open_viewer(profile_file)
    end

    private

    def open_viewer(profile_file)
      if ENV['CURSOR_AGENT'] == '1'
        system('LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8', 'vernier', 'view', '--top', '100', '--', profile_file)
      else
        system('profile-viewer', profile_file)
      end
    end
  end
end
