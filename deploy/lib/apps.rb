require "fileutils"
require "json"
require "openssl"
require "tempfile"

module Apps
  class << self
    attr_writer :root, :tmp_root

    def root = @root || File.join(Constants.local_root, "apps")
    def tmp_root = @tmp_root || File.join(Constants.local_root, "deploy", "tmp", "apps")
    def config = @config ||= read_json(File.join(root, "config.json"))
    def version = config.fetch(:version)
    def release = @release ||= read_json(File.join(root, "versions", "#{version}.json"))
    def build = version
    def export_options_path = File.join(root, "apple", "App", "Config", "ExportOptions.plist")

    def targets
      @targets ||= config
        .dig(:targets, :apple)
        .map { |name, target| target.merge(name:) }
    end

    def archive_path(target)
      File.join(tmp_root, version, "#{target.fetch(:name)}.xcarchive")
    end

    def export_path(target)
      File.join(tmp_root, version, "#{target.fetch(:name)}-export")
    end

    def project_path(target)
      File.expand_path(target.fetch(:project), Constants.local_root)
    end

    def private_key
      @private_key ||= OpenSSL::PKey.read(ENV.fetch("APPLE_KEY_SECRET_BASE64").unpack1("m0"))
    end

    def private_key_path
      return @private_key_file.path if @private_key_file.present?

      @private_key_file = Tempfile.new([ "app-store-connect", ".p8" ])
      @private_key_file.chmod(0600)
      @private_key_file.write(ENV.fetch("APPLE_KEY_SECRET_BASE64").unpack1("m0"))
      @private_key_file.close
      @private_key_file.path
    end

    def authentication_arguments
      [
        "-authenticationKeyPath",
        private_key_path,
        "-authenticationKeyID",
        ENV.fetch("APPLE_KEY_ID"),
        "-authenticationKeyIssuerID",
        ENV.fetch("APPLE_ISSUER_ID"),
      ]
    end

    def reset
      @private_key_file&.unlink
      @config = nil
      @release = nil
      @targets = nil
      @private_key = nil
      @private_key_file = nil
      @root = nil
      @tmp_root = nil
    end

    private

    def read_json(path)
      JSON.parse(File.read(path), symbolize_names: true)
    rescue JSON::ParserError => error
      raise "Invalid JSON in #{path}: #{error.message}"
    end
  end
end
