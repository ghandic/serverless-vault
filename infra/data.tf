data "external" "vaultwarden_admin_hash" {
  program = [
    "docker", "run", "--rm", "abstractvector/argon2", "sh", "-c",
  "echo -n '${var.vaultwarden_admin_password}' | argon2 ${var.vaultwarden_admin_salt} -e | awk '{$1=$1; print \"{\\\"hash\\\":\\\"\" $0 \"\\\"}\"}'"]
}
