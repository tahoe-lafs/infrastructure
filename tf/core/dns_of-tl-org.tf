# Here under should come records in `of.tahoe-lafs.org` only
resource "desec_rrset" "tl-org-of_webforge_ipv4" {
  subname = "webforge.of"
  type    = "A"
  records = [hcloud_server.webforge.ipv4_address]
  domain  = desec_domain.dns_tl-org.name
}

resource "desec_rrset" "tl-org-of_webforge_ipv6" {
  subname = "webforge.of"
  type    = "AAAA"
  records = [hcloud_server.webforge.ipv6_address]
  domain  = desec_domain.dns_tl-org.name
}

resource "desec_rrset" "tl-org-of_webforge_aliases" {
  for_each = toset([
    "home",
    "legacy",
    "preview",
  ])

  subname = "${each.value}.of"
  type    = "CNAME"
  records = ["webforge.of"]
  ttl     = "600"
  domain  = desec_domain.dns_tl-org.name
}

# MX and TXT for forge.of forbid CNAME, so re-use the A/AAAA
resource "desec_rrset" "tl-org-of_forge_ipv4" {
  subname = "forge.of"
  type    = "A"
  records = [hcloud_server.webforge.ipv4_address]
  domain  = desec_domain.dns_tl-org.name
}

resource "desec_rrset" "tl-org-of_forge_ipv6" {
  subname = "forge.of"
  type    = "AAAA"
  records = [hcloud_server.webforge.ipv6_address]
  domain  = desec_domain.dns_tl-org.name
}

# Better have an MX record to webforge, even if it will only send
resource "desec_rrset" "tl-org-of_forge_mx" {
  subname = "forge.of"
  type    = "MX"
  records = ["0 webforge.of.${hetznerdns_zone.tl-org.name}."]
  ttl     = "600"
  domain  = desec_domain.dns_tl-org.name
}

# Explicitely authorize sending email from webforge IPs
resource "desec_rrset" "tl-org-of_forge_spf" {
  subname = "forge.of"
  type    = "TXT"
  records = ["v=spf1 a:webforge.of.${hetznerdns_zone.tl-org.name} -all"]
  ttl     = "600"
  domain  = desec_domain.dns_tl-org.name
}

# Public DKIM keys used to sign emails send from webforge
resource "desec_rrset" "tl-org-of_forge_dkim" {
  subname = "mail._domainkey.forge.of"
  type    = "TXT"
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC/QgivKbeRtd1wETUE+DWCYzkNwFh6H/RfiyOEvzOW/lTU3CMc25T+/h6/5iHk0Kjxu8zdYB3n4llgeM28XSVuQBToedhL2p1X3UlJkMb+8Zm10o7aqBppUG+4MPCiqXwgTtk9FQq/s/iojIMrvyfNqdRYIsmmSZppfXIvEBYcEQIDAQAB"]
  ttl     = "600"
  domain  = desec_domain.dns_tl-org.name
}

# Be a good citizen and catch DMARC reports (via Least Authority for now)
resource "desec_rrset" "tl-org-of_forge_dmarc" {
  subname = "_dmarc.forge.of"
  type    = "TXT"
  records = ["v=DMARC1; p=none; rua=mailto:tahoe@leastauthority.com"]
  ttl     = "600"
  domain  = desec_domain.dns_tl-org.name
}
