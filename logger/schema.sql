CREATE TABLE chat (
  id int(11) NOT NULL auto_increment,
  channel varchar(255) NOT NULL,
  stamp timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  utterance text,
  who varchar(32) default NULL,
  PRIMARY KEY  (id),
  KEY chat_stamp (stamp),
  KEY chat_who (who),
  FULLTEXT KEY chat_utterance (utterance)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

