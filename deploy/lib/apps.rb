require "fileutils"
require "digest"
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
    def build = config.fetch(:build)
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

    def revision_path(target)
      extension = target.fetch(:platform) == "MAC_OS" ? "zip" : "ipa"
      name = config.fetch(:name).gsub(/[^A-Za-z0-9]+/, "-").sub(/\A-/, "").sub(/-\z/, "")
      File.join(tmp_root, version, "revisions", "#{name}-#{target.fetch(:name)}-#{version}.#{extension}")
    end

    def revision_export_path(target)
      File.join(tmp_root, version, "#{target.fetch(:name)}-revision-export")
    end

    def revision_repositories
      [ Constants.codeberg_repo, Constants.github_repo ].map { |repo| revision_repository(repo) }
    end

    def project_path(target)
      File.expand_path(target.fetch(:project), Constants.local_root)
    end

    def screenshot_path(screenshot)
      File.expand_path(screenshot.fetch(:path), Constants.local_root)
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

    def with_signing_certificate(name, prefix)
      keychain = File.join(tmp_root, "signing-#{Process.pid}.keychain-db")
      password = "#{prefix}_CERTIFICATE_PASSWORD"
      previous = Cmd.local("security list-keychains -d user").scan(/\"([^\"]+)\"/).flatten
      FileUtils.mkdir_p(tmp_root)
      Tempfile.create([ "signing", ".p12" ]) do |certificate|
        certificate.binmode
        certificate.write(ENV.fetch("#{prefix}_CERTIFICATE_BASE64").unpack1("m0"))
        certificate.close
        Tempfile.create([ "signing", ".pem" ]) do |pem|
          pem.close
          Tempfile.create([ "signing-modern", ".p12" ]) do |modern|
            modern.close
            openssl = "\"$(brew --prefix openssl)/bin/openssl\""
            Cmd.local("#{openssl} pkcs12 -legacy -in #{Shellwords.escape(certificate.path)} -passin env:#{password} -nodes -out #{Shellwords.escape(pem.path)}")
            Cmd.local("#{openssl} pkcs12 -export -in #{Shellwords.escape(pem.path)} -out #{Shellwords.escape(modern.path)} -passout env:#{password}")
            FileUtils.rm_f(keychain)
            Cmd.local("security create-keychain -p \"$#{password}\" #{Shellwords.escape(keychain)}")
            Cmd.local("security unlock-keychain -p \"$#{password}\" #{Shellwords.escape(keychain)}")
            Cmd.local("security import #{Shellwords.escape(modern.path)} -k #{Shellwords.escape(keychain)} -f pkcs12 -P \"$#{password}\" -T /usr/bin/codesign -T /usr/bin/security")
            Cmd.local("security set-key-partition-list -S apple-tool:,apple: -s -k \"$#{password}\" #{Shellwords.escape(keychain)}")
            identities = Cmd.local(Shellwords.join([ "security", "find-identity", "-v", "-p", "codesigning", keychain ]))
            raise "Missing #{name} identity" unless identities.include?(name)
            Cmd.local(Shellwords.join([ "security", "list-keychains", "-d", "user", "-s", keychain, *previous ]))
            yield keychain
          end
        end
      ensure
        Cmd.local(Shellwords.join([ "security", "list-keychains", "-d", "user", "-s", *previous ])) if previous.present?
        Cmd.local(Shellwords.join([ "security", "delete-keychain", keychain ])) rescue StandardError
      end
    end

    def reset
      @private_key_file&.unlink
      @config = nil
      @targets = nil
      @private_key = nil
      @private_key_file = nil
      @root = nil
      @tmp_root = nil
    end

    private

    def revision_repository(repo)
      match = repo.match(%r{(?:ssh://)?git@([^/:]+)[:/](.+?)/(.+?)(?:\.git)?\z})
      raise "Invalid revision repository #{repo}" if match.blank?

      host, owner, name = match.captures
      case host
      when "codeberg.org"
        { api: "https://codeberg.org/api/v1", host:, name:, owner:, token: ENV.fetch("CODEBERG_TOKEN") }
      when "github.com"
        { api: "https://api.github.com", host:, name:, owner:, token: ENV.fetch("GITHUB_TOKEN") }
      else
        raise "Unsupported revision repository #{host}"
      end
    end

    def read_json(path)
      JSON.parse(File.read(path), symbolize_names: true)
    rescue JSON::ParserError => error
      raise "Invalid JSON in #{path}: #{error.message}"
    end
  end
end
