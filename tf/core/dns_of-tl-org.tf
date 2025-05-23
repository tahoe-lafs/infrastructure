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
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}
# TODO: Move the above in a separate `dns_tl-org.tf` file
# when/if we end up managing the full zone

# Here under should come records in `of.tahoe-lafs.org` only
resource "hetznerdns_record" "tl-org-of_webforge_ipv4" {
  name    = "webforge.of"
  type    = "A"
  value   = hcloud_server.webforge.ipv4_address
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}

resource "hetznerdns_record" "tl-org-of_webforge_ipv6" {
  name    = "webforge.of"
  type    = "AAAA"
  value   = hcloud_server.webforge.ipv6_address
  ttl     = hetznerdns_zone.tl-org.ttl
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
  value   = "webforge.of.tahoe-lafs.org."
  ttl     = "600"
  zone_id = hetznerdns_zone.tl-org.id
}
