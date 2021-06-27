CREATE TABLE `articles` (
  `srno` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created` datetime NOT NULL,
  `ymd` char(8) NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `title` varchar(256) NOT NULL,
  `content` text,
  `category_srno` int(10) unsigned NOT NULL,
  PRIMARY KEY (`srno`),
  KEY `category_srno` (`category_srno`),
  KEY `index_article_ymd` (`ymd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
