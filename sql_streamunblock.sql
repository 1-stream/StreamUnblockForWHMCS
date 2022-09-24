-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2022-09-24 20:16:57
-- 服务器版本： 8.0.24
-- PHP 版本： 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `sql_streamunblock`
--

-- --------------------------------------------------------

--
-- 表的结构 `su_backends`
--

CREATE TABLE `su_backends` (
  `id` int NOT NULL COMMENT '主键id',
  `ip` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `active` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_costomnodes`
--

CREATE TABLE `su_costomnodes` (
  `id` int NOT NULL,
  `backend` text COLLATE utf8mb4_general_ci NOT NULL,
  `auth` text COLLATE utf8mb4_general_ci NOT NULL,
  `dns` text COLLATE utf8mb4_general_ci NOT NULL,
  `dnsv6` text COLLATE utf8mb4_general_ci NOT NULL,
  `doh` text COLLATE utf8mb4_general_ci NOT NULL,
  `dot` text COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_dns`
--

CREATE TABLE `su_dns` (
  `id` int NOT NULL,
  `server_id` int NOT NULL,
  `doh_url` text COLLATE utf8mb4_general_ci NOT NULL,
  `post_body` text COLLATE utf8mb4_general_ci NOT NULL,
  `remark` text COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_logs`
--

CREATE TABLE `su_logs` (
  `id` int NOT NULL,
  `uid` int NOT NULL,
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `time` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_nodes`
--

CREATE TABLE `su_nodes` (
  `id` int NOT NULL COMMENT '主键id',
  `aera` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '地区',
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称',
  `info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '注释',
  `backend` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '后端地址',
  `server_id` int NOT NULL,
  `auth` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '后端认证',
  `dns` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'dns53地址',
  `dnsv6` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'dnsv6',
  `doh` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'doh地址',
  `dot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'dot地址',
  `ss` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ss地址',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_servers`
--

CREATE TABLE `su_servers` (
  `id` int NOT NULL,
  `remark` text COLLATE utf8mb4_general_ci NOT NULL,
  `url` text COLLATE utf8mb4_general_ci NOT NULL,
  `auth` text COLLATE utf8mb4_general_ci NOT NULL,
  `dns` text COLLATE utf8mb4_general_ci NOT NULL,
  `doh` text COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_users`
--

CREATE TABLE `su_users` (
  `id` int NOT NULL COMMENT '主键id',
  `sid` int NOT NULL COMMENT 'whmcs服务id',
  `type` int NOT NULL DEFAULT '1',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '可用',
  `email` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户邮箱',
  `node` int NOT NULL DEFAULT '0',
  `speed_limit` int NOT NULL COMMENT '限速',
  `ip_limit` int NOT NULL COMMENT 'ip限制',
  `ips` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '绑定ips',
  `max_subnet` int NOT NULL DEFAULT '0' COMMENT '最大子网',
  `bandwidth_total` bigint NOT NULL COMMENT '总流量',
  `bandwidth_usage` bigint NOT NULL DEFAULT '0',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL DEFAULT '0',
  `aera_updated_at` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `su_users_history`
--

CREATE TABLE `su_users_history` (
  `id` int NOT NULL,
  `user` int NOT NULL,
  `traffic` bigint NOT NULL,
  `month` int NOT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 转储表的索引
--

--
-- 表的索引 `su_backends`
--
ALTER TABLE `su_backends`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_costomnodes`
--
ALTER TABLE `su_costomnodes`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_dns`
--
ALTER TABLE `su_dns`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_logs`
--
ALTER TABLE `su_logs`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_nodes`
--
ALTER TABLE `su_nodes`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_servers`
--
ALTER TABLE `su_servers`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_users`
--
ALTER TABLE `su_users`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `su_users_history`
--
ALTER TABLE `su_users_history`
  ADD PRIMARY KEY (`id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `su_backends`
--
ALTER TABLE `su_backends`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键id';

--
-- 使用表AUTO_INCREMENT `su_costomnodes`
--
ALTER TABLE `su_costomnodes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `su_dns`
--
ALTER TABLE `su_dns`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `su_logs`
--
ALTER TABLE `su_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `su_nodes`
--
ALTER TABLE `su_nodes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键id';

--
-- 使用表AUTO_INCREMENT `su_servers`
--
ALTER TABLE `su_servers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `su_users`
--
ALTER TABLE `su_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键id';

--
-- 使用表AUTO_INCREMENT `su_users_history`
--
ALTER TABLE `su_users_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
