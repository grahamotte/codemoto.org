require_relative "lib/require"

Apps::ValidationPatch.call
Apps::BuildPatch.call
Apps::RevisionPatch.call
Apps::UploadPatch.call
Apps::SubmitPatch.call
