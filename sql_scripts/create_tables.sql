CREATE TABLE IF NOT EXISTS users(id          INTEGER NOT NULL AUTO_INCREMENT,
                                 accountType INTEGER,
                                 email       VARCHAR(100) NOT NULL,
                                 password    VARCHAR(100) NOT NULL,
                                 name        VARCHAR(100) NOT NULL,
                                 usrImgURL   VARCHAR(200) NOT NULL,
                                 gender      CHAR(7) NOT NULL,
                                 dob         DATE,
                                 lat         DECIMAL(17,14) NOT NULL,
                                 lng         DECIMAL(17,14) NOT NULL,
                                 latlang     POINT NOT NULL,
                                 countryCode CHAR(3),
                                 stateCode   INTEGER,
                                 countyCode  INTEGER,
                                 cityCode    INTEGER,
                                 PRIMARY KEY(id),
                                 SPATIAL INDEX(latlang)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS facebook(facebook_id VARCHAR(100),
                                    email       VARCHAR(100),
                                    firstname   VARCHAR(50),
                                    lastname    VARCHAR(50),
                                    profileURL  VARCHAR(200),
                                    usrImgURL   VARCHAR(200),
                                    gender      CHAR(6),
                                    hometown    VARCHAR(50),
                                    location    VARCHAR(100),
                                    dob         DATE,
                                    PRIMARY KEY(facebook_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS google(google_id      VARCHAR(100),
                                  PRIMARY KEY(google_id),
                                  google_details VARCHAR(100)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS twitter(twitter_id   VARCHAR(100),
                                   username     VARCHAR(100),
                                   name         VARCHAR(100),
                                   usrImgURL    VARCHAR(200),
                                   location     VARCHAR(100),
                                   PRIMARY KEY(twitter_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS linkedin(linkedin_id      VARCHAR(100),
                                    PRIMARY KEY(linkedin_id),
                                    linkedin_details VARCHAR(100)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS facebook_accounts(facebook_id     VARCHAR(100),
                                             id              INTEGER,
                                             date_registered DATE,
                                             PRIMARY KEY(id, facebook_id),
                                             FOREIGN KEY(id) REFERENCES users(id),
                                             FOREIGN KEY(facebook_id) REFERENCES facebook(facebook_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS google_accounts(google_id       VARCHAR(100),
                                           id              INTEGER,
                                           date_registered DATE,
                                           PRIMARY KEY(google_id, id, date_registered),
                                           FOREIGN KEY(id) REFERENCES users(id),
                                           FOREIGN KEY(google_id) REFERENCES google(google_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS linkedin_accounts(linkedin_id     VARCHAR(100),
                                             id              INTEGER,
                                             date_registered DATE,
                                             PRIMARY KEY(linkedin_id, id),
                                             FOREIGN KEY(id) REFERENCES users(id),
                                             FOREIGN KEY(linkedin_id) REFERENCES linkedin(linkedin_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS twitter_accounts(twitter_id      VARCHAR(100),
                                            id              INTEGER,
                                            date_registered DATE,
                                            PRIMARY KEY(twitter_id, id),
                                            FOREIGN KEY(id) REFERENCES users(id),
                                            FOREIGN KEY(twitter_id) REFERENCES twitter(twitter_id)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS invitation(email     VARCHAR(100),
                                      invite_id VARCHAR(100),
                                      active    TINYINT(1),
                                      PRIMARY KEY(email)) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS polls(id          INTEGER NOT NULL AUTO_INCREMENT,
                                 user_id     INTEGER,
                                 question    VARCHAR(140),
                                 dt          DATETIME NOT NULL,
                                 PRIMARY KEY(id),
                                 FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS options(id          INTEGER NOT NULL AUTO_INCREMENT,
                                   poll_id     INTEGER,
                                   optionstr   VARCHAR(30),
                                   color       VARCHAR(7),
                                   PRIMARY KEY(id),
                                   FOREIGN KEY(poll_id) REFERENCES polls(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS pollanswers(poll_id     INTEGER,
                                       user_id     INTEGER,
                                       option_id   INTEGER NOT NULL,
                                       dt          DATETIME NOT NULL,
                                       PRIMARY KEY(poll_id, user_id),
                                       FOREIGN KEY(option_id) REFERENCES options(id) ON UPDATE CASCADE ON DELETE CASCADE,
                                       FOREIGN KEY(poll_id) REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE,
                                       FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS opinions(id          INTEGER NOT NULL AUTO_INCREMENT,
                                    poll_id     INTEGER,
                                    user_id     INTEGER,
                                    opinion     VARCHAR(1000),
                                    dt          DATETIME NOT NULL,
                                    PRIMARY KEY(id),
                                    FOREIGN KEY(poll_id) REFERENCES polls(id) ON UPDATE CASCADE ON DELETE CASCADE,
                                    FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS comments(id             INTEGER NOT NULL AUTO_INCREMENT,
                                    opinion_id     INTEGER NOT NULL,
                                    user_id        INTEGER NOT NULL,
                                    comment_text   VARCHAR(1000) NOT NULL,
                                    dt             DATETIME NOT NULL,
                                    PRIMARY KEY(id),
                                    FOREIGN KEY(opinion_id) REFERENCES opinions(id) ON UPDATE CASCADE ON DELETE CASCADE,
                                    FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS opinionlikes(opinion_id     INTEGER NOT NULL,
                                        user_id        INTEGER NOT NULL,
                                        PRIMARY KEY(opinion_id, user_id),
                                        FOREIGN KEY(opinion_id) REFERENCES opinions(id) ON UPDATE CASCADE ON DELETE CASCADE,
                                        FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS opinionstats(opinion_id     INTEGER NOT NULL,
                                        comment_cnt    INTEGER,
                                        like_cnt       INTEGER,
                                        PRIMARY KEY(opinion_id),
                                        FOREIGN KEY(opinion_id) REFERENCES opinions(id) ON UPDATE CASCADE ON DELETE CASCADE) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS cmdlog(log VARCHAR(500));
