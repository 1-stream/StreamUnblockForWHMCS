<?php

require_once __DIR__ . '/MaxMind-DB-Reader-php/autoload.php';

use MaxMind\Db\Reader;

function domain_resolv($domain)
{
    $ip_rgx = "/^(((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))\\.){3}((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))$/i";
    if (preg_match($ip_rgx, $domain)) {
        return $domain;
    }
    $dns_res =  dns_get_record($domain, DNS_A);
    if (!$dns_res) {
        return 1;
    }
    if (count($dns_res) > 1) {
        return 2;
    }
    return $dns_res[0]['ip'];
}

function ips_pre_test($domain)
{
    $dns_res = domain_resolv($domain);
    if ($dns_res == 1) {
        return "域名 " . $domain . " 空解析";
    }
    if ($dns_res == 2) {
        return "域名 " . $domain . " 存在2条或以上A记录,可能使用了CDN,请直接添加服务器出口ip";
    }
    $reader = new Reader(__DIR__ . '/GeoLite2-ASN.mmdb');
    $ip_res = $dns_res;
    $geo_res = $reader->get($ip_res);
    $ip_asn = $geo_res['autonomous_system_number'];
    if ($ip_asn == 13335) {
        return "域名 " . $domain . " 可能使用了Cloudflare小云朵或Warp,请直接添加服务器出口ip";
    }
    if ($ip_asn == 4809 || $ip_asn == 4134 || $ip_asn == 4837 || $ip_asn == 9808) {
        return "域名 " . $domain . " ASN黑名单";
    }
    return 0;
}

function get_ip($domain)
{
    $ip_rgx = "/^(((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))\\.){3}((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))$/i";
    if (preg_match($ip_rgx, $domain)) {
        return $domain;
    }
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379);
    $redis->select(15);
    if (!$redis->exists($domain)) {
        $redis->set($domain, domain_resolv($domain));
    }
    return $redis->get($domain);
}
