CREATE TABLE IDN_BASE_TABLE (
            PRODUCT_NAME LVARCHAR(20),
            PRIMARY KEY (PRODUCT_NAME)
);

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');

CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            ID SERIAL,
            CONSUMER_KEY LVARCHAR(255),
            CONSUMER_SECRET LVARCHAR(512),
            USERNAME LVARCHAR(255),
            TENANT_ID INTEGER DEFAULT 0,
            USER_DOMAIN LVARCHAR(50),
            APP_NAME LVARCHAR(255),
            OAUTH_VERSION LVARCHAR(128),
            CALLBACK_URL LVARCHAR(1024),
            GRANT_TYPES LVARCHAR (1024),
            PKCE_MANDATORY CHAR(1) DEFAULT '0',
            PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',
            APP_STATE LVARCHAR (25) DEFAULT 'ACTIVE',
            UNIQUE (CONSUMER_KEY) CONSTRAINT CONSUMER_KEY_CONSTRAINT,
            PRIMARY KEY (ID)
);

CREATE TABLE IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN LVARCHAR(255),
            REQUEST_TOKEN_SECRET LVARCHAR(512),
            CONSUMER_KEY_ID INTEGER ,
            CALLBACK_URL LVARCHAR(1024),
            SCOPE LVARCHAR(2048),
            AUTHORIZED LVARCHAR(128),
            OAUTH_VERIFIER LVARCHAR(512),
            AUTHZ_USER LVARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);


CREATE TABLE IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN LVARCHAR(255),
            ACCESS_TOKEN_SECRET LVARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            SCOPE LVARCHAR(2048),
            AUTHZ_USER LVARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN (
            TOKEN_ID LVARCHAR (255),
            ACCESS_TOKEN LVARCHAR(255),
            REFRESH_TOKEN LVARCHAR(255),
            CONSUMER_KEY_ID INTEGER,
            AUTHZ_USER LVARCHAR(100),
            TENANT_ID INTEGER,
            USER_DOMAIN LVARCHAR(50),
            USER_TYPE LVARCHAR (25),
            GRANT_TYPE LVARCHAR (50),
            TIME_CREATED DATETIME YEAR TO SECOND,
            REFRESH_TOKEN_TIME_CREATED DATETIME YEAR TO SECOND,
            VALIDITY_PERIOD BIGINT,
            REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
            TOKEN_SCOPE_HASH LVARCHAR(32),
            TOKEN_STATE LVARCHAR(25) DEFAULT 'ACTIVE',
            TOKEN_STATE_ID LVARCHAR (128) DEFAULT 'NONE',
            SUBJECT_IDENTIFIER LVARCHAR(255),
            PRIMARY KEY (TOKEN_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
            UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TOKEN_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,TOKEN_STATE,
            TOKEN_STATE_ID) CONSTRAINT CON_APP_KEY
);

CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);

CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);

CREATE TABLE IDN_OAUTH2_AUTHORIZATION_CODE (
            CODE_ID LVARCHAR (255),
            AUTHORIZATION_CODE LVARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
	          CALLBACK_URL LVARCHAR(1024),
            SCOPE LVARCHAR(2048),
            AUTHZ_USER LVARCHAR(100),
            TENANT_ID INTEGER,
            USER_DOMAIN LVARCHAR(50),
	          TIME_CREATED DATETIME YEAR TO SECOND,
	          VALIDITY_PERIOD BIGINT,
	          STATE LVARCHAR (25) DEFAULT 'ACTIVE',
            TOKEN_ID LVARCHAR(255),
            SUBJECT_IDENTIFIER LVARCHAR(255),
            PKCE_CODE_CHALLENGE LVARCHAR (255),
            PKCE_CODE_CHALLENGE_METHOD LVARCHAR(128),
            PRIMARY KEY (CODE_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
            TOKEN_ID LVARCHAR (255),
            TOKEN_SCOPE LVARCHAR (60),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
            FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE
);

CREATE TABLE IDN_OAUTH2_SCOPE (
            SCOPE_ID SERIAL,
            SCOPE_KEY LVARCHAR(100) NOT NULL,
            NAME LVARCHAR(255),
            DESCRIPTION LVARCHAR(512),
            TENANT_ID INTEGER NOT NULL,
            ROLES LVARCHAR (500),
            PRIMARY KEY (SCOPE_ID)
);

CREATE TABLE IDN_OAUTH2_RESOURCE_SCOPE (
            RESOURCE_PATH LVARCHAR(255) NOT NULL,
            SCOPE_ID INTEGER NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (RESOURCE_PATH),
            FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE
);

CREATE TABLE IDN_SCIM_GROUP (
			ID SERIAL UNIQUE,
			TENANT_ID INTEGER NOT NULL,
			ROLE_NAME LVARCHAR(255) NOT NULL,
            ATTR_NAME LVARCHAR(1024) NOT NULL,
			ATTR_VALUE LVARCHAR(1024)
);

CREATE TABLE IDN_OPENID_REMEMBER_ME (
            USER_NAME LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT 0,
            COOKIE_VALUE LVARCHAR(1024),
            CREATED_TIME DATETIME YEAR TO SECOND,
            PRIMARY KEY (USER_NAME, TENANT_ID)
);

CREATE TABLE IDN_OPENID_USER_RPS (
			USER_NAME LVARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL LVARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS LVARCHAR(128) DEFAULT 'f',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME LVARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
);

CREATE TABLE IDN_OPENID_ASSOCIATIONS (
			HANDLE LVARCHAR(255) NOT NULL,
			ASSOC_TYPE LVARCHAR(255) NOT NULL,
			EXPIRE_IN DATETIME YEAR TO SECOND NOT NULL,
			MAC_KEY LVARCHAR(255) NOT NULL,
			ASSOC_STORE LVARCHAR(128) DEFAULT 'SHARED',
			TENANT_ID INTEGER DEFAULT -1,
			PRIMARY KEY (HANDLE)
);

CREATE TABLE IDN_STS_STORE (
             ID SERIAL UNIQUE,
             TOKEN_ID LVARCHAR(255) NOT NULL,
             TOKEN_CONTENT BLOB(1024) NOT NULL,
             CREATE_DATE DATETIME YEAR TO SECOND NOT NULL,
             EXPIRE_DATE DATETIME YEAR TO SECOND NOT NULL,
             STATE INTEGER DEFAULT 0
);

CREATE TABLE IDN_IDENTITY_USER_DATA (
             TENANT_ID INTEGER DEFAULT -1234,
             USER_NAME LVARCHAR(255) NOT NULL,
             DATA_KEY LVARCHAR(255) NOT NULL,
             DATA_VALUE LVARCHAR(255),
             PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)
);

CREATE TABLE IDN_IDENTITY_META_DATA (
            USER_NAME LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
            METADATA_TYPE LVARCHAR(255) NOT NULL,
            METADATA LVARCHAR(255) NOT NULL,
            VALID LVARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
);

CREATE TABLE IDN_THRIFT_SESSION (
            SESSION_ID LVARCHAR(255) NOT NULL,
            USER_NAME LVARCHAR(255) NOT NULL,
            CREATED_TIME LVARCHAR(255) NOT NULL,
            LAST_MODIFIED_TIME LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (SESSION_ID)
);

CREATE TABLE IDN_AUTH_SESSION_STORE (
            SESSION_ID LVARCHAR (100) NOT NULL,
            SESSION_TYPE LVARCHAR(100) NOT NULL,
            OPERATION VARCHAR(10) NOT NULL,
            SESSION_OBJECT BLOB,
            TIME_CREATED BIGINT,
            TENANT_ID INTEGER DEFAULT -1
            PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
);

CREATE TABLE SP_APP (
            ID SERIAL,
            TENANT_ID INTEGER NOT NULL,
	    	APP_NAME LVARCHAR (255) NOT NULL ,
	    	USER_STORE LVARCHAR (255) NOT NULL,
            USERNAME LVARCHAR (255) NOT NULL ,
            DESCRIPTION LVARCHAR (1024),
	    	ROLE_CLAIM LVARCHAR (512),
            AUTH_TYPE LVARCHAR (255) NOT NULL,
	    	PROVISIONING_USERSTORE_DOMAIN LVARCHAR (512),
	    	IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
	    	IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
	    	IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
        IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
        IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
	    	SUBJECT_CLAIM_URI LVARCHAR (512),
	    	IS_SAAS_APP CHAR(1) DEFAULT '0',
	    	IS_DUMB_MODE CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_APP ADD CONSTRAINT UNIQUE(APP_NAME, TENANT_ID) CONSTRAINT APPLICATION_NAME_CONSTRAINT;

CREATE TABLE SP_METADATA (
            ID SERIAL,
            SP_ID INTEGER,
            NAME LVARCHAR(255) NOT NULL,
            VALUE LVARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            UNIQUE (SP_ID, NAME) CONSTRAINT SP_METADATA_CONSTRAINT,
            FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE);

CREATE TABLE SP_INBOUND_AUTH (
            ID SERIAL,
            TENANT_ID INTEGER NOT NULL,
            INBOUND_AUTH_KEY LVARCHAR (255),
            INBOUND_AUTH_TYPE LVARCHAR (255) NOT NULL,
            PROP_NAME LVARCHAR (255),
            PROP_VALUE LVARCHAR (1024) ,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT APPLICATION_ID_CONSTRAINT;

CREATE TABLE SP_AUTH_STEP (
            ID SERIAL,
            TENANT_ID INTEGER NOT NULL,
	     	STEP_ORDER INTEGER DEFAULT 1,
            APP_ID INTEGER NOT NULL,
            IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
            IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP;

CREATE TABLE SP_FEDERATED_IDP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_ID INTEGER NOT NULL,
            PRIMARY KEY (ID, AUTHENTICATOR_ID));

ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE CONSTRAINT STEP_ID_CONSTRAINT;

CREATE TABLE SP_CLAIM_MAPPING (
	    	ID SERIAL,
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_CLAIM LVARCHAR (512) NOT NULL ,
            SP_CLAIM LVARCHAR (512) NOT NULL ,
	   		APP_ID INTEGER NOT NULL,
	    	IS_REQUESTED LVARCHAR(128) DEFAULT '0',
			DEFAULT_VALUE LVARCHAR(255),
            PRIMARY KEY (ID));

ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT CLAIMID_APPID_CONSTRAINT;

CREATE TABLE SP_ROLE_MAPPING (
	    	ID SERIAL,
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_ROLE LVARCHAR (255) NOT NULL ,
            SP_ROLE LVARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT ROLEID_APPID_CONSTRAINT;

CREATE TABLE SP_REQ_PATH_AUTHENTICATOR (
	    	ID SERIAL,
	    	TENANT_ID INTEGER NOT NULL,
	    	AUTHENTICATOR_NAME LVARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT REQ_AUTH_APPID_CONSTRAINT ;

CREATE TABLE SP_PROVISIONING_CONNECTOR (
	    	ID SERIAL,
	    	TENANT_ID INTEGER NOT NULL,
            IDP_NAME LVARCHAR (255) NOT NULL ,
	    	CONNECTOR_NAME LVARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	IS_JIT_ENABLED CHAR(1) DEFAULT '0',
		    BLOCKING CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT;

CREATE TABLE IDP (
			ID SERIAL,
			TENANT_ID INTEGER,
			NAME LVARCHAR(254) NOT NULL,
			IS_ENABLED CHAR(1) DEFAULT '1',
			IS_PRIMARY CHAR(1) DEFAULT '0',
			HOME_REALM_ID LVARCHAR(254),
			IMAGE BLOB,
			CERTIFICATE BLOB,
			ALIAS LVARCHAR(254),
			INBOUND_PROV_ENABLED CHAR (1) DEFAULT '0',
			INBOUND_PROV_USER_STORE_ID LVARCHAR(254),
 			USER_CLAIM_URI LVARCHAR(254),
 			ROLE_CLAIM_URI LVARCHAR(254),
			DESCRIPTION LVARCHAR (1024),
 			DEFAULT_AUTHENTICATOR_NAME LVARCHAR(254),
 			DEFAULT_PRO_CONNECTOR_NAME LVARCHAR(254),
			PROVISIONING_ROLE VARCHAR(128),
			IS_FEDERATION_HUB CHAR(1) DEFAULT '0',
			IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '0',
                  DISPLAY_NAME VARCHAR(255),			
			PRIMARY KEY (ID),
	        UNIQUE (TENANT_ID, NAME));

CREATE TABLE IDP_ROLE (
			ID SERIAL,
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			ROLE LVARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, ROLE),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDP_ROLE_MAPPING (
			ID SERIAL,
			IDP_ROLE_ID INTEGER,
			TENANT_ID INTEGER,
			USER_STORE_ID LVARCHAR (253),
			LOCAL_ROLE LVARCHAR(253),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE);

CREATE TABLE IDP_CLAIM (
			ID SERIAL,
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			CLAIM LVARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, CLAIM),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDP_CLAIM_MAPPING (
			ID SERIAL,
			IDP_CLAIM_ID INTEGER,
			TENANT_ID INTEGER,
			LOCAL_CLAIM LVARCHAR(253),
			DEFAULT_VALUE VARCHAR(255),
	    	IS_REQUESTED LVARCHAR(128) DEFAULT '0',
			PRIMARY KEY (ID),
			UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
			FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE);

CREATE TABLE IDP_AUTHENTICATOR (
            ID SERIAL,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            NAME LVARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '1',
            DISPLAY_NAME VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDP_METADATA (
            ID SERIAL,
            IDP_ID INTEGER,
            NAME LVARCHAR(255) NOT NULL,
            VALUE LVARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            UNIQUE (IDP_ID, NAME) CONSTRAINT IDP_METADATA_CONSTRAINT,
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDP_AUTHENTICATOR_PROPERTY (
            ID SERIAL,
            TENANT_ID INTEGER,
            AUTHENTICATOR_ID INTEGER,
            PROPERTY_KEY LVARCHAR(255) NOT NULL,
            PROPERTY_VALUE LVARCHAR(2047),
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
            FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE);

CREATE TABLE IDP_PROVISIONING_CONFIG (
            ID SERIAL,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            PROVISIONING_CONNECTOR_TYPE LVARCHAR(255) NOT NULL,
			IS_ENABLED CHAR (1) DEFAULT '0',
			IS_BLOCKING CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDP_PROV_CONFIG_PROPERTY (
            ID SERIAL,
            TENANT_ID INTEGER,
            PROVISIONING_CONFIG_ID INTEGER,
            PROPERTY_KEY LVARCHAR(255) NOT NULL,
            PROPERTY_VALUE LVARCHAR(2048),
            PROPERTY_BLOB_VALUE BLOB,
            PROPERTY_TYPE CHAR(32) NOT NULL,
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

CREATE TABLE IDP_PROVISIONING_ENTITY (
            ID SERIAL,
            PROVISIONING_CONFIG_ID INTEGER,
            ENTITY_TYPE LVARCHAR(255) NOT NULL,
            ENTITY_LOCAL_USERSTORE LVARCHAR(255) NOT NULL,
            ENTITY_NAME LVARCHAR(255) NOT NULL,
            ENTITY_VALUE LVARCHAR(255),
            TENANT_ID INTEGER,
            ENTITY_LOCAL_ID VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
            UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

CREATE TABLE IDP_LOCAL_CLAIM (
            ID SERIAL,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            CLAIM_URI LVARCHAR(255) NOT NULL,
            DEFAULT_VALUE LVARCHAR(255),
       	    IS_REQUESTED LVARCHAR(128) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

CREATE TABLE IDN_ASSOCIATED_ID (
            ID SERIAL,
	    IDP_USER_ID VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
	    IDP_ID INTEGER NOT NULL,
            DOMAIN_NAME LVARCHAR(255) NOT NULL,
 	    USER_NAME VARCHAR(255) NOT NULL,
	    PRIMARY KEY (ID),
            UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
);

CREATE TABLE IDN_USER_ACCOUNT_ASSOCIATION (
            ASSOCIATION_KEY LVARCHAR(255) NOT NULL,
            TENANT_ID INTEGER,
            DOMAIN_NAME LVARCHAR(255) NOT NULL,
            USER_NAME LVARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME));

CREATE TABLE FIDO_DEVICE_STORE (
        TENANT_ID INTEGER,
        DOMAIN_NAME LVARCHAR(255) NOT NULL,
        USER_NAME LVARCHAR(45) NOT NULL,
	    TIME_REGISTERED DATETIME YEAR TO FRACTION(5),
        KEY_HANDLE LVARCHAR(200) NOT NULL,
        DEVICE_DATA LVARCHAR(2048) NOT NULL,
      PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE));
      
CREATE TABLE WF_REQUEST (
    UUID LVARCHAR (45),
    CREATED_BY LVARCHAR (255),
    TENANT_ID INTEGER DEFAULT -1,
    OPERATION_TYPE LVARCHAR (50),
    CREATED_AT DATETIME YEAR TO SECOND,
    UPDATED_AT DATETIME YEAR TO SECOND,
    STATUS LVARCHAR (30),
    REQUEST BLOB,
    PRIMARY KEY (UUID)
);

CREATE TABLE WF_BPS_PROFILE (
    PROFILE_NAME LVARCHAR(45),
    HOST_URL_MANAGER LVARCHAR(255),
    HOST_URL_WORKER LVARCHAR(255),
    USERNAME LVARCHAR(45),
    PASSWORD LVARCHAR(255),
    CALLBACK_HOST LVARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (PROFILE_NAME,TENANT_ID)
);

CREATE TABLE WF_WORKFLOW(
    ID LVARCHAR (45),
    WF_NAME LVARCHAR (45),
    DESCRIPTION LVARCHAR (255),
    TEMPLATE_ID LVARCHAR (45),
    IMPL_ID LVARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID)
);

CREATE TABLE WF_WORKFLOW_ASSOCIATION(
    ID SERIAL,
    ASSOC_NAME LVARCHAR (45),
    EVENT_ID LVARCHAR(45),
    ASSOC_CONDITION LVARCHAR (2000),
    WORKFLOW_ID LVARCHAR (45),
    IS_ENABLED CHAR (1) DEFAULT '1',
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID) ON DELETE CASCADE
);

CREATE TABLE WF_WORKFLOW_CONFIG_PARAM(
    WORKFLOW_ID LVARCHAR (45),
    PARAM_NAME LVARCHAR (45),
    PARAM_VALUE LVARCHAR (1000),
    PARAM_QNAME LVARCHAR (45),
    PARAM_HOLDER LVARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID) ON DELETE CASCADE
);

CREATE TABLE WF_REQUEST_ENTITY_RELATIONSHIP(
  REQUEST_ID LVARCHAR (45),
  ENTITY_NAME LVARCHAR (255),
  ENTITY_TYPE VARCHAR (50),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID) ON DELETE CASCADE
);

CREATE TABLE WF_WORKFLOW_REQUEST_RELATION(
  RELATIONSHIP_ID VARCHAR (45),
  WORKFLOW_ID LVARCHAR (45),
  REQUEST_ID LVARCHAR (45),
  UPDATED_AT DATETIME YEAR TO SECOND,
  STATUS VARCHAR (30),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY (RELATIONSHIP_ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
);

CREATE TABLE IDN_RECOVERY_DATA (
  USER_NAME LVARCHAR(255) NOT NULL,
  USER_DOMAIN LVARCHAR(255) NOT NULL,
  TENANT_ID INTEGER DEFAULT -1,
  CODE LVARCHAR(255) NOT NULL,
  SCENARIO LVARCHAR(255) NOT NULL,
  STEP LVARCHAR(255) NOT NULL,
  TIME_CREATED DATETIME NOT NULL,
  REMAINING_SETS LVARCHAR(2500) DEFAULT NULL,
  PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),
  UNIQUE(CODE)
);

CREATE TABLE IDN_PASSWORD_HISTORY_DATA (
  ID SERIAL,
  USER_NAME   LVARCHAR(255) NOT NULL,
  USER_DOMAIN LVARCHAR(255) NOT NULL,
  TENANT_ID   INTEGER DEFAULT -1,
  SALT_VALUE  LVARCHAR(255),
  HASH        LVARCHAR(255) NOT NULL,
  TIME_CREATED DATETIME YEAR TO SECOND NOT NULL,
  PRIMARY KEY (ID),
  UNIQUE(USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH),
  );

CREATE TABLE IDN_CLAIM_DIALECT (
  ID SERIAL,
  DIALECT_URI LVARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  UNIQUE (DIALECT_URI, TENANT_ID) CONSTRAINT DIALECT_URI_CONSTRAINT
);

CREATE TABLE IDN_CLAIM (
  ID SERIAL,
  DIALECT_ID INTEGER,
  CLAIM_URI LVARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,
  UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID) CONSTRAINT CLAIM_URI_CONSTRAINT
);

CREATE TABLE IDN_CLAIM_MAPPED_ATTRIBUTE (
  ID SERIAL,
  LOCAL_CLAIM_ID INTEGER,
  USER_STORE_DOMAIN_NAME LVARCHAR (255) NOT NULL,
  ATTRIBUTE_NAME LVARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID) CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT
);

CREATE TABLE IDN_CLAIM_PROPERTY (
  ID SERIAL,
  LOCAL_CLAIM_ID INTEGER,
  PROPERTY_NAME LVARCHAR (255) NOT NULL,
  PROPERTY_VALUE LVARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID) CONSTRAINT PROPERTY_NAME_CONSTRAINT
);

CREATE TABLE IDN_CLAIM_MAPPING (
  ID SERIAL,
  EXT_CLAIM_ID INTEGER NOT NULL,
  MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  UNIQUE (EXT_CLAIM_ID, TENANT_ID) CONSTRAINT EXT_TO_LOCAL_UNIQUE_MAPPING_CONSTRAINT
);
