import os
import pyroute2
import requests
ipset_name = "users"
api_url = "http://100.64.69.3/modules/servers/StreamUnblock/white.php"
ips = pyroute2.ipset.IPSet()


class backend(object):
    def __init__(self):
        users = eval(requests.get(api_url).text)
        os.system("iptables -F&&iptables -X")
        # ipset
        try:
            ips.destroy(name=ipset_name)
        except:
            pass
        ips.create(name=ipset_name, stype='hash:ip', counters=True)
        for user in users:
            try:
                ips.add(name=ipset_name, entry=user)
            except:
                pass
        # iptables
        os.system("iptables -I INPUT -p tcp -m multiport --dports 443,80 -m set --match-set " +
                  ipset_name+" src -j ACCEPT")
        os.system("iptables -A INPUT -p tcp -m multiport --dports 443,80 -j DROP")
        os.system("iptables -I OUTPUT -p tcp -m multiport --sports 443,80 -m set --match-set " +
                  ipset_name+" dst")

    def add_ips(self, users_):
        for ip in users_:
            try:
                ips.add(name=ipset_name, entry=ip)
            except:
                pass

    def del_ips(self, users_):
        for ip in users_:
            try:
                ips.delete(name=ipset_name, entry=ip)
            except:
                pass

    def fetch(self):
        ip_list = ips.list(name=ipset_name)[0].get_attr(
            'IPSET_ATTR_ADT').get_attrs('IPSET_ATTR_DATA')
        res = {}
        for ip in ip_list:
            res[ip.get_attr('IPSET_ATTR_IP_FROM').get_attr(
                'IPSET_ATTR_IPADDR_IPV4')] = ip.get_attr('IPSET_ATTR_BYTES')
        return res


# backend()
