<?php
require_once __DIR__ . '/sql.php';

function AdGuardRequest($node, $url, $data)
{
    if (!$node['auth'] | !$node['url'])
        return "error! no auth or backend url";
    $auth_header = array('Authorization:Basic ' . $node['auth']);
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $node['url'] . $url);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $auth_header);
    curl_setopt($curl, CURLOPT_TIMEOUT, 30);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, FALSE);
    if ($data) {
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
        // var_dump(json_encode($data));
    }
    $output = curl_exec($curl);
    // var_dump(curl_error($curl));
    // var_dump(curl_getinfo($curl));
    curl_close($curl);
    return $output;
}

function BackendRequest($backend, $url, $data = "")
{
    if (!$backend['token'])
        return "error";
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $backend['ip'] . '/' . $backend['token'] . '/' . $url);
    curl_setopt($curl, CURLOPT_TIMEOUT, 5);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, FALSE);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
    if ($data) {
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
    }
    $output = curl_exec($curl);
    // var_dump($output);
    curl_close($curl);
    return $output;
}

function Updateadgnodedns($node)
{
    $server = GetServerById($node['server_id']);
    $post_data = json_decode(base64_decode($node['post_body']), true);
    $ids = GetNodeIps($node['id']);
    if (empty($ids)) {
        $ids = [strval(time())];
    };
    $post_data['data']['ids'] = $ids;
    AdGuardRequest($server, '/control/clients/update', $post_data);
    return ($post_data);
}

function Updateadgwhitelist($node_id)
{
    $node = GetNodeById($node_id);
    $server = GetServerById($node['server_id']);
    $ips = CollectIpsByServer($node['server_id']);
    $ips = array_unique($ips);
    $ips = array_values($ips);
    return AdGuardRequest($server, '/control/access/set', array('allowed_clients' => $ips, 'blocked_hosts' => [], 'disallowed_clients' => []));
}

// function UpdateBackendDNSIpsInAeraAllNode($aera)
// {
//     $nodes = GetAeraAllNode($aera);
//     $ips = CollectIpsByAera($aera);
//     $ips = array_unique($ips);
//     $ips = array_values($ips);
//     // var_dump($ips);
//     foreach ($nodes as $node) {
//         AdGuardRequest($node, '/control/access/set', array('allowed_clients' => $ips, 'blocked_hosts' => [], 'disallowed_clients' => []));
//     }
//     return 1;
//     // return AdGuardRequest($nodes[1], '/control/access/set', array('allowed_clients' => $ips, 'blocked_hosts' => [], 'disallowed_clients' => []));
// }

function UpdataAllBackendNginx($old_ip, $new_ip, $user_id)
{
    $backends = GetAllBackend();
    $flows = 0;
    $new_ips = [];
    $old_ips = [];
    foreach ($old_ip as $ip) {
        $r_ip = get_ip($ip);
        if ($r_ip != 1 & $r_ip != 2) {
            array_push($old_ips, $r_ip);
        }
    }
    foreach ($new_ip as $ip) {
        $r_ip = get_ip($ip);
        if ($r_ip != 1 & $r_ip != 2) {
            array_push($new_ips, $r_ip);
        }
    }
    foreach ($backends as $backend) {
        $res = json_decode(BackendRequest($backend, 'update', array('old_ips' => json_encode($old_ips), 'new_ips' => json_encode($new_ips))), true);
        foreach ($old_ips as $ip) {
            $flows = $flows + $res[$ip];
            // var_dump($res->"127.0.0.1");
        }
        // var_dump($flows);
        UpdateUserFlow($user_id, $flows);
    }
    return 1;
}

function FetchAllTrafic()
{
    $backends = GetAllBackend();
    $userstraffic = [];
    foreach ($backends as $backend) {
        $res = json_decode(BackendRequest($backend, 'fetch'), true);
        if (is_array($res))
            foreach ($res as $ip => $traffic) {
                $userstraffic[get_user_by_ip($ip)] = $userstraffic[get_user_by_ip($ip)] + $res[$ip];
            }
    }
    // echo(json_encode($userstraffic));
    return $userstraffic;
}

function ReinAll()
{
    $backends = GetAllBackend();
    foreach ($backends as $backend) {
        BackendRequest($backend, 'rein');
    }
    return 1;
}

function DailyTrafficFetch()
{
    $userstraffic = FetchAllTrafic();
    $users = GetAllUsers();
    // var_dump($users);
    foreach ($users as $user) {
        UpdateUserFlow($user['sid'], $userstraffic[$user['sid']]);
    }
    ReinAll();
    return 1;
}


function UpdateConstomBackendDNS($node_id, $ips)
{
    $node = GetCostomDNSById($node_id);
    AdGuardRequest($node, '/control/access/set', array('allowed_clients' => $ips, 'blocked_hosts' => [], 'disallowed_clients' => []));
    return 1;
}
