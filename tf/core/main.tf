# There is no remote state backend for the resources defined in this project.
# TODO: Assess if we could/should use one instead of committing the tfstate file.

# Lets make the local state explicit and remind contributors to commit changes
terraform {
  # https://opentofu.org/docs/language/settings/backends/s3/
  backend "s3" {
    bucket               = "tf-state-tahoe-infra"
    encrypt              = true
    key                  = "state"
    workspace_key_prefix = "wks:"

    region         = "eu-central-1"
    dynamodb_table = "tf-state-tahoe-infra"
  }
}
