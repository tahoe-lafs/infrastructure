# DNS zone for tahoe-lafs.org
# with 1-hour TTL to support migration
resource "desec_domain" "dns_tl-org" {
  name = "tahoe-lafs.org"
  ttl  = 3600
}

# There is no way to get the data from the subdomain
# Let's use a local variable instead
locals {
  dns_tl-org = {
    nameservers = {
      primary   = "ns1.desec.io."
      secondary = "ns2.desec.org.",
    }
    ttl = 3600
  }
}

# Other root records of this zone
resource "desec_rrset" "tl-org_mx" {
  subname = "@"
  type    = "MX"
  records = ["50 tahoe-lafs.org."]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

resource "desec_rrset" "tl-org_spf1" {
  subname = "@"
  type    = "TXT"
  records = ["v=spf1 ip4:74.207.252.227/32"]
  ttl     = local.dns_tl-org.ttl
  domain  = local.dns_tl-org.name
}

resource "desec_rrset" "tl-org_ipv4" {
  subname = "@"
  type    = "A"
  records = ["74.207.252.227"]
  ttl     = local.dns_tl-org.ttl
  domain  = local.dns_tl-org.name
}

# Delegation for tahoeperf sub-domain
resource "desec_rrset" "tl-org_perf" {
  for_each = {
    primary   = "ns-cloud1.googledomains.com."
    secondary = "ns-cloud2.googledomains.com."
  }

  subname = "tahoeperf"
  type    = "NS"
  records = [each.value]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

# Web landing page
resource "desec_rrset" "tl-org_www" {
  subname = "www"
  type    = "CNAME"
  records = ["tahoe-lafs.org."]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

# Mailing lists
resource "desec_rrset" "tl-org_lists" {
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

  subname = "lists"
  type    = upper(split("-", each.key)[0])
  records = [each.value]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

# Buildmaster
resource "desec_rrset" "tl-org_buildmaster" {
  subname = "buildmaster"
  type    = "CNAME"
  records = ["tahoe-lafs.org."]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

# Wormwhole
resource "desec_rrset" "tl-org_wormhole" {
  subname = "wormhole"
  type    = "CNAME"
  records = ["relay.magic-wormhole.io."]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

# Testgrid - trac#4160
resource "desec_rrset" "tl-org_testgrid_ipv4" {
  subname = "testgrid"
  type    = "A"
  records = [hcloud_server.testgrid.ipv4_address]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}

resource "desec_rrset" "tl-org_testgrid_ipv6" {
  subname = "testgrid"
  type    = "AAAA"
  records = [hcloud_server.testgrid.ipv6_address]
  ttl     = local.dns_tl-org.ttl
  domain  = desec_domain.dns_tl-org.name
}
