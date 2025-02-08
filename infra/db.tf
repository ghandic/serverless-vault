resource "neon_project" "vaultwarden" {
  name                      = "something"
  region_id                 = "aws-ap-southeast-2"
  pg_version                = 17
  history_retention_seconds = 86400
}

resource "neon_endpoint" "vaultwarden" {
  project_id = neon_project.vaultwarden.id
  branch_id  = neon_branch.vaultwarden.id

  autoscaling_limit_min_cu = 0.25
  autoscaling_limit_max_cu = 1
}

resource "neon_branch" "vaultwarden" {
  project_id = neon_project.vaultwarden.id
  parent_id  = neon_project.vaultwarden.default_branch_id
  name       = "vaultwarden"
}

resource "neon_role" "vaultwarden" {
  project_id = neon_project.vaultwarden.id
  branch_id  = neon_branch.vaultwarden.id
  name       = "vaultwarden"
}

resource "neon_database" "vaultwarden" {
  project_id = neon_project.vaultwarden.id
  branch_id  = neon_branch.vaultwarden.id
  owner_name = neon_role.vaultwarden.name
  name       = "vaultwarden"
}

locals {
  neon_database_url = "postgresql://${neon_role.vaultwarden.name}:${neon_role.vaultwarden.password}@${neon_endpoint.vaultwarden.host}/${neon_database.vaultwarden.name}?sslmode=require"
}
