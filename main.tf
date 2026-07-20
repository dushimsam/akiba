terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "custom_api_vm" {
  # Triggers ensure this runs again if the URL changes
  triggers_replace = [
    var.server_api_url
  ]

  # Executes the POST request on 'terraform apply'
  provisioner "local-exec" {
    command = <<EOT
      curl -X POST "${var.server_api_url}" \
        -H "Authorization: Bearer ${var.bearer_api_key}" \
        -H "Content-Type: application/json" \
        -d '{
          "hostName": "terraform-vm-test",
           "image": "UBUNTU-24.04",
           "publicKeys": [
                "ssh-ed25519 AAAAC3NzaC1lDI1NTE5UUUAINNmDDADm0XCfgg+pZLnGz4eSO1mQnUd3W+l2x3NR1w user@MacBook-Pro-2.local"
            ],
            "region": "KGL-1",
            "specification": "S-1C-1G",
            "tags": [
                "public-api",
                "web"
            ],
            "withPublicIp": true
        }'
    EOT
  }
}
