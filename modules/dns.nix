{ config, lib, pkgs, ... }:

{
  services.unbound = {
    enable = true;
    resolveLocalQuries = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" "192.168.1.1"];
        access-control = [ "0.0.0.0/0 refuse" "127.0.0.1/32 allow" "192.168.1.0/24 allow"];
        port = 53;

        hide-identity = true;
        hide-version = true;
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = true;
        prefetch = true;
        aggressive-nsec = true;

        local-zone = [ '''"casa." static'' ];
        local-data = [
          '"router.casa IN A 192.168.1.1"'
        ];
      };

      forward-zone = [{
        name = ".";
        forward-tls-upstream = true;
        forward-addr = [
          "1.1.1.1@cloudfare-dns.com"
          "1.0.0.1@cloudfare-dns.com"
          "8.8.8.8@dns.google"
          "9.9.9.9@853#dns.quad9.net"
        ];
      }];
  };
};
  
  networking.nameservers = [ "127.0.0.1" ];
  networking.resolvconf.useLocalResolver = true;
}
