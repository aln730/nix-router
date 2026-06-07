{ config, lib, pkgs, ... };

{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ "enp2s0" ];

      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };

      subnet4 = [{
        subnet = "192.168.1.0/24";
        pools = [{ pool = "192.168.1.100 - 192.168.1.200"; }];
        option-data = [
          { name = "routers";             data = "192.168.1.1"; }
          { name = "domain-name-servers"; data = "192.168.1.1"; }
          { name = "domain-name";         data = "casa"; }
        ];
        valid-lifetime = 86400;
        max-valid-lifetime = 86400;
      }];
    };
  };
}
