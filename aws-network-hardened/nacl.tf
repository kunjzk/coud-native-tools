
# Remove all rules from default NACL - stops prowler from complaining
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  # No ingress or egress blocks here = everything denied
  # (default NACL rule = *deny all* if no explicit allow)
  
  tags = merge(local.tags, {
    Name = "Default NACL (DO NOT USE, deny all traffic)"
  }) 
}


# Custom NACL
resource "aws_network_acl" "web_nacl" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {
    Name = "Web NACL"
  })
}

## INGRESS rules (into subnet)
# Allow HTTP
resource "aws_network_acl_rule" "in_http" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS
resource "aws_network_acl_rule" "in_https" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Block inbound RDP (explicilty deny RDP traffic)
resource "aws_network_acl_rule" "in_rdp" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}


# Allow inbound ephemeral (responses to outbound connections)
resource "aws_network_acl_rule" "in_ephemeral" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


## EGRESS rules (out of subnet)
# Allow HTTPS out
resource "aws_network_acl_rule" "out_https" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow HTTP out (optional; keep if your instances need it)
resource "aws_network_acl_rule" "out_http" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow outbound ephemeral (responses to inbound 80/443)
resource "aws_network_acl_rule" "out_ephemeral" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 220
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

## Associate NACL to the main subnet (replaces default)
resource "aws_network_acl_association" "web_nacl_assoc" {
  subnet_id      = aws_subnet.public_main.id
  network_acl_id = aws_network_acl.web_nacl.id
}

## Associate NACL to the second subnet (replaces default)
resource "aws_network_acl_association" "web_nacl_assoc_second" {
  subnet_id      = aws_subnet.public_second.id
  network_acl_id = aws_network_acl.web_nacl.id
}

# Create a new NACL for the private subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {
    Name = "Private NACL"
  })
}

## INGRESS rules (into private subnet)
# Allow inbound traffic from ALB on port 80
resource "aws_network_acl_rule" "in_alb_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/16"
  from_port      = 80
  to_port        = 80
}

# Allow inbound traffic from ALB on ephemeral ports
resource "aws_network_acl_rule" "in_ephemeral_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Deny inbound traffic on port 22 and 3389
resource "aws_network_acl_rule" "in_deny_ssh_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "in_deny_rdp_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}
## EGRESS rules (out of private subnet)
# Allow outbound traffic to the internet
resource "aws_network_acl_rule" "out_internet_https_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow outbound traffic to the internet
resource "aws_network_acl_rule" "out_internet_http_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 205
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow outbound traffic to the internet on ephemeral ports
resource "aws_network_acl_rule" "out_internet_ephemeral_private" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

## Associate NACL to the private subnet (replaces default)
resource "aws_network_acl_association" "private_nacl_assoc" {
  subnet_id      = aws_subnet.private.id
  network_acl_id = aws_network_acl.private_nacl.id
} 