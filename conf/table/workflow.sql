CREATE TABLE T_OOZIE_APP (
  APP_NAME           VARCHAR(255)  NOT NULL,
  XML_NS    		 VARCHAR(255)          ,
  XML			 	 TEXT                  ,	
  DESCRIPTION        VARCHAR(255)          ,
  CREATOR            VARCHAR(255)          ,
  PRIMARY KEY (APP_NAME)
) DEFAULT CHARSET='utf8' ; 

CREATE TABLE T_OOZIE_JOB (
  JOB_NAME           VARCHAR(255)  NOT NULL,
  APP_NAME           VARCHAR(255)  NOT NULL,
  XML			 	 TEXT                  ,	
  SCHEDULE_INFO      VARCHAR(255)          COMMENT 'crontab notation',
  JOB_PARAMS         TEXT                  COMMENT 'json', 
  DESCRIPTION        VARCHAR(255)          ,
  LAST_JOB_ID        VARCHAR(255)          ,
  LAST_STATUS        VARCHAR( 10)          COMMENT 'last execution status',
  LAST_EXEC_TIME     DATETIME              ,
  PRIMARY KEY (JOB_NAME)
) DEFAULT CHARSET='utf8' ; 
