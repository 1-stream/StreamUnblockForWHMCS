<?php

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/ddns.php';
//Mysql
function dbInit()
{
    $mysql_config = get_db_config();
    $conn = new PDO("mysql:host=" . $mysql_config['mysql_host'] . ";dbname=" . $mysql_config['mysql_dbname'], $mysql_config['mysql_user'], $mysql_config['mysql_pass']);
    return $conn;
}

function create_account($data)
{
    try {
        if (!GetUserBySid($data['sid'])) {
            $conn = dbInit();
            $prefix = get_db_config()['mysql_prefix'];
            $insert = 'INSERT INTO `' . $prefix . 'users` (`sid`,  `email`,`type`,`ip_limit`,`ips`,`speed_limit`,`bandwidth_total`,`created_at`, `updated_at`) VALUES ( :sid, :email, :type,:ip_limit,"[]",:speed_limit,:bandwidth_total,UNIX_TIMESTAMP(), 0)';
            $action = $conn->prepare($insert);
            $action->bindValue(':sid', $data['sid']);
            $action->bindValue(':email', $data['email']);
            $action->bindValue(':ip_limit', $data['ip_limit']);
            $action->bindValue(':speed_limit', $data['speed_limit']);
            $action->bindValue(':bandwidth_total', $data['bandwidth']);
            $action->bindValue(':type', $data['type']);
            // $action->bindValue(':ips', '[]');
            return $action->execute();
        } else {
            return '账户已存在';
        }
    } catch (Exception $e) {
        return $e;
    }
}
function delete_account($sid)
{
    try {
        if (GetUserBySid($sid)) {
            $prefix = get_db_config()['mysql_prefix'];
            $conn = dbInit();
            $action = $conn->prepare('DELETE FROM `' . $prefix . 'users` WHERE `sid` = :sid');
            $action->bindValue(':sid', $sid);
            return $action->execute();
        } else {
            return "账户未找到";
        }
    } catch (Exception $e) {
        return $e;
    }
}

function set_status($data)
{
    try {
        if (GetUserBySid($data['sid'])) {
            $prefix = get_db_config()['mysql_prefix'];
            $conn = dbInit();
            $action = $conn->prepare('UPDATE `' . $prefix . 'users` SET `active` = :enable WHERE `sid` = :sid');
            $action->bindValue(':enable', $data['action']);
            $action->bindValue(':sid', $data['sid']);
            return $action->execute();
        } else {
            return "账户未找到";
        }
    } catch (Exception $e) {
        return $e;
    }
}
function GetUserBySid($sid)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users` WHERE `sid` = :sid';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $sid);
        $action->execute();
        return $action->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetAllUsers()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users`';
        $action = $conn->prepare($insert);
        $action->execute();
        return $action->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function UpdateIpsBySid($sid, $ips)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'UPDATE `' . $prefix . 'users` SET `ips` = :ips, `updated_at` = UNIX_TIMESTAMP() WHERE `sid` = :sid';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $sid);
        $action->bindValue(':ips', json_encode($ips));
        return $action->execute();
    } catch (Exception $e) {
        return $e;
    }
}

function GetDNSListSafe()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT `id`,`aera`,`name`,`info` FROM `' . $prefix . 'nodes`';
        $action = $conn->prepare($insert);
        $action->execute();
        return $action->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetDNSById($node_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'dns` WHERE `id` = :id';
        $action = $conn->prepare($insert);
        $action->bindValue(':id', $node_id);
        $action->execute();
        return $action->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function UpdateAeraBySid($sid, $node_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'UPDATE `' . $prefix . 'users` SET `node` = :node_id, `aera_updated_at` = UNIX_TIMESTAMP() WHERE `sid` = :sid';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $sid);
        $action->bindValue(':node_id', $node_id);
        return $action->execute();
    } catch (Exception $e) {
        return $e;
    }
}

function GetAeraServerNode($server_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'dns` WHERE `server_id` = :server_id';
        $action = $conn->prepare($insert);
        $action->bindValue(':server_id', $server_id);
        $action->execute();
        return $action->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetServerAllUser($server_id)
{
    $node_ids = GetAeraServerNode($server_id);
    $res = [];
    foreach ($node_ids as $id) {
        array_push($res, (int)$id['id']);
    }
    $node_ids = $res;
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users` WHERE `node` IN (' . implode(",", $node_ids) . ') AND `type`=1';
        $action = $conn->prepare($insert);
        $action->execute();
        return $action->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function CollectIpsByServer($server_id)
{
    $users = GetServerAllUser($server_id);
    $ips = [];
    foreach ($users as $user) {
        foreach (json_decode($user['ips']) as $ip) {
            $r_ip = get_ip($ip);
            if ($r_ip != 1 & $r_ip != 2) {
                array_push($ips, $r_ip);
            }
        }
    }
    return $ips;
}

function GetNodeById($node_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'dns` WHERE `id` = :id';
        $action = $conn->prepare($insert);
        $action->bindValue(':id', $node_id);
        $action->execute();
        return $action->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetAllIps()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users`';
        $action = $conn->prepare($insert);
        $action->execute();
        $users =  $action->fetchAll(PDO::FETCH_ASSOC);
        $ips = [];
        foreach ($users as $user) {
            foreach (json_decode($user['ips']) as $ip) {
                $r_ip = get_ip($ip);
                if ($r_ip != 1 & $r_ip != 2) {
                    array_push($ips, $r_ip);
                }
            }
        }
        $ips = array_unique($ips);
        $ips = array_values($ips);
        return $ips;
    } catch (Exception $e) {
        return $e;
    }
}

function GetAllIpsWITHOUTUnique()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users`';
        $action = $conn->prepare($insert);
        $action->execute();
        $users =  $action->fetchAll(PDO::FETCH_ASSOC);
        $ips = [];
        foreach ($users as $user) {
            foreach (json_decode($user['ips']) as $ip) {
                $r_ip = get_ip($ip);
                if ($r_ip != 1 & $r_ip != 2) {
                    array_push($ips, $r_ip);
                }
            }
        }
        return $ips;
    } catch (Exception $e) {
        return $e;
    }
}

function GetAllBackend()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'backends`';
        $action = $conn->prepare($insert);
        $action->execute();
        return $action->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function UpdateUserFlow($user_id, $add_flows)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'UPDATE `' . $prefix . 'users` SET `bandwidth_usage` = bandwidth_usage+:bandwidth_usage WHERE `sid` = :sid';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $user_id);
        $action->bindValue(':bandwidth_usage', $add_flows);
        return $action->execute();
    } catch (Exception $e) {
        return $e;
    }
}

function GetCostomDNSById($node_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'costomnodes` WHERE `id` = :id';
        $action = $conn->prepare($insert);
        $action->bindValue(':id', $node_id);
        $action->execute();
        return $action->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetAllDNS()
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT `id`,`server_id`,`remark`,`doh_url` FROM `' . $prefix . 'dns`';
        $action = $conn->prepare($insert);
        $action->execute();
        $dns = $action->fetchAll(PDO::FETCH_ASSOC);
        $insert = 'SELECT `id`,`remark`,`dns`,`doh` FROM `' . $prefix . 'servers`';
        $action = $conn->prepare($insert);
        $action->execute();
        $servers = $action->fetchAll(PDO::FETCH_ASSOC);
        return array("dns" => $dns, "servers" => $servers);
    } catch (Exception $e) {
        return $e;
    }
}

function GetServerById($server_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'servers` WHERE `id` = :server_id';
        $action = $conn->prepare($insert);
        $action->bindValue(':server_id', $server_id);
        $action->execute();
        return $action->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        return $e;
    }
}

function GetNodeIps($node_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users` WHERE `node` = :node_id AND `type`=1';
        $action = $conn->prepare($insert);
        $action->bindValue(':node_id', $node_id);
        $action->execute();
        $users = $action->fetchAll(PDO::FETCH_ASSOC);
        $ips = [];
        foreach ($users as $user) {
            foreach (json_decode($user['ips']) as $ip) {
                $r_ip = get_ip($ip);
                if ($r_ip != 1 & $r_ip != 2) {
                    array_push($ips, $r_ip);
                }
            }
        }
        return $ips;
    } catch (Exception $e) {
        return $e;
    }
}

function update_user_mirror()
{
    try {
        $redis = new Redis();
        $redis->connect('127.0.0.1', 6379);
        $redis->select(14);
        $redis->flushDB();
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'SELECT * FROM `' . $prefix . 'users`';
        $action = $conn->prepare($insert);
        $action->execute();
        $users =  $action->fetchAll(PDO::FETCH_ASSOC);
        foreach ($users as $user) {
            foreach (json_decode($user['ips']) as $ip) {
                $redis->set($ip, $user['sid']);
                $redis->set(get_ip($ip), $user['sid']);
            }
        }
        return 1;
    } catch (Exception $e) {
        return $e;
    }
}

function get_user_by_ip($ip)
{
    try {
        $redis = new Redis();
        $redis->connect('127.0.0.1', 6379);
        $redis->select(14);
        return $redis->get($ip);
    } catch (Exception $e) {
        return $e;
    }
}

function get_client_products($sid)
{
    $data = array(
        'serviceid' => $sid
    );
    $result = localAPI('GetClientsProducts', $data);
    return $result;
}

function reset_user_traffic($user_id)
{
    try {
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'UPDATE `' . $prefix . 'users` SET `bandwidth_usage` = :bandwidth_usage WHERE `sid` = :sid';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $user_id);
        $action->bindValue(':bandwidth_usage', 0);
        return $action->execute();
    } catch (Exception $e) {
        return $e;
    }
}

function save_traffic_history($user_id)
{
    try {
        $user = GetUserBySid($user_id);
        $conn = dbInit();
        $prefix = get_db_config()['mysql_prefix'];
        $insert = 'INSERT INTO `' . $prefix . 'users_history` (`user`,`traffic`,`month`,`created_at` ) VALUES ( :sid,:traffic,:month, UNIX_TIMESTAMP())';
        $action = $conn->prepare($insert);
        $action->bindValue(':sid', $user_id);
        $action->bindValue(':traffic', $user['bandwidth_usage']);
        $action->bindValue(':month', date("m"));
        return $action->execute();
    } catch (Exception $e) {
        return $e;
    }
}

function reset_traffic_monthly()
{
    $get_orders_data = array(
        'status' => 'Active',
        'limitstart' => 0,
        'limitnum' => 10000
    );
    $result_orders = localAPI('GetOrders', $get_orders_data);
    $get_products_data = array(
        'module' => 'StreamUnblock'
    );
    $result_products = localAPI('GetProducts', $get_products_data);
    if ($result_products['result'] == 'success') {
        $pid_array = array();
        foreach ($result_products['products']['product'] as $data) {
            $pid_array[] = $data['pid'];
        }
    }
    $today = date("d");
    $month = date("m");
    $total_order = $result_orders['totalresults'];
    $return_start_number = $result_orders['startnumber'];
    $num_returned = $result_orders['numreturned'];
    if ($result_orders['result'] == 'success') {
        foreach ($result_orders['orders']['order'] as $data) {
            $sid = $data['lineitems']['lineitem'][0]['relid'];
            $product = get_client_products($sid)['products']['product'][0];
            if ($product['status'] == 'Active' && in_array($product['pid'], $pid_array)) {
                $due_date_origin = $product['nextduedate'];
                $due_date = date("d", strtotime($due_date_origin));
                if ($due_date == $today & !is_null($due_date)) {
                    save_traffic_history($sid);
                    reset_user_traffic($sid);
                }
            }
        }
    }
    return 1;
    // return ($result_orders);
}
