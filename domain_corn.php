<?php

require_once __DIR__ . '/ddns.php';
require_once __DIR__ . '/backend.php';

$redis = new Redis();
$redis->connect('127.0.0.1', 6379);
$redis->select(15);
$domains = $redis->keys("*");

foreach ($domains as $domain) {
    $old_ip = get_ip($domain);
    $new_ip = domain_resolv($domain);
    $user_id = get_user_by_ip($domain);
    if (!get_user_by_ip($domain)) {
        continue;
    }
    if ($old_ip == $new_ip) {
        continue;
    } else {
        $node_id = GetUserBySid($user_id)['node'];
        $redis->del($domain);
        echo "delete " . $domain . "\n";
        if ($new_ip == 1 || $new_ip == 2) {
            get_ip($domain);
        } else {
            UpdataAllBackendNginx([$old_ip], [$new_ip], $user_id);
            Updateadgwhitelist($node_id);
            Updateadgnodedns(GetNodeById($node_id));
            $redis1 = new Redis();
            $redis1->connect('127.0.0.1', 6379);
            $redis1->select(14);
            $redis1->set(get_ip($domain), $user['sid']);
        }
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, "https://api.telegram.org/bot5728960452:AAGuD_9u2sc3xhEf27FpqXDiNrWHoZFdLSc/sendMessage?chat_id=-1001510588935&parse_mode=HTML&text=%23DDNS%0A%E5%9F%9F%E5%90%8D%3A%3Ccode%3E" . $domain . "%3C/code%3E%0A%E6%94%B9%E5%8F%98%3A%3Ccode%3E" . $old_ip . "%3C/code%3E%20%3D%3E%20%3Ccode%3E" . $new_ip . "%3C/code%3E");
        $output = curl_exec($curl);
        curl_close($curl);
        echo "\n";
    }
}
echo "Done\n";
