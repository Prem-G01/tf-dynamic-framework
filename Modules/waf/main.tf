resource "google_compute_security_policy" "waf" {

  name = var.policy_name

  description = "Enterprise WAF Policy"

  ############################################
  # ALLOW RULE
  ############################################

  rule {

    action = "allow"

    priority = 1000

    match {

      versioned_expr = "SRC_IPS_V1"

      config {

        src_ip_ranges = ["*"]
      }
    }

    description = "Allow Traffic"
  }

  ############################################
  # DEFAULT RULE
  ############################################

  rule {

    action = "deny(403)"

    priority = 2147483647

    match {

      versioned_expr = "SRC_IPS_V1"

      config {

        src_ip_ranges = ["*"]
      }
    }

    description = "Default Deny Rule"
  }
}