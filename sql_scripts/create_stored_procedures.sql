DELIMITER //
DROP PROCEDURE IF EXISTS AddUser;
CREATE PROCEDURE AddUser ( IN email       VARCHAR(100),
                           IN password    VARCHAR(100),
                           IN name        VARCHAR(100),
                           IN usrImgURL   VARCHAR(200),
                           IN gender      CHAR(6),
                           IN dob         DATE,
                           IN lat         DECIMAL(17,14),
                           IN lng         DECIMAL(17,14)
                         )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create local user entry in database'
BEGIN

DECLARE user_id INTEGER DEFAULT 0;

CREATE TEMPORARY TABLE geoLocation (country_name VARCHAR(30), country_code CHAR(3), state_name VARCHAR(50), state_code INTEGER, county_name VARCHAR(70), county_code INTEGER, city_name VARCHAR(70), city_code INTEGER);

SELECT users.id FROM users WHERE users.email = email INTO user_id;
IF NOT user_id>0 THEN

  SET @countryCode = NULL;
  SET @stateCode = NULL;
  SET @countyCode = NULL;
  SET @cityCode = NULL;
  SET @tableName = NULL;

  SELECT ADM0_A3 INTO @countryCode
  FROM world
  WHERE ST_CONTAINS(SHAPE, POINT(lng, lat));

  IF (NOT @countryCode IS NULL)  THEN

    SELECT TABLE_NAME INTO @tableName
    FROM information_schema.tables
    WHERE table_schema = 'opinions'
    AND table_name = LOWER(@countryCode);

    IF (NOT @tableName IS NULL) THEN

      SET @cityQuery = ' ';
      SET @countyQuery = ' ';
      SET @stateQuery = ' ';

      SELECT column_name INTO @cityQuery
      FROM information_schema.COLUMNS
      WHERE
          TABLE_SCHEMA = 'opinions'
      AND TABLE_NAME = LOWER(@countryCode)
      AND COLUMN_NAME = 'city_name';

      IF (NOT @cityQuery = ' ') THEN
        SET @cityQuery = ', city_name, city_code';
      END IF;


      SELECT column_name INTO @countyQuery
      FROM information_schema.COLUMNS
      WHERE
          TABLE_SCHEMA = 'opinions'
      AND TABLE_NAME = LOWER(@countryCode)
      AND COLUMN_NAME = 'county_name';

      IF (NOT @countyQuery = ' ') THEN
        SET @countyQuery = ', county_name, county_code';
      END IF;


      SELECT column_name INTO @stateQuery
      FROM information_schema.COLUMNS
      WHERE
          TABLE_SCHEMA = 'opinions'
      AND TABLE_NAME = LOWER(@countryCode)
      AND COLUMN_NAME = 'state_name';

      IF (NOT @stateQuery = ' ')  THEN
        SET @stateQuery = ', state_name, state_code';
      END IF;


      SET @sqlstmt = CONCAT('INSERT INTO geoLocation (country_name, country_code', @stateQuery, @countyQuery, @cityQuery,') SELECT country_name, country_code', @stateQuery, @countyQuery, @cityQuery,
                            ' FROM ', LOWER(@countryCode),
                            ' WHERE ST_CONTAINS(SHAPE, POINT(', lng, ',', lat, '))');

      INSERT INTO cmdlog(log) VALUES (@sqlstmt);

      PREPARE stmt from @sqlstmt;
      EXECUTE stmt;

      SELECT state_code   INTO @stateCode   FROM geoLocation;
      SELECT county_code  INTO @countyCode  FROM geoLocation;
      SELECT city_code    INTO @cityCode    FROM geoLocation;

    END IF;

    INSERT INTO users (accountType,
                       email,
                       password,
                       name,
                       usrImgURL,
                       gender,
                       dob,
                       lat,
                       lng,
                       latlang,
                       countryCode,
                       stateCode,
                       countyCode,
                       cityCode) VALUES ( 1,
                                          email,
                                          password,
                                          name,
                                          usrImgURL,
                                          gender,
                                          dob,
                                          lat,
                                          lng,
                                          POINT(lng, lat),
                                          @countryCode,
                                          @stateCode,
                                          @countyCode,
                                          @cityCode);
    END IF;

    SELECT u.*
    FROM users AS u
    WHERE u.id = LAST_INSERT_ID();
  END IF;

  DROP TABLE geoLocation;

END //


DROP PROCEDURE IF EXISTS FindUserbyID;
CREATE PROCEDURE FindUserbyID ( IN id INTEGER )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find local user entry in database'
BEGIN

DECLARE accountType INTEGER;

SELECT u.accountType INTO accountType
FROM users AS u
WHERE u.id = id;

IF accountType = 1 THEN
  SELECT u.*
  FROM users AS u
  WHERE u.id = id;
ELSEIF accountType = 2 THEN

SELECT fb.*, CONCAT(fb.firstname, ' ',  fb.lastname) AS name, u.id, u.lat, u.lng, fba.date_registered
  FROM   facebook AS fb
    INNER JOIN facebook_accounts AS fba
      ON fb.facebook_id = fba.facebook_id
    INNER JOIN users AS u
      ON u.id = fba.id
    WHERE u.id = id;

ELSEIF accountType = 3 THEN

  SELECT t.*, u.id, u.lat, u.lng, ta.date_registered
  FROM   twitter AS t
    INNER JOIN twitter_accounts AS ta
      ON t.twitter_id = ta.twitter_id
    INNER JOIN users AS u
      ON u.id = ta.id
    WHERE u.id = id;

END IF;

END //


DROP PROCEDURE IF EXISTS FindUserbyEmail;
CREATE PROCEDURE FindUserbyEmail ( IN email VARCHAR(100))
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find local user entry by email in database'
BEGIN

SELECT u.*
FROM users AS u
WHERE u.email = email;

END //


DROP PROCEDURE IF EXISTS AddFacebookUser;
CREATE PROCEDURE AddFacebookUser ( IN facebook_id VARCHAR(100),
                                   IN email       VARCHAR(100),
                                   IN password    VARCHAR(100),
                                   IN firstname   VARCHAR(50),
                                   IN lastname    VARCHAR(50),
                                   IN profileURL  VARCHAR(200),
                                   IN usrImgURL   VARCHAR(200),
                                   IN gender      CHAR(6),
                                   IN hometown    VARCHAR(50),
                                   IN location    VARCHAR(100),
                                   IN dob         DATE,
                                   IN lat         DECIMAL(17,14),
                                   IN lng         DECIMAL(17,14)
                                   )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create facebook user entry in database'
BEGIN
INSERT INTO facebook(facebook_id,
                     email,
                     firstname,
                     lastname,
                     profileURL,
                     usrImgURL,
                     gender,
                     hometown,
                     location,
                     dob) VALUES (facebook_id,
                                  email,
                                  firstname,
                                  lastname,
                                  profileURL,
                                  usrImgURL,
                                  gender,
                                  hometown,
                                  location,
                                  dob);

INSERT INTO users (accountType,
                   email,
                   password,
                   name,
                   gender,
                   dob,
                   lat,
                   lng,
                   latlang) VALUES ( 2,
                                    email,
                                    password,
                                    firstname,
                                    gender,
                                    dob,
                                    lat,
                                    lng,
                                    POINT(lng, lat));

INSERT INTO facebook_accounts(facebook_id,
                              id,
                              date_registered) VALUES (facebook_id,
                                                       LAST_INSERT_ID(),
                                                       CURDATE());

SELECT fb.*, CONCAT(fb.firstname, ' ', fb.lastname) AS name, u.id, u.lat, u.lng, fba.date_registered
FROM   facebook AS fb
  INNER JOIN facebook_accounts AS fba
    ON fb.facebook_id = fba.facebook_id
  INNER JOIN users AS u
    ON u.id = fba.id
  WHERE fba.facebook_id = facebook_id;

END //


DROP PROCEDURE IF EXISTS FindFacebookUser;
CREATE PROCEDURE FindFacebookUser ( IN facebook_id VARCHAR(100) )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find facebook user entry in database'
BEGIN

SELECT fb.*, CONCAT(fb.firstname, ' ', fb.lastname) AS name, u.id, u.lat, u.lng, fba.date_registered
FROM   facebook AS fb
  INNER JOIN facebook_accounts AS fba
    ON fb.facebook_id = fba.facebook_id
  INNER JOIN users AS u
    ON u.id = fba.id
  WHERE fba.facebook_id = facebook_id;

END //



DROP PROCEDURE IF EXISTS AddTwitterUser;
CREATE PROCEDURE AddTwitterUser  ( IN twitter_id VARCHAR(100),
                                   IN username   VARCHAR(100),
                                   IN password   VARCHAR(100),
                                   IN name       VARCHAR(50),
                                   IN usrImgURL  VARCHAR(200),
                                   IN gender     CHAR(6),
                                   IN location   VARCHAR(100),
                                   IN dob        DATE,
                                   IN lat         DECIMAL(17,14),
                                   IN lng         DECIMAL(17,14)
                                 )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create twitter user entry in database'
BEGIN
INSERT INTO twitter(twitter_id,
                    username,
                    name,
                    usrImgURL,
                    location) VALUES (twitter_id,
                                      username,
                                      name,
                                      usrImgURL,
                                      location);
INSERT INTO users (accountType,
                   email,
                   password,
                   name,
                   gender,
                   dob,
                   lat,
                   lng,
                   latlang) VALUES ( 3,
                                    username,
                                    password,
                                    name,
                                    gender,
                                    dob,
                                    lat,
                                    lng,
                                    POINT(lng, lat));

INSERT INTO twitter_accounts(twitter_id,
                             id,
                             date_registered) VALUES (twitter_id,
                                                      LAST_INSERT_ID(),
                                                      CURDATE());

SELECT t.*, u.id, u.lat, u.lng, ta.date_registered
FROM   twitter AS t
  INNER JOIN twitter_accounts AS ta
    ON t.twitter_id = ta.twitter_id
  INNER JOIN users AS u
    ON u.id = ta.id
  WHERE ta.twitter_id = twitter_id;

END //


DROP PROCEDURE IF EXISTS FindTwitterUser;
CREATE PROCEDURE FindTwitterUser ( IN twitter_id VARCHAR(100) )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find twitter user entry in database'
BEGIN

SELECT t.*, u.id, u.lat, u.lng, ta.date_registered
FROM   twitter AS t
  INNER JOIN twitter_accounts AS ta
    ON t.twitter_id = ta.twitter_id
  INNER JOIN users AS u
    ON u.id = ta.id
  WHERE ta.twitter_id = twitter_id;

END //



DROP PROCEDURE IF EXISTS StoreInvitation;
CREATE PROCEDURE StoreInvitation ( IN email       VARCHAR(100),
                                   IN invite_id   VARCHAR(100),
                                   IN active      TINYINT(1)
                                 )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to store invitation ID entry in database'
BEGIN
INSERT INTO invitation (email,
                        invite_id,
                        active) VALUES (email,
                                        invite_id,
                                        active);


SELECT invite.*
FROM invitation AS invite
WHERE invite.email = email;

END //


DROP PROCEDURE IF EXISTS UpdateInvitation;
CREATE PROCEDURE UpdateInvitation ( IN email       VARCHAR(100),
                                    IN invite_id   VARCHAR(100),
                                    IN active      TINYINT(1)
                                  )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to update status of invitation entry in database'
BEGIN

UPDATE invitation AS invite
  SET invite.active    = active,
      invite.invite_id = invite_id
WHERE invite.email = email;


SELECT invite.*
FROM invitation AS invite
WHERE invite.email = email;

END //


DROP PROCEDURE IF EXISTS RetriveInvitationByEmail;
CREATE PROCEDURE RetriveInvitationByEmail ( IN email VARCHAR(100))
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find invitation entry by email in database'
BEGIN

SELECT invite.*
FROM invitation AS invite
WHERE invite.email = email;

END //


DROP PROCEDURE IF EXISTS RetriveInvitationById;
CREATE PROCEDURE RetriveInvitationById ( IN id VARCHAR(100))
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to find invitation entry by email in database'
BEGIN

SELECT invite.*
FROM invitation AS invite
WHERE invite.invite_id = id;

END //

DROP PROCEDURE IF EXISTS CreatePoll;
CREATE PROCEDURE CreatePoll (IN user_id     INTEGER,
                             IN question    VARCHAR(140)
                            )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create poll entry in database'
BEGIN
DECLARE poll_id INTEGER DEFAULT 0;
SELECT polls.id FROM polls WHERE polls.question = question INTO poll_id;
IF NOT poll_id > 0 THEN
  INSERT INTO polls (user_id,
                     question,
                     dt) VALUES (user_id,
                                 question,
                                 UTC_TIMESTAMP());
END IF;

SELECT p.*
FROM polls AS p
WHERE p.id = LAST_INSERT_ID();

END //

DROP PROCEDURE IF EXISTS GetPolls;
CREATE PROCEDURE GetPolls ()
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to fetch all the polls from database'
BEGIN

SELECT users.name, users.usrImgURL, polls.id AS poll_id, polls.user_id, polls.question AS poll, polls.dt AS date, options.id AS option_id, options.optionstr, options.color
FROM polls
  INNER JOIN users ON users.id = polls.user_id
  INNER JOIN options ON polls.id = options.poll_id;

END //

DROP PROCEDURE IF EXISTS AddOption;
CREATE PROCEDURE AddOption (IN poll_id     INTEGER,
                            IN optionstr   VARCHAR(30),
                            IN color       VARCHAR(7)
                            )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create poll option entry in database'
BEGIN
DECLARE option_id INTEGER DEFAULT 0;

SELECT options.id INTO option_id
FROM polls
  INNER JOIN options ON polls.id = options.poll_id
WHERE options.optionstr = optionstr
  AND polls.id = poll_id;

IF NOT option_id > 0 THEN
  INSERT INTO options (poll_id,
                       optionstr,
                       color) VALUES (poll_id,
                                      optionstr,
                                      color);
END IF;

SELECT *
FROM polls
  INNER JOIN options ON polls.id = options.poll_id
WHERE polls.id = poll_id;

END //

DROP PROCEDURE IF EXISTS PostVote;
CREATE PROCEDURE PostVote ( IN poll_id     INTEGER,
                            IN user_id     INTEGER,
                            IN option_id   INTEGER
                          )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create vote entry in database'
BEGIN
INSERT INTO pollanswers (poll_id,
                         user_id,
                         option_id,
                         dt) VALUES (poll_id,
                                      user_id,
                                      option_id,
                                      UTC_TIMESTAMP()) ON DUPLICATE KEY UPDATE option_id=option_id, dt=UTC_TIMESTAMP();

SELECT pa.*
FROM pollanswers AS pa
WHERE pa.poll_id = poll_id AND pa.user_id = user_id;

END //

DROP PROCEDURE IF EXISTS GetWorldVotes;
CREATE PROCEDURE GetWorldVotes ( IN poll_id INTEGER )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create vote entry in database'
BEGIN

SELECT users.countryCode AS id, pa.poll_id, count(*) AS count, pa.option_id, options.optionstr, options.color
FROM pollanswers AS pa
  INNER JOIN users ON pa.user_id = users.id
  INNER JOIN options on pa.option_id = options.id
WHERE pa.poll_id = poll_id
GROUP BY users.countryCode, pa.option_id;

END //


DROP PROCEDURE IF EXISTS GetCountryVotes;
CREATE PROCEDURE GetCountryVotes ( IN poll_id INTEGER,
                                   IN country_code CHAR(3) )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create vote entry in database'
BEGIN

SELECT users.countryCode, users.stateCode AS id, pa.poll_id, count(*) AS count, pa.option_id, options.optionstr, options.color
FROM pollanswers AS pa
  INNER JOIN users ON pa.user_id = users.id
  INNER JOIN options on pa.option_id = options.id
WHERE users.countryCode = country_code AND pa.poll_id = poll_id
GROUP BY users.stateCode, pa.option_id;

END //

DROP PROCEDURE IF EXISTS GetStateVotes;
CREATE PROCEDURE GetStateVotes ( IN poll_id INTEGER,
                                 IN country_code CHAR(3),
                                 IN state_id INTEGER)
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create vote entry in database'
BEGIN

  SET @cityQuery = ' ';
  SET @countyQuery = ' ';

  SELECT column_name INTO @cityQuery
  FROM information_schema.COLUMNS
  WHERE
      TABLE_SCHEMA = 'opinions'
  AND TABLE_NAME = LOWER(country_code)
  AND COLUMN_NAME = 'city_name';

  IF (NOT @cityQuery = ' ') THEN

    SELECT users.countryCode, users.stateCode, users.cityCode as id, pa.poll_id, count(*) AS count, pa.option_id, options.optionstr, options.color
    FROM pollanswers AS pa
      INNER JOIN users ON pa.user_id = users.id
      INNER JOIN options on pa.option_id = options.id
    WHERE users.countryCode = country_code AND users.stateCode = state_id AND pa.poll_id = poll_id
    GROUP BY users.cityCode, pa.option_id;
  ELSE
    SELECT users.countryCode, users.stateCode, users.countyCode as id, pa.poll_id, count(*) AS count, pa.option_id, options.optionstr, options.color
    FROM pollanswers AS pa
      INNER JOIN users ON pa.user_id = users.id
      INNER JOIN options on pa.option_id = options.id
    WHERE users.countryCode = country_code AND users.stateCode = state_id AND pa.poll_id = poll_id
    GROUP BY users.cityCode, pa.option_id;
  END IF;

END //


DROP PROCEDURE IF EXISTS CreateOpinion;
CREATE PROCEDURE CreateOpinion (IN poll_id     INTEGER,
                                IN user_id     INTEGER,
                                IN opinion     VARCHAR(1000)
                               )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create opinion entry in database'
BEGIN
DECLARE opinion_id INTEGER DEFAULT 0;
SELECT opinions.id FROM opinions WHERE opinions.poll_id=poll_id AND  opinions.user_id=user_id INTO opinion_id;
IF NOT opinion_id>0 THEN
  INSERT INTO opinions (poll_id,
                        user_id,
                        opinion,
                        dt) VALUES (poll_id,
                                    user_id,
                                    opinion,
                                    UTC_TIMESTAMP());

  INSERT INTO opinionstats (opinion_id,
                            comment_cnt,
                            like_cnt) VALUES (LAST_INSERT_ID(),
                                              0,
                                              0);
END IF;

SELECT o.*
FROM opinions AS o
WHERE o.id = LAST_INSERT_ID();

END //

DROP PROCEDURE IF EXISTS GetOpinions;
CREATE PROCEDURE GetOpinions (IN poll_id     INTEGER)
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to fetch all the opinions from database'
BEGIN

SELECT u.name, u.usrImgURL, p.question, o.*
FROM opinions AS o
  INNER JOIN users AS u
    ON u.id=o.user_id
  INNER JOIN polls AS p
    ON p.id = o.poll_id
WHERE o.poll_id = poll_id;

END //

DROP PROCEDURE IF EXISTS PostOpinionLike;
CREATE PROCEDURE PostOpinionLike ( IN opinion_id     INTEGER,
                                   IN user_id        INTEGER
                                 )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create opinion like entry in database'
BEGIN
DECLARE o_id INTEGER DEFAULT 0;

SELECT opinionlikes.opinion_id FROM opinionlikes
  WHERE opinionlikes.opinion_id=opinion_id AND  opinionlikes.user_id=user_id
INTO o_id;

IF NOT o_id>0 THEN

  INSERT INTO opinionlikes (opinion_id,
                            user_id) VALUES (opinion_id,
                                             user_id) ON DUPLICATE KEY UPDATE opinion_id=opinion_id;
  UPDATE opinionstats AS os
    SET os.like_cnt = os.like_cnt + 1
  WHERE os.opinion_id = opinion_id;
END IF;

SELECT ol.*
FROM opinionlikes AS ol
WHERE ol.opinion_id = opinion_id AND ol.user_id = user_id;

END //

DROP PROCEDURE IF EXISTS CreateComment;
CREATE PROCEDURE CreateComment (IN opinion_id     INTEGER,
                                IN user_id     INTEGER,
                                IN comment     VARCHAR(1000)
                               )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to create comment entry in database'
BEGIN
DECLARE comment_id INTEGER DEFAULT 0;
SELECT comments.id FROM comments WHERE comments.comment_text = comment INTO comment_id;
IF NOT comment_id>0 THEN
  INSERT INTO comments (opinion_id,
                        user_id,
                        comment_text,
                        dt) VALUES (opinion_id,
                                    user_id,
                                    comment,
                                    UTC_TIMESTAMP());
END IF;

SELECT c.*
FROM comments AS c
WHERE c.id = LAST_INSERT_ID();

END //

DROP PROCEDURE IF EXISTS GetComments;
CREATE PROCEDURE GetComments (IN opinion_id     INTEGER)
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to fetch all the comments from database for a specific opinion'
BEGIN

SELECT u.name, u.usrImgURL, c.*
FROM users AS u
JOIN comments AS c
ON u.id = c.user_id
WHERE c.opinion_id = opinion_id;

END //

DROP PROCEDURE IF EXISTS ReverseGeoCoder;
CREATE PROCEDURE ReverseGeoCoder ( IN lat         DECIMAL(17,14),
                                   IN lng         DECIMAL(17,14)
                                 )
LANGUAGE SQL
DETERMINISTIC
SQL SECURITY DEFINER
COMMENT 'Stored procedure to reverse geocode from latitude and longitude'
BEGIN

SET @country = '';

SELECT ADM0_A3 INTO @country
FROM world
WHERE ST_CONTAINS(SHAPE, POINT(lng, lat));

  SET @cityQuery = ' ';
  SET @countyQuery = ' ';

  SELECT column_name INTO @cityQuery
  FROM information_schema.COLUMNS
  WHERE
      TABLE_SCHEMA = 'opinions'
  AND TABLE_NAME = LOWER(@country)
  AND COLUMN_NAME = 'city_name';

  IF (NOT @cityQuery = ' ') THEN
    SET @sqlstmt = CONCAT('SELECT country_name, @country AS country_code, state_name, state_code, county_name, county_code, city_name, city_code '
                          'FROM ', LOWER(@country), ' '
                          'WHERE ST_CONTAINS(SHAPE, POINT(', lng, ',', lat, '))');
  ELSE
    SET @sqlstmt = CONCAT('SELECT country_name, @country AS country_code, state_name, state_code, county_name, county_code '
                          'FROM ', LOWER(@country), ' '
                          'WHERE ST_CONTAINS(SHAPE, POINT(', lng, ',', lat, '))');
  END IF;

  PREPARE stmt from @sqlstmt;
  EXECUTE stmt;

END //


DELIMITER ;

CALL AddUser('root@root.com',
            'athakwanipdevanur',
            'Root',
            "./public/avatar/avatar001.png",
            'male',
            '1983-01-01',
            28.6,
            77.23);

CALL AddUser('root1@root.com',
            'athakwanipdevanur',
            'Bob Nilson',
            "./public/avatar/avatar002.png",
            'male',
            '1980-01-01',
            28.5,
            77.13);

CALL AddUser('root2@root.com',
            'athakwanipdevanur',
            'Lisa Wong',
            "./public/avatar/avatar003.png",
            'female',
            '1990-01-01',
            28.4,
            77.03);

CALL AddUser('root3@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar004.png",
            'male',
            '1978-01-01',
            28.3,
            77.43);

CALL AddUser('root4@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar005.png",
            'male',
            '1978-01-01',
            28.7,
            77.33);

CALL AddUser('root5@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar006.png",
            'male',
            '1978-01-01',
            28.3,
            77.63);

CALL AddUser('root6@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar007.png",
            'male',
            '1978-01-01',
            28.2,
            77.33);

CALL AddUser('root7@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar008.png",
            'male',
            '1978-01-01',
            28.6,
            77.13);

CALL AddUser('root8@root.com',
            'athakwanipdevanur',
            'Richard Doe',
            "./public/avatar/avatar001.png",
            'male',
            '1978-01-01',
            28.1,
            77.03);


CALL CreatePoll(1, "Which party do you support for 2015 Delhi assembly elections?");
CALL AddOption(1, "AAP", "#FFB746");
CALL AddOption(1, "BJP", "#D4E157");
CALL AddOption(1, "Congress", "blue");


CALL CreateOpinion(1, 1, "I support AAP");
CALL CreateComment(1, 1, "I support BJP");
CALL CreateComment(1, 2, "this is new 1..");
CALL CreateComment(1, 3, "this is new 2..");
CALL CreateComment(1, 4, "this is really long comment, very very very very very long so that it overflows on multiple lines to check how the display looks like for long comments...");

CALL PostVote(1, 1, 1);
CALL PostVote(1, 2, 1);
CALL PostVote(1, 3, 2);
CALL PostVote(1, 4, 2);
CALL PostVote(1, 5, 1);
CALL PostVote(1, 6, 1);
CALL PostVote(1, 7, 2);
CALL PostVote(1, 8, 2);
