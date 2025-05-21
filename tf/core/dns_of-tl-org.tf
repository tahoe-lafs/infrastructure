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
