locals {
  # BIMI TXT value: v=BIMI1; l=<logo-url>; [a=<vmc-url>]
  bimi_value = trimspace(
    var.vmc_url == "" ?
    "v=BIMI1; l=${var.bimi_svg_url}" :
    "v=BIMI1; l=${var.bimi_svg_url}; a=${var.vmc_url}"
  )

  bimi_host = "${var.bimi_selector}._bimi.${var.identity_domain}"
}

resource "cloudflare_dns_record" "bimi_txt" {
  zone_id = var.cloudflare_zone_id
  name    = local.bimi_host
  type    = "TXT"
  content = local.bimi_value
  ttl     = 300
  proxied = false

  # Note: Tags removed due to Cloudflare plan limitations
}