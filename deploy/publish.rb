require_relative "lib/require"

Apps.submit_for_review = ENV.fetch("PUBLISH_NO_REVIEW", "false") != "true"

Apps::ValidationPatch.call
Apps::BuildPatch.call
Apps::RevisionPatch.call
Apps::UploadPatch.call
Apps::SubmitPatch.call
