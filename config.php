<?php

function get_db_config()
{
    return array(
        'mysql_host' => '127.0.0.1',
        'mysql_pass' => 'ycNbHeK54apysjkf',
        'mysql_user' => 'sql_streamunblock',
        'mysql_prefix' => 'su_',
        'mysql_dbname' => 'sql_streamunblock'
    );
}

function get_sstoken()
{
    return "ZyELkjEXREqaBsNZXp4NfHarJa9Rt3bZ";
}

function get_redis_config()
{
    return array(
        'redis_pass' => '',
        'redis_host' => '127.0.0.1',
        'redis_port' => '6379'
    );
}
