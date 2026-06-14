{ config, lib, pkgs, ... }:

{
  networking.firewall.enable  = false;
  networking.nftables.enable  = true;

  services.openssh = {
    enable      = true;
    openFirewall = false;
  };

  networking.nftables.ruleset = ''
    table inet offload {
      flowtable f {
        hook ingress priority 0;
        devices = { enp1s0, enp2s0 };
      }
    }

    # ── Early ingress hardening (netdev, runs before routing) ────
    table netdev filter {
      chain ingress_wan {
        type filter hook ingress device enp1s0 priority -500;

        tcp flags & (fin|syn)                 == (fin|syn)                 drop
        tcp flags & (syn|rst)                 == (syn|rst)                 drop
        tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|syn|rst|psh|ack|urg) drop
        tcp flags & (fin|syn|rst|psh|ack|urg) == 0                         drop
        tcp flags syn tcp option maxseg size 0-500 drop

        ip  protocol icmp   limit rate 5/second accept
        ip  protocol icmp   drop
        ip6 nexthdr  icmpv6 limit rate 5/second accept
        ip6 nexthdr  icmpv6 drop

        fib saddr . iif oif missing drop

        fib daddr . iif type != local drop
      }
    }

    table inet global {

      chain inbound_wan {
        drop
      }

      chain inbound_lan {
        accept
      }

      chain input {
        type filter hook input priority 0; policy drop;

        ct state vmap {
          established : accept,
          related     : accept,
          invalid     : drop
        }

        tcp flags & syn != syn ct state new drop

        iifname vmap {
          lo      : accept,
          enp1s0  : jump inbound_wan,
          enp2s0  : jump inbound_lan,
        }
      }

      chain forward {
        type filter hook forward priority 0; policy drop;

        ct state vmap {
          established : accept,
          related     : accept,
          invalid     : drop
        }

        ip  protocol { tcp, udp } flow offload @inet#offload#f
        ip6 nexthdr  { tcp, udp } flow offload @inet#offload#f

        iifname enp2s0 oifname enp1s0 accept
      }

      chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        iifname enp2s0 oifname enp1s0 masquerade
      }
    }
  '';
}
