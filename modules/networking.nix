{ config, lib, pkgs, ... }:

{
  networking.hostName = "quartz";
  networking.hostId = "625673fb4a24af96";
  time.timeZone = "America/New_York";

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp2s0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.1";
      prefixLength = 24;
    }];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_fitler" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
    "net.ipv6.conf.enp1s0.accept_ra" = 2;
    "net.ipv6.conf.enp1s0.autoconf" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.enp1s0.rp_filter" = 1;
    "net.ipv4.conf.enp2s0.rp_filter" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };

  environment.systemPackages = with pkgs; [
    ethtool
    tcpdump
    iproute2
    nftables
  ];
}
