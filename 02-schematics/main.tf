provider "ibm" {
  generation = 2
  region     = "us-south"
}

resource "ibm_is_ssh_key" "iac_test_key" {
  name       = "${var.project_name}-${var.environment}-key"
  public_key = var.public_key
}

resource "ibm_is_instance" "iac_test_instance" {
  name    = "${var.project_name}-${var.environment}-instance"
  image   = "r006-bb322b53-e1b2-4968-bc60-60c99ac50729"
  profile = "cx2-2x4"

  primary_network_interface {
    name            = "eth1"
    subnet          = ibm_is_subnet.iac_test_subnet.id
    security_groups = [ibm_is_security_group.iac_test_security_group.id]
  }

  vpc  = ibm_is_vpc.iac_test_vpc.id
  zone = "us-south-1"
  keys = [ibm_is_ssh_key.iac_test_key.id]

  user_data = <<-EOUD
              #!/bin/bash
              echo "Hello!" > index.html
              nohup busybox httpd -f -p ${var.port} &
              EOUD

  tags = ["iac-${var.project_name}-${var.environment}"]
}
