# DNS zone for tahoe-lafs.org
# with 1-hour TTL to support migration
resource "hetznerdns_zone" "tl-org" {
  name = "tahoe-lafs.org"
  ttl  = 3600
}

# Root records of this zone
resource "hetznerdns_record" "tl-org" {
  for_each = {
    # <type>-<index> = <value>
    ns-1  = "hydrogen.ns.hetzner.com.",
    ns-2  = "oxygen.ns.hetzner.com.",
    ns-3  = "helium.ns.hetzner.de.",
    mx-1  = "50 tahoe-lafs.org.",
    txt-1 = "v=spf1 ip4:74.207.252.227/32",
    a-1   = "74.207.252.227"
  }

  name    = "@"
  type    = upper(split("-", each.key)[0])
  value   = each.value
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}

# Web landing page
resource "hetznerdns_record" "tl-org_www" {
  name    = "www"
  type    = "CNAME"
  value   = "tahoe-lafs.org."
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}

# Mailing lists
resource "hetznerdns_record" "tl-org_lists" {
  for_each = {
    # <type>-<index> = <value>
    mx-1   = "5 smtp1.osuosl.org.",
    mx-2   = "5 smtp2.osuosl.org.",
    mx-3   = "5 smtp3.osuosl.org.",
    mx-4   = "5 smtp4.osuosl.org.",
    txt-1  = "v=spf1 mx include:_spf.osuosl.org ~all",
    a-1    = "140.211.9.53"
    aaaa-1 = "2605:bc80:3010:104::8cd3:935"
  }

  name    = "lists"
  type    = upper(split("-", each.key)[0])
  value   = each.value
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}

# Testgrid - trac#4160
resource "hetznerdns_record" "tl-org_testgrid_ipv4" {
  name    = "testgrid"
  type    = "A"
  value   = hcloud_server.testgrid.ipv4_address
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}

resource "hetznerdns_record" "tl-org_testgrid_ipv6" {
  name    = "testgrid"
  type    = "AAAA"
  value   = hcloud_server.testgrid.ipv6_address
  ttl     = hetznerdns_zone.tl-org.ttl
  zone_id = hetznerdns_zone.tl-org.id
}
