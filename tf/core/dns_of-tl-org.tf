# Hetzner does not support zone for sub-domain like
# `of.tahoe-lafs.org`, so we need to start from the parent
# even if we want to manage only the sub one here

# DNS zone for tahoe-lafs.org
# with 1-hour TTL to support migration
resource "hetznerdns_zone" "tl-org" {
  name = "tahoe-lafs.org"
  ttl  = 3600
}

# NS records of the zone
resource "hetznerdns_record" "tl-org_ns" {
  for_each = {
    primary   = "hydrogen.ns.hetzner.com."
    secondary = "oxygen.ns.hetzner.com."
    tertiary  = "helium.ns.hetzner.de."
  }

  name    = "@"
  type    = "NS"
  value   = each.value
  zone_id = hetznerdns_zone.tl-org.id
}
# TODO: Move the above in a separate `dns_tl-org.tf` file
# when/if we end up managing the full zone

# Here under should come records in `of.tahoe-lafs.org` only
resource "hetznerdns_record" "tl-org-of_webforge_ipv4" {
  name    = "webforge.of"
  type    = "A"
  value   = hcloud_server.webforge.ipv4_address
  zone_id = hetznerdns_zone.tl-org.id
}

resource "hetznerdns_record" "tl-org-of_webforge_ipv6" {
  name    = "webforge.of"
  type    = "AAAA"
  value   = hcloud_server.webforge.ipv6_address
  zone_id = hetznerdns_zone.tl-org.id
}

resource "hetznerdns_record" "tl-org-of_webforge_aliases" {
  for_each = toset([
    "forge",
    "home",
    "legacy",
    "preview",
  ])

  name    = "${each.value}.of"
  type    = "CNAME"
  value   = "webforge.of"
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}

# Better have an MX record to webforge, even if it will only send
resource "hetznerdns_record" "tl-org-of_forge_mx" {
  name    = "forge.of"
  type    = "MX"
  value   = "0 webforge.of.${hetznerdns_zone.tl-org.name}."
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}

# Explicitely authorize sending email from webforge IPs
resource "hetznerdns_record" "tl-org-of_forge_spf" {
  name    = "forge.of"
  type    = "TXT"
  value   = "v=spf1 a:webforge.of.${hetznerdns_zone.tl-org.name} -all"
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}

# Public DKIM keys used to sign emails send from webforge
resource "hetznerdns_record" "tl-org-of_forge_dkim" {
  name    = "mail._domainkey.forge.of"
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC/QgivKbeRtd1wETUE+DWCYzkNwFh6H/RfiyOEvzOW/lTU3CMc25T+/h6/5iHk0Kjxu8zdYB3n4llgeM28XSVuQBToedhL2p1X3UlJkMb+8Zm10o7aqBppUG+4MPCiqXwgTtk9FQq/s/iojIMrvyfNqdRYIsmmSZppfXIvEBYcEQIDAQAB"
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}

# Be a good citizen and catch DMARC reports (via Least Authority for now)
resource "hetznerdns_record" "tl-org-of_forge_dmarc" {
  name    = "_dmarc.forge.of"
  type    = "TXT"
  value   = "v=DMARC1; p=none; rua=mailto:tahoe@leastauthority.com"
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}
