-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 16, 2021 at 12:37 PM
-- Server version: 10.4.19-MariaDB
-- PHP Version: 8.0.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_project`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ava` (IN `AVA_CONTENT` VARCHAR(256), IN `AVA_POSTAGE_DATE` DATETIME, OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    iF @USER_NAME IS NOT NULL THEN

        INSERT INTO ava(USER_NAME, AVA_CONTENT, AVA_POSTAGE_DATE)
        VALUES (@USER_NAME, AVA_CONTENT, AVA_POSTAGE_DATE);
        SET STATE = 'AVA ADDED';
    	
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_hashtag` (IN `TEXT` VARCHAR(6), OUT `STATE` VARCHAR(50))  iF TEXT REGEXP '^#[a-zA-z]{5}$' 
THEN
	INSERT INTO hashtag (TEXT)
    VALUES (TEXT);
    SET STATE = 'HASHTAG ADDED';
ELSE
	SET STATE = 'FAILED TO ADD';
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_hashtag_to_ava` (IN `AVA_ID` INT(11), IN `TEXT` VARCHAR(6), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN

        INSERT INTO RELATIONSHIP_HASHTAG_AVA(AVA_ID, USER_NAME, TEXT)
        VALUES (`AVA_ID`, @USER_NAME,`TEXT`);
        SET STATE = 'HASHTAG ADDED TO AVA';
    	
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user` (IN `FIRST_NAME` VARCHAR(20), IN `LAST_NAME` VARCHAR(20), IN `USER_NAME` VARCHAR(20), IN `PASSWORD` VARCHAR(128), IN `BIRTHDAY` DATETIME, IN `REGISTERY_DATE` DATETIME, IN `BIOGRAPHY` VARCHAR(64))  BEGIN

    INSERT INTO user_data(FIRST_NAME, LAST_NAME, USER_NAME, PASSWORD, BIRTHDAY, BIOGRAPHY)
    VALUES (FIRST_NAME, LAST_NAME, USER_NAME, PASSWORD, BIRTHDAY, BIOGRAPHY);
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ava_comments` (IN `RECEVIER_COMMENTING_USER_NAME` VARCHAR(20), IN `RECEVIER_AVA_ID` INT(11), IN `CONTENT` VARCHAR(256), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN

        IF NOT EXISTS (SELECT *
                         FROM blocking as B
                         WHERE 
                         B.BLOCKER_USER_NAME = `RECEVIER_COMMENTING_USER_NAME`
                         AND
                         B.BLOCKED_USER_NAME = @USER_NAME)
           AND
           EXISTS (SELECT *
                    FROM ava as A
                    WHERE
                    A.AVA_ID = `RECEVIER_AVA_ID`
                    AND
                    A.USER_NAME = `RECEVIER_COMMENTING_USER_NAME`)
        THEN

            INSERT INTO ava (USER_NAME, AVA_CONTENT)
            SELECT @USER_NAME as USER_NAME, `CONTENT` as AVA_CONTENT;

            SET @SENDER_AVA_ID := (SELECT A.AVA_ID
                                    FROM ava as A
                                    WHERE A.AVA_POSTAGE_DATE = (SELECT MAX(ava.AVA_POSTAGE_DATE) 
                                                                FROM ava 
                                                                WHERE ava.USER_NAME = @USER_NAME)
                                    AND A.USER_NAME = @USER_NAME);

            INSERT INTO commenting (SENDER_COMMENTING_USER_NAME, SENDER_AVA_ID, RECEVIER_COMMENTING_USER_NAME, RECEVIER_AVA_ID)
            SELECT @USER_NAME as SENDER_COMMENTING_USER_NAME, @SENDER_AVA_ID as SENDER_AVA_ID,
            `RECEVIER_COMMENTING_USER_NAME` as RECEVIER_COMMENTING_USER_NAME, `RECEVIER_AVA_ID` as RECEVIER_AVA_ID;
            
            SET STATE = 'AVA COMMENT ADDED';
		
		ELSE
			SET STATE = 'AVA COMMENT FAILED TO ADD';
        END IF;
        
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `block_user` (IN `BLOCKED_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN

        INSERT INTO BLOCKING(BLOCKER_USER_NAME, BLOCKED_USER_NAME)
        VALUES (@USER_NAME, `BLOCKED_USER_NAME`);
        SELECT CONCAT(@USER_NAME, ' BLOCKED ', `BLOCKED_USER_NAME`)
        INTO STATE;
	
    END IF;
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `check_login` (OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
	
        SELECT * FROM
        (SELECT U.USER_NAME, U.LOGIN_TIME, U.LOG_TYPE
        FROM user_log as U
        WHERE U.USER_NAME = @USER_NAME
        ORDER BY U.LOGIN_TIME DESC
        LIMIT 1) AS H
        WHERE H.LOG_TYPE = 1;
        SET STATE = 'USER FOUND';
    
    ELSE
    
    	SET STATE = 'USER NOT FOUND';
        
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `follow_user` (IN `FOLLOWED_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);

	IF @USER_NAME IS NOT NULL THEN
        insert into FOLLOWING(FOLLOWER_USER_NAME, FOLLOWED_USER_NAME)
        VALUES (@USER_NAME, `FOLLOWED_USER_NAME`);
        SELECT CONCAT(@USER_NAME, ' FOLLOWED ', `FOLLOWED_USER_NAME`) INTO STATE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ava_comments` (IN `SELECT_AVA_ID` INT(11), IN `SELECT_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
        select *
        from COMMENTING as C inner join AVA as A
        on 
        `SELECT_AVA_ID` = C.RECEVIER_AVA_ID
        and
        `SELECT_USER_NAME` = C.RECEVIER_COMMENTING_USER_NAME
        and
        C.SENDER_AVA_ID = A.AVA_ID
        and
        C.SENDER_COMMENTING_USER_NAME = A.USER_NAME
        and
        not exists (select *
                    from BLOCKING as B
                    where 
                    (
                    B.BLOCKER_USER_NAME = C.SENDER_COMMENTING_USER_NAME
                    or
                    B.BLOCKER_USER_NAME = C.RECEVIER_COMMENTING_USER_NAME
                    )
                    and
                    B.BLOCKED_USER_NAME = @USER_NAME
                    );
       	SET STATE = 'AVA_COMMENTING RECEIVE';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_login_user` (OUT `USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	SELECT U.USER_NAME INTO `USER_NAME`
	FROM (SELECT * 
    FROM user_log as UL
    ORDER BY UL.LOGIN_TIME DESC
    LIMIT 1) AS U
    WHERE U.LOG_TYPE = 1;
    
    IF USER_NAME IS NULL THEN
    	SET STATE = 'USER NOT LOGIN';
    ELSE 
    	SET STATE = 'USER LOGIN';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_the_activity_of_the_followers` (OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
	
    IF @USER_NAME IS NOT NULL THEN
        SELECT *
        FROM FOLLOWING as F inner join MESSAGE as M
        ON 
        F.FOLLOWER_USER_NAME = M.SENDER_USER_NAME
        AND
        F.FOLLOWED_USER_NAME = M.RECEIVER_USER_NAME
        WHERE
        M.MES_CONTENT IS NULL
        AND
        F.FOLLOWED_USER_NAME = @USER_NAME
        AND
        F.FOLLOWER_USER_NAME NOT IN (select BLOCKER_USER_NAME FROM BLOCKING)
        ORDER BY M.MES_POSTAGE_DATE DESC;
        SET STATE = 'LIST ACTIVITY RECEIVED';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_activity` (IN `BLOCKED_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);

	IF @USER_NAME IS NOT NULL THEN
        select *
        from AVA as A
        where
        A.USER_NAME = @USER_NAME
        and
        not exists (select *
                     from BLOCKING as B
                     where 
                     B.BLOCKER_USER_NAME = @USER_NAME
                     and
                     B.BLOCKED_USER_NAME = `BLOCKED_USER_NAME`
                     );
        SET STATE = 'USER_ACTIVITY_RECEIVED';
     END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `like_ava` (IN `AVA_ID` INT(11), IN `AVA_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);

	IF @USER_NAME IS NOT NULL THEN
        INSERT INTO LIKED(USER_NAME, AVA_ID, AVA_USER_NAME)
        SELECT @USER_NAME as USER_NAME , `AVA_ID` as AVA_ID, `AVA_USER_NAME` as AVA_USER_NAME;
		SELECT CONCAT(@USER_NAME, ' LIKE AVA ', `AVA_ID`, ' _ ', `AVA_USER_NAME`) INTO STATE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `list_message_senders` (OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);

	IF @USER_NAME IS NOT NULL THEN
        select DISTINCT M.SENDER_USER_NAME
        from MESSAGE as M
        where  M.RECEIVER_USER_NAME = @USER_NAME and (
            M.AVA_ID is null or ( M.AVA_ID is not null 
                                 and
                                 not exists (select *
                                             from BLOCKING as B
                                             where
                                             B.BLOCKER_USER_NAME = M.SENDER_USER_NAME
                                             and
                                             B.BLOCKED_USER_NAME = M.RECEIVER_USER_NAME
                                            )
                                )
        )
        order by M.MES_POSTAGE_DATE DESC;
    	SET STATE = 'LIST MASSAGE SENDERS RECEIVED';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_Ava` (OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
        select *
        from AVA 
        where AVA.USER_NAME = @USER_NAME;
        SET STATE = 'AVA RECEIVED';
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_ava_of_a_special_symbol` (IN `TEXT` VARCHAR(6), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
        select @USER_NAME as USER_NAME, TEXT, A.AVA_ID, A.USER_NAME, A.AVA_CONTENT, A.AVA_POSTAGE_DATE
        from RELATIONSHIP_HASHTAG_AVA as R inner join AVA as A
        on
        R.TEXT = TEXT
        and
        R.AVA_ID = A.AVA_ID
        and
        R.USER_NAME = A.USER_NAME
        and
        not exists (select * 
                    from BLOCKING as B
                    where 
                    B.BLOCKER_USER_NAME = R.USER_NAME
                    and
                    B.BLOCKED_USER_NAME = @USER_NAME
                );
        SET STATE = 'SPECIAL SYMBOL RECEIVED';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_count_of_Like` (IN `SELECT_AVA_ID` INT(11), IN `SELECT_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN
	
    CALL get_login_user(@USER_NAME, STATE);
	
    IF @USER_NAME IS NOT NULL THEN
        select @USER_NAME, case when
									not exists (select *
												from BLOCKING as B
												where 
												B.BLOCKER_USER_NAME = `SELECT_USER_NAME`
												and
												B.BLOCKED_USER_NAME = @USER_NAME
											   )
										then COUNT(*)
										else 0
									end as 'COUNT_OF_LIKE'

        from LIKED as L
        WHERE L.AVA_ID = `SELECT_AVA_ID` and L.AVA_USER_NAME = `SELECT_USER_NAME`;
        SET STATE = 'COUNT OF LIKE RECEIVED';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_list_message_of_user` (OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
	
    IF @USER_NAME IS NOT NULL THEN
        select *
        from MESSAGE as M
        where  M.RECEIVER_USER_NAME = @USER_NAME AND 
        (M.AVA_ID is null or ( M.AVA_ID is not null 
                                    and
                                    not exists (select *
                                                from BLOCKING as B
                                                where
                                                B.BLOCKER_USER_NAME = M.SENDER_USER_NAME
                                                and
                                                B.BLOCKED_USER_NAME = M.RECEIVER_USER_NAME
                                                )
                             )                                   
        )
        order by M.MES_POSTAGE_DATE DESC;
        SET STATE = 'LIST MESSAGE OF USER RECEIVED';
    END IF;
    

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_list_of_Like` (IN `SELECT_AVA_ID` INT(11), IN `SELECT_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
	
    IF @USER_NAME IS NOT NULL THEN
        select @USER_NAME as 'REQUESTED_USER_NAME', L.USER_NAME, L.AVA_ID, L.AVA_USER_NAME
        from LIKED as L
        where L.AVA_ID = SELECT_AVA_ID and L.AVA_USER_NAME = SELECT_USER_NAME
        and not exists (select *
                            from BLOCKING as B
                            where 
                            B.BLOCKER_USER_NAME = SELECT_USER_NAME
                            and
                            B.BLOCKED_USER_NAME = @USER_NAME
                            )
        and not exists (select *
                         from BLOCKING as B
                         where 
                         B.BLOCKER_USER_NAME = L.USER_NAME
                         and
                         B.BLOCKED_USER_NAME = @USER_NAME
                         )
            and exists (SELECT * FROM user_data as U WHERE U.USER_NAME = @USER_NAME);
            SET STATE = 'LIST OF LIKE RECEIVED';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_popular_ava` ()  BEGIN

    select A.USER_NAME , COUNT(A.AVA_ID) as 'COUNT_OF_LIKE'
    from AVA as A join LIKED as L
    on A.AVA_ID = L.AVA_ID and A.USER_NAME = L.AVA_USER_NAME
    where not exists (select *
                        from BLOCKING as B
                        where
                        B.BLOCKER_USER_NAME = L.AVA_USER_NAME
                        and
                        B.BLOCKED_USER_NAME = L.USER_NAME
                        )
    group by A.USER_NAME
    order by COUNT(A.AVA_ID);


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_ava` (IN `RECEIVER_USER_NAME` VARCHAR(20), IN `AVA_ID` INT(11), IN `MES_POSTAGE_DATE` DATETIME, OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);

	IF @USER_NAME IS NOT NULL THEN
        INSERT INTO MESSAGE(SENDER_USER_NAME, RECEIVER_USER_NAME, AVA_ID, MES_POSTAGE_DATE)
        VALUES (@USER_NAME, RECEIVER_USER_NAME, AVA_ID, MES_POSTAGE_DATE);
        SELECT CONCAT(@USER_NAME, ' SEND AVA TO ', `RECEIVER_USER_NAME`) INTO STATE;
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_message` (IN `RECEIVER_USER_NAME` VARCHAR(20), IN `MES_CONTENT` VARCHAR(256), IN `MES_POSTAGE_DATE` DATETIME, OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
    
    	INSERT INTO message(SENDER_USER_NAME, RECEIVER_USER_NAME, AVA_ID, MES_POSTAGE_DATE, MES_CONTENT)
        VALUES (@USER_NAME, `RECEIVER_USER_NAME`, NULL, `MES_POSTAGE_DATE`, `MES_CONTENT`);
        SELECT CONCAT(@USER_NAME, ' SEND MESSAGE TO ' , `RECEIVER_USER_NAME`);
    
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stop_block` (IN `BLOCKED_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
    
    IF @USER_NAME IS NOT NULL THEN
    	IF `BLOCKED_USER_NAME` IN (SELECT B.BLOCKED_USER_NAME
                                   FROM blocking as B
                                   WHERE
           	 					   B.BLOCKER_USER_NAME = @USER_NAME) THEN
            DELETE 
            FROM BLOCKING
            WHERE
            BLOCKING.BLOCKER_USER_NAME = @USER_NAME
            AND
            BLOCKING.BLOCKED_USER_NAME = `BLOCKED_USER_NAME`;
        	SELECT CONCAT(@USER_NAME, ' STOP BLOCKING ', `BLOCKED_USER_NAME`) INTO STATE;
        ELSE
        	SELECT CONCAT(@USER_NAME, ' STOP BLOCKING FAILED ', `BLOCKED_USER_NAME`) INTO STATE;
        END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stop_following` (IN `FOLLOWED_USER_NAME` VARCHAR(20), OUT `STATE` VARCHAR(50))  BEGIN

	CALL get_login_user(@USER_NAME, STATE);
	
    IF @USER_NAME IS NOT NULL THEN
        IF `FOLLOWED_USER_NAME` IN (SELECT F.FOLLOWED_USER_NAME
                                       FROM following as F
                                       WHERE
                                       F.FOLLOWER_USER_NAME = @USER_NAME) THEN
            delete
            from following
            WHERE
            following.FOLLOWER_USER_NAME = @USER_NAME
            and
            following.FOLLOWED_USER_NAME = `FOLLOWED_USER_NAME`;
            SELECT CONCAT(@USER_NAME, ' STOP FOLLOWING ', `FOLLOWED_USER_NAME`) INTO STATE;
        ELSE
        	SELECT CONCAT(@USER_NAME, ' STOP FOLLOWING FAILED ', `FOLLOWED_USER_NAME`) INTO STATE;
        END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_log` (IN `USER_NAME` VARCHAR(20), IN `PASSWORD` VARCHAR(128), IN `LOG_TYPE` BOOLEAN, OUT `STATE` VARCHAR(50))  BEGIN

	IF EXISTS(SELECT * FROM user_data as UD
              WHERE `USER_NAME` = UD.USER_NAME
             	AND `PASSWORD` = UD.PASSWORD)
       AND (EXISTS (SELECT * 
                   FROM (SELECT * 
                         FROM user_log as U
                         ORDER BY U.LOGIN_TIME DESC
                         LIMIT 1) AS H 
                   WHERE LOG_TYPE <> H.LOG_TYPE)
            OR NOT EXISTS(SELECT * 
                         FROM user_log as U
                         ORDER BY U.LOGIN_TIME DESC
                         LIMIT 1))
    THEN
    
    	INSERT INTO user_log (USER_NAME, LOG_TYPE)
        VALUES (`USER_NAME`, LOG_TYPE);
        
        IF LOG_TYPE = 1 THEN
        	SELECT CONCAT(`USER_NAME`,' LOGIN DONE')
            as STATE INTO STATE;
        ELSE  
        	SELECT CONCAT(`USER_NAME`,' LOGOUT DONE')
            as STATE INTO STATE;
        END IF;
        
    
    ELSE
    	
        IF LOG_TYPE = 1 THEN
        	SELECT CONCAT(`USER_NAME`,' LOGIN FAILED')
            as STATE INTO STATE;
        ELSE
        	SELECT CONCAT(`USER_NAME`,' LOGOUT FAILED') 
            as STATE INTO STATE;
        END IF;
        
	END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ava`
--

CREATE TABLE `ava` (
  `AVA_ID` int(11) NOT NULL,
  `USER_NAME` varchar(20) NOT NULL,
  `AVA_CONTENT` varchar(256) NOT NULL,
  `AVA_POSTAGE_DATE` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `blocking`
--

CREATE TABLE `blocking` (
  `BLOCKER_USER_NAME` varchar(20) NOT NULL,
  `BLOCKED_USER_NAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `blocking`
--
DELIMITER $$
CREATE TRIGGER `valid_block` BEFORE INSERT ON `blocking` FOR EACH ROW BEGIN

	IF NEW.BLOCKER_USER_NAME = NEW.BLOCKED_USER_NAME THEN
   		 signal sqlstate '45000';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `commenting`
--

CREATE TABLE `commenting` (
  `SENDER_COMMENTING_USER_NAME` varchar(20) NOT NULL,
  `SENDER_AVA_ID` int(11) NOT NULL,
  `RECEVIER_COMMENTING_USER_NAME` varchar(20) NOT NULL,
  `RECEVIER_AVA_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `following`
--

CREATE TABLE `following` (
  `FOLLOWER_USER_NAME` varchar(20) NOT NULL,
  `FOLLOWED_USER_NAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `following`
--
DELIMITER $$
CREATE TRIGGER `following_block` BEFORE INSERT ON `following` FOR EACH ROW BEGIN
		
     IF EXISTS (SELECT *
                  FROM following as H
                  WHERE 
                  H.FOLLOWER_USER_NAME = NEW.FOLLOWER_USER_NAME 
                  and 
                  H.FOLLOWED_USER_NAME = NEW.FOLLOWED_USER_NAME
                  ) 
     OR EXISTS (SELECT *
                  FROM blocking as B
                  WHERE 
                  B.BLOCKER_USER_NAME =  NEW.FOLLOWED_USER_NAME
                  and 
                  B.BLOCKED_USER_NAME = NEW.FOLLOWER_USER_NAME
                )
     OR NEW.FOLLOWED_USER_NAME = NEW.FOLLOWER_USER_NAME
     THEN         
        signal sqlstate '45000';
     END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `hashtag`
--

CREATE TABLE `hashtag` (
  `TEXT` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `liked`
--

CREATE TABLE `liked` (
  `USER_NAME` varchar(20) NOT NULL,
  `AVA_ID` int(11) NOT NULL,
  `AVA_USER_NAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `liked`
--
DELIMITER $$
CREATE TRIGGER `block_like` BEFORE INSERT ON `liked` FOR EACH ROW BEGIN

	IF exists (select *
                        from BLOCKING as B
                        where 
                        B.BLOCKER_USER_NAME = NEW.AVA_USER_NAME
                        and
                        B.BLOCKED_USER_NAME = NEW.USER_NAME
                        )
    THEN
    	signal sqlstate '45000';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `MES_ID` int(11) NOT NULL,
  `SENDER_USER_NAME` varchar(20) NOT NULL,
  `RECEIVER_USER_NAME` varchar(20) NOT NULL,
  `AVA_ID` int(11) DEFAULT NULL,
  `MES_POSTAGE_DATE` datetime DEFAULT current_timestamp(),
  `MES_CONTENT` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `message`
--
DELIMITER $$
CREATE TRIGGER `block_send_ava_and_message` BEFORE INSERT ON `message` FOR EACH ROW BEGIN

    IF 	(NEW.AVA_ID IS NULL XOR  NEW.MES_CONTENT IS NOT NULL)
    	OR NEW.SENDER_USER_NAME = NEW.RECEIVER_USER_NAME
        OR EXISTS (select *
                     from BLOCKING as B
                     where 	
                     (B.BLOCKER_USER_NAME = NEW.RECEIVER_USER_NAME
                      and
                      B.BLOCKED_USER_NAME = NEW.SENDER_USER_NAME)
                     or
                     (NEW.AVA_ID is not null
                      and 
                      B.BLOCKER_USER_NAME = NEW.SENDER_USER_NAME
                      and
                      B.BLOCKED_USER_NAME = NEW.RECEIVER_USER_NAME)
                    )
    THEN
        signal sqlstate '45000';    
    END IF;
			
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `relationship_hashtag_ava`
--

CREATE TABLE `relationship_hashtag_ava` (
  `AVA_ID` int(11) NOT NULL,
  `USER_NAME` varchar(20) NOT NULL,
  `TEXT` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `relationship_hashtag_ava`
--
DELIMITER $$
CREATE TRIGGER `create_hashtag` BEFORE INSERT ON `relationship_hashtag_ava` FOR EACH ROW BEGIN

	IF NOT EXISTS (SELECT * FROM hashtag as H
                  	WHERE H.TEXT = NEW.TEXT)
    THEN
    
    	iF NEW.TEXT REGEXP '^#[a-zA-z]{5}$' THEN
            INSERT INTO hashtag (TEXT)
            VALUES (NEW.TEXT);
    	END iF;
        
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_data`
--

CREATE TABLE `user_data` (
  `FIRST_NAME` varchar(20) DEFAULT NULL,
  `LAST_NAME` varchar(20) DEFAULT NULL,
  `USER_NAME` varchar(20) NOT NULL,
  `PASSWORD` varchar(128) NOT NULL,
  `BIRTHDAY` datetime DEFAULT NULL,
  `REGISTERY_DATE` datetime DEFAULT current_timestamp(),
  `BIOGRAPHY` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `user_log`
--

CREATE TABLE `user_log` (
  `LOG_ID` int(11) NOT NULL,
  `USER_NAME` varchar(20) NOT NULL,
  `LOGIN_TIME` datetime NOT NULL DEFAULT current_timestamp(),
  `LOG_TYPE` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ava`
--
ALTER TABLE `ava`
  ADD PRIMARY KEY (`AVA_ID`,`USER_NAME`),
  ADD KEY `USER_NAME` (`USER_NAME`);

--
-- Indexes for table `blocking`
--
ALTER TABLE `blocking`
  ADD PRIMARY KEY (`BLOCKER_USER_NAME`,`BLOCKED_USER_NAME`),
  ADD UNIQUE KEY `CHECK_USER_CAN_NOT_BLOCK_HIMSELF` (`BLOCKER_USER_NAME`,`BLOCKED_USER_NAME`),
  ADD KEY `BLOCKED_USER_NAME` (`BLOCKED_USER_NAME`);

--
-- Indexes for table `commenting`
--
ALTER TABLE `commenting`
  ADD PRIMARY KEY (`RECEVIER_COMMENTING_USER_NAME`,`SENDER_COMMENTING_USER_NAME`,`SENDER_AVA_ID`,`RECEVIER_AVA_ID`),
  ADD KEY `RECEVIER_COMMENTING_USER_NAME` (`RECEVIER_COMMENTING_USER_NAME`,`RECEVIER_AVA_ID`),
  ADD KEY `FK_COMMENTI_RELATIONS_AVA_SENDER` (`SENDER_COMMENTING_USER_NAME`,`SENDER_AVA_ID`);

--
-- Indexes for table `following`
--
ALTER TABLE `following`
  ADD PRIMARY KEY (`FOLLOWER_USER_NAME`,`FOLLOWED_USER_NAME`),
  ADD UNIQUE KEY `CK_FOLLOWING` (`FOLLOWER_USER_NAME`,`FOLLOWED_USER_NAME`),
  ADD KEY `FK_FOLLOWIN_RELATIONS_USER_FOLLOWER` (`FOLLOWED_USER_NAME`);

--
-- Indexes for table `hashtag`
--
ALTER TABLE `hashtag`
  ADD PRIMARY KEY (`TEXT`);

--
-- Indexes for table `liked`
--
ALTER TABLE `liked`
  ADD PRIMARY KEY (`USER_NAME`,`AVA_USER_NAME`,`AVA_ID`),
  ADD KEY `FK_LIKE_RELATIONS_AVA` (`AVA_USER_NAME`,`AVA_ID`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`MES_ID`,`SENDER_USER_NAME`,`RECEIVER_USER_NAME`),
  ADD KEY `FK_MESSAGE_REFERENCE_AVA` (`SENDER_USER_NAME`,`AVA_ID`),
  ADD KEY `FK_MESSAGE_REFERENCE_USER_RECEEVIER` (`RECEIVER_USER_NAME`);

--
-- Indexes for table `relationship_hashtag_ava`
--
ALTER TABLE `relationship_hashtag_ava`
  ADD PRIMARY KEY (`USER_NAME`,`AVA_ID`,`TEXT`),
  ADD KEY `FK_RELATION_RELATIONS_HASHTAG` (`TEXT`);

--
-- Indexes for table `user_data`
--
ALTER TABLE `user_data`
  ADD PRIMARY KEY (`USER_NAME`);

--
-- Indexes for table `user_log`
--
ALTER TABLE `user_log`
  ADD PRIMARY KEY (`LOG_ID`,`USER_NAME`),
  ADD KEY `FK_LOGIN_RELATIONS_USER` (`USER_NAME`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ava`
--
ALTER TABLE `ava`
  MODIFY `AVA_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `MES_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_log`
--
ALTER TABLE `user_log`
  MODIFY `LOG_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ava`
--
ALTER TABLE `ava`
  ADD CONSTRAINT `ava_ibfk_1` FOREIGN KEY (`USER_NAME`) REFERENCES `user_data` (`USER_NAME`);

--
-- Constraints for table `blocking`
--
ALTER TABLE `blocking`
  ADD CONSTRAINT `blocking_ibfk_1` FOREIGN KEY (`BLOCKER_USER_NAME`) REFERENCES `user_data` (`USER_NAME`),
  ADD CONSTRAINT `blocking_ibfk_2` FOREIGN KEY (`BLOCKED_USER_NAME`) REFERENCES `user_data` (`USER_NAME`);

--
-- Constraints for table `commenting`
--
ALTER TABLE `commenting`
  ADD CONSTRAINT `FK_COMMENTI_RELATIONS_AVA_SENDER` FOREIGN KEY (`SENDER_COMMENTING_USER_NAME`,`SENDER_AVA_ID`) REFERENCES `ava` (`USER_NAME`, `AVA_ID`),
  ADD CONSTRAINT `commenting_ibfk_1` FOREIGN KEY (`RECEVIER_COMMENTING_USER_NAME`,`RECEVIER_AVA_ID`) REFERENCES `ava` (`USER_NAME`, `AVA_ID`);

--
-- Constraints for table `following`
--
ALTER TABLE `following`
  ADD CONSTRAINT `FK_FOLLOWIN_RELATIONS_USER_FOLLOWED` FOREIGN KEY (`FOLLOWER_USER_NAME`) REFERENCES `user_data` (`USER_NAME`),
  ADD CONSTRAINT `FK_FOLLOWIN_RELATIONS_USER_FOLLOWER` FOREIGN KEY (`FOLLOWED_USER_NAME`) REFERENCES `user_data` (`USER_NAME`);

--
-- Constraints for table `liked`
--
ALTER TABLE `liked`
  ADD CONSTRAINT `FK_LIKE_RELATIONS_AVA` FOREIGN KEY (`AVA_USER_NAME`,`AVA_ID`) REFERENCES `ava` (`USER_NAME`, `AVA_ID`),
  ADD CONSTRAINT `FK_LIKE_RELATIONS_USER` FOREIGN KEY (`USER_NAME`) REFERENCES `user_data` (`USER_NAME`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `FK_MESSAGE_REFERENCE_AVA` FOREIGN KEY (`SENDER_USER_NAME`,`AVA_ID`) REFERENCES `ava` (`USER_NAME`, `AVA_ID`),
  ADD CONSTRAINT `FK_MESSAGE_REFERENCE_USER_RECEEVIER` FOREIGN KEY (`RECEIVER_USER_NAME`) REFERENCES `user_data` (`USER_NAME`),
  ADD CONSTRAINT `FK_MESSAGE_RELATIONS_USER_SENDER` FOREIGN KEY (`SENDER_USER_NAME`) REFERENCES `user_data` (`USER_NAME`);

--
-- Constraints for table `relationship_hashtag_ava`
--
ALTER TABLE `relationship_hashtag_ava`
  ADD CONSTRAINT `FK_RELATION_RELATIONS_AVA` FOREIGN KEY (`USER_NAME`,`AVA_ID`) REFERENCES `ava` (`USER_NAME`, `AVA_ID`),
  ADD CONSTRAINT `FK_RELATION_RELATIONS_HASHTAG` FOREIGN KEY (`TEXT`) REFERENCES `hashtag` (`TEXT`);

--
-- Constraints for table `user_log`
--
ALTER TABLE `user_log`
  ADD CONSTRAINT `FK_LOGIN_RELATIONS_USER` FOREIGN KEY (`USER_NAME`) REFERENCES `user_data` (`USER_NAME`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
