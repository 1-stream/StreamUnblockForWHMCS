<?php

use WHMCS\Database\Capsule;
use Carbon\Carbon;


add_hook('DailyCronJob', 1, function ($vars) {
    require_once __DIR__ . '/sql.php';
    try {
        reset_traffic_monthly();
    } catch (Exception $e) {
        file_put_contents('after_cron_log.txt', var_export($e, true), FILE_APPEND);
    }
});
