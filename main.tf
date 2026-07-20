terraform {
  required_version = ">= 1.5.0"
}

locals {
  vm_request_body = jsonencode({
    hostName = "terraform-vm-test"
    image    = "UBUNTU-24.04"
    publicKeys = [
      "ssh-ed25519 AAAAC3NwwW1uZWQ1NTE5AAAAINNmDhXvDu0UCfgg+pZLnGz4eSO7m6nad3W+l2x3NR1w user@Mac-Pro.local"
    ]
    region        = "KGL-1"
    specification = "S-1C-1G"
    tags          = ["public-api", "web"]
    withPublicIp  = true
  })
}

resource "terraform_data" "custom_api_vm" {
  triggers_replace = [
    var.server_api_url,
    local.vm_request_body,
  ]

  provisioner "local-exec" {
    environment = {
      BEARER_API_KEY = var.bearer_api_key
    }
    
    command = <<EOT
      curl --fail-with-body -sS -X POST "${var.server_api_url}" \
        -H "Authorization: Bearer $BEARER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "Idempotency-Key: u1d951b1-8e27-368c-b00c-34924f0bfeed" \
        -d '${local.vm_request_body}' \
        -w '\nHTTP_STATUS:%%{http_code}\n'
    EOT
  }
}
