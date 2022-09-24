<?php

require_once __DIR__ . '/sql.php';
require_once __DIR__ . '/backend.php';
require_once __DIR__ . '/ddns.php';
function StreamUnblock_MetaData()
{
    return array(
        'DisplayName' => 'simpleStreamUnblockBackend',
        'APIVersion' => '1.0',
        'RequiresServer' => true
    );
}


function StreamUnblock_ConfigOptions()
{
    return array(
        "ip限制" => array(
            'Type' => 'text',
            'Size' => '25',
            'Description' => '个'
        ),
        "限速" => array(
            'Type' => 'text',
            'Size' => '25',
            'Description' => 'Mbps'
        ),
        "限流" => array(
            'Type' => 'text',
            'Size' => '25',
            'Description' => 'Bytes'
        ),
        "cidr" => [
            "FriendlyName" => "启用CIDR/通配符IP",
            "Type" => "yesno", # Yes/No Checkbox
            "Description" => "若启用请配置最大子网"
        ],
        "最大子网" => array(
            'Type' => 'text',
            'Size' => '25',
            'Description' => ''
        ),
        "账户类型" => array(
            'Type' => 'text',
            'Size' => '25',
            'Description' => '1=>常规,2=>定制'
        )
    );
}


function StreamUnblock_CreateAccount($params)
{
    // $data = array(
    //     'email' => $params['clientsdetails']['email'],
    //     'uuid' => Uuid::uuid4(),
    //     'token' => $params['password'],
    //     'sid' => $params['serviceid'],
    //     'package_id' => $params['pid'],
    //     'telegram_id' => 0,
    //     'enable' => 1,
    //     'need_reset' => $params['configoption5'],
    //     'node_group_id' => $params['configoption7'],
    //     'bandwidth' => $bandwidth
    // );
    if ($params['configoption1'] == "-1") {
        $ip_limit = $params['configoptions']['ips_count'];
        $bandwidth = $params['configoptions']['ips_count'] * (int)$params['configoption3'];
    } else {
        $ip_limit = $params['configoption1'];
        $bandwidth = $params['configoption3'];
    }
    $data = array(
        'sid' => $params['serviceid'],
        'email' => $params['clientsdetails']['email'],
        'ip_limit' => $ip_limit,
        'speed_limit' => $params['configoption2'],
        'bandwidth' => $bandwidth,
        'type' => $params['configoption6']
    );
    $push = create_account($data);
    // $push=$data;
    return $push;
}

function StreamUnblock_SuspendAccount($params)
{
    $sid = $params['serviceid'];
    $data = array(
        'sid' => $sid,
        'action' => 0,
    );
    $action = set_status($data);
    return $action;
}

function StreamUnblock_UnsuspendAccount($params)
{
    $sid = $params['serviceid'];
    $data = array(
        'sid' => $sid,
        'action' => 1,
    );
    $action = set_status($data);
    return $action;
}

function StreamUnblock_TerminateAccount(array $params)
{
    $action = delete_account($params['serviceid']);
    return $action;
}

function StreamUnblock_AdminServicesTabFields(array $params)
{
    try {
        $user = GetUserBySid($params['serviceid']);
        $node = GetNodeById($user['node']);
        if ($user > 0) {
            $result = array(
                '账户类型' => $params['configoption6'],
                '授权ip数' => $user['ip_limit'],
                'ips' => $user['ips'],
                '节点信息' => $user['node'] . ":" . $node['aera'] . "/" . $node['name'],
                "创建时间" => date('Y-m-d H:i:s', $user['created_at']),
                "流量信息" => convert_byte($user['bandwidth_usage']) . "/" . convert_byte($user['bandwidth_total']),

            );
        } else {
            $result = array(
                '账户类型' => $params['configoption6'],
                '提示' => '<p style="color:red;">账户不存在,请执行开通命令</p>'
            );
        }
        return $result;
    } catch (Exception $e) {
        return $e;
    }
}

function StreamUnblock_ClientArea($params)
{
    $user = GetUserBySid($params['serviceid']);
    if (isset($_GET['ajax'])) {
        switch ($_GET['ajax']) {
            case "update_ips":
                if (count($_POST['ips']) > $user['ip_limit']) {
                    $result = array(
                        "ok" => 0,
                        "status" => "sb",
                        "msg" => "ip数量超出限制"
                    );
                    echo (json_encode($result));
                    die();
                }
                if ((time() - $user['updated_at']) <= 1800) {
                    $result = array(
                        "ok" => 0,
                        "status" => "sb",
                        "msg" => "基于滥用限制,您还需等待" . strval(1800 - (time() - $user['updated_at'])) . "s才能提交"
                    );
                    echo (json_encode($result));
                    die();
                }
                foreach ($_POST['ips'] as $ip) {
                    $msg = ips_pre_test($ip);
                    if ($msg) {
                        $result = array(
                            "ok" => 0,
                            "status" => "sb",
                            "msg" => $msg
                        );
                        echo (json_encode($result));
                        die();
                    }
                }
                $result = array(
                    "ok" => 1,
                    "status" => "ok",
                    "msg" => "ok"
                );
                UpdateIpsBySid($_GET['id'], $_POST['ips']);
                echo (json_encode($result));
                fastcgi_finish_request();
                set_time_limit(0);
                update_user_mirror();
                UpdataAllBackendNginx(json_decode($user['ips']), $_POST['ips'], $user['sid']);
                if ($user['type'] == 1) {
                    Updateadgwhitelist($user['node']);
                    Updateadgnodedns(GetNodeById($user['node']));
                } else {
                    UpdateConstomBackendDNS($user['node'], $_POST['ips']);
                }

                die();
            case "update_aera":
                $result = array(
                    "ok" => 1,
                    "status" => "ok",
                    "msg" => "ok"
                );
                if ($user['node']) {
                    $old_node = GetNodeById($user['node']);
                }
                $new_node = GetNodeById($_POST['node_id']);
                UpdateAeraBySid($_GET['id'], $_POST['node_id']);
                echo json_encode($result);
                fastcgi_finish_request();
                set_time_limit(0);
                if ($old_node['server_id'] == $new_node['server_id']) {
                    if ($user['node']) {
                        Updateadgnodedns($old_node);
                    }
                    Updateadgnodedns($new_node);
                } else {
                    if ($user['node']) {
                        Updateadgwhitelist($old_node['id']);
                        Updateadgnodedns($old_node);
                    }
                    Updateadgwhitelist($new_node['id']);
                    Updateadgnodedns($new_node);
                }
                die();
            case "update_remark":
                $command = 'UpdateClientProduct';
                $postData = array(
                    'serviceid' => $params['serviceid'],
                    'domain' => $_GET['remark'],
                );
                localAPI($command, $postData);
                $result = array(
                    "ok" => 1,
                    "status" => "ok",
                    "msg" => "ok"
                );
                die(json_encode($result));
            case "test":
                var_dump(reset_traffic_monthly());
                die();
            case "testt":
                var_dump(Updateadgnodedns(GetNodeById(10)));
                die();
            default:
                http_response_code(403);
                die();
        };
    }
    // var_dump($user);
    // die();
    // var_dump(json_encode(json_decode($user['ips'])));
    // die();
    return array(
        'templatefile' => $user['type'] == 1 ? 'new.tpl' : 'costomarea.tpl',
        'templateVariables' => array("nodes" => GetAllDNS(), 'user' => $user, "ips" => json_decode($user['ips'])),
        // 'templateVariables' => array('user' => $user, "ips" => json_decode($user['ips']), 'aeras' => GetDNSListSafe(), 'node_info' => $user['type'] == 1 ? GetDNSById($user['node']) : GetCostomDNSById($user['node']), 'traffic' => convert_byte($user['bandwidth_usage'])),
    );
}

function StreamUnblock_ChangePackage($params)
{
    var_dump("mdzz");
}

function convert_byte($size, $digits = 2)
{
    $unit = array('', 'K', 'M', 'G', 'T', 'P');
    $base = 1024;
    $i = floor(log($size, $base));
    $n = count($unit);
    if ($i >= $n) {
        $i = $n - 1;
    }
    return round($size / pow($base, $i), $digits) . ' ' . $unit[$i] . 'B';
}
