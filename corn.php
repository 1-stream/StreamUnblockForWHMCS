<?php

require_once __DIR__ . '/backend.php';

$redis = new Redis();
$redis->connect('127.0.0.1', 6379);
$redis->select(15);
$redis->flushDB();
DailyTrafficFetch();
update_user_mirror();
echo "Done\n";
