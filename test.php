<?php

require_once __DIR__ . '/sql.php';
require_once __DIR__ . '/backend.php';

// $arr = GetAllIpsWITHOUTUnique();
// $unique_arr = array_unique($arr);
// $repeat_arr = array_diff_assoc($arr, $unique_arr);
// var_dump($repeat_arr);

// var_dump(Updateadgnodedns(GetNodeById($_GET['id'])));

// require_once __DIR__ . '/ddns.php';

// // var_dump(get_ip($_GET['test']));
// // var_dump(get_user_by_ip("test.bugdns.com"));
// var_dump(get_user_by_ip("baidu.com"));

// var_dump(FetchAllTrafic());

var_dump(Updateadgwhitelist(10));
