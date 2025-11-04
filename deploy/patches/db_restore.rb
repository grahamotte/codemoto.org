class DbRestorePatch < BasePatch
  class << self
    def always
      Cmd.ssh("sudo apt-get install -y awscli") unless $instance.installed?("aws")

      key = backup_keys.last
      path = File.join($constants.remote_home_dir, key)

      aws_cmd("s3 cp s3://#{$constants.backup_bucket}/#{key} #{path}")

      Cmd.ssh("psql #{$constants.db_name} < #{path}")
      $instance.start_service(:postgresql)

      Cmd.ssh("rm -f #{path}")
    end

    private

    def aws_cmd(cmd)
      Cmd.ssh(
        [
          "export AWS_ACCESS_KEY_ID=#{$constants.backup_access_key_id};",
          "export AWS_SECRET_ACCESS_KEY=#{$constants.backup_secret_access_key};",
          "export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED;",
          "export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED;",
          "aws --endpoint-url #{$constants.backup_endpoint}",
          cmd,
        ].join(" ")
      )
    end

    def backup_keys
      result = aws_cmd("s3 ls s3://#{$constants.backup_bucket}/")

      result
        .split("\n")
        .map(&:split)
        .map(&:last)
        .select { |x| x.present? && x.start_with?($constants.db_name) }
        .sort
    end
  end
end

# module Patches
#   class DbRestore < Base
#     class << self
#       def needed?
#         return false unless backups_setup?
#         return false unless Instance.exists?

#         true
#       end

#       def apply
#         Instance.stop_service(:postgresql)
#         sleep(5)

#         install_aws_cli

#         key = backup_keys.last
#         path = "#{home}/#{key}"

#         remote_cmd("#{aws_cli_s3} cp s3://#{Secrets.all.dig(:backup_bucket, :bucket)}/#{key} #{path}")
#         remote_cmd("psql #{db_name} < #{path}")

#         sleep(5)
#         Instance.start_service(:postgresql)
#       ensure
#         remote_cmd("rm -f #{path}")
#       end
#     end
#   end
# end
