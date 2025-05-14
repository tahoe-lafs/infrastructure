# DNS sub-zone `of` tahoe-lafs.org
resource "hetznerdns_zone" "of-tl-org" {
  name = "of.tahoe-lafs.org"
  ttl  = 3600
}

# NS records of this sub-zone
resource "hetznerdns_record" "of-tl-org_ns" {
  for_each = toset([
    "hydrogen.ns.hetzner.com.",
    "oxygen.ns.hetzner.com.",
    "helium.ns.hetzner.de.",
  ])

  name    = "@"
  type    = "NS"
  value   = each.value
  ttl     = hetznerdns_zone.of-tl-org.ttl
  zone_id = hetznerdns_zone.of-tl-org.id
}
