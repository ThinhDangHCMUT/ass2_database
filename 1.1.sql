DELIMITER $$
CREATE PROCEDURE `insert_new_account`(
	Fname		VARCHAR(15)	,
	Lname		    VARCHAR(15)	,
    Acc_id		    CHAR(9),
	Date_of_birth 	DATE,
	Address	       	VARCHAR(30),
	Sex		       	CHAR(1),
	Roles       	CHAR(20),
    Username		VARCHAR(30),
	Passwords	    VARCHAR(20)
)
BEGIN
    if exists (select acc_id from account where acc_id = Acc_id) 
    then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account id already exists in system, try another one'; 
    elseif exists (select username from account where username = Username)
    then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already chosen, try another one';
	else insert into account values (Fname,Acc_id,Lname,STR_TO_DATE(Date_of_birth, '%Y-%m-%d'),Address,Sex,Roles,Username,Passwords);
    end if;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `update_account_name`(
	IN Acc_id 	CHAR(9),
	IN First_name	VARCHAR(15),
    IN Last_name	VARCHAR(15)
)
BEGIN
if exists (select account.acc_id from btl2.account where account.acc_id=Acc_id) 
then UPDATE btl2.account SET fname = First_name,lname=Last_name WHERE (account.acc_id = Acc_id);
else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account id does not exist in system, try again';
end if;
END
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `update_username_or_password`(
	IN Acc_id 	CHAR(9),
    IN current_Username	VARCHAR(30),
    IN current_Password VARCHAR(20),
	IN new_Username	VARCHAR(30),
    IN new_Password VARCHAR(20)
)
BEGIN
	if not exists (select account.acc_id from account where account.acc_id=Acc_id) 
	then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account id not exists, try again ';
	else 
		if exists (select account.username,account.passwords from account 
        where account.acc_id = Acc_id and current_Username = account.username and current_Password= account.passwords)
		then UPDATE account SET account.username = new_Username,account.passwords=new_Password WHERE (account.acc_id=Acc_id);
		else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or password incorrect, try again'; 
		end if;
	end if;
END
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `update_account_id` (
	IN curr_acc_id 	CHAR(9),
    IN new_id char(9),
    IN current_Username	VARCHAR(30),
    IN current_Password VARCHAR(20)
)
BEGIN
	if not exists (select account.acc_id from account where account.acc_id=Acc_id) 
	then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account id not exists, try again ';
	else 
		if exists (select account.username,account.passwords from account 
        where account.acc_id = Acc_id and current_Username = account.username and current_Password= account.passwords)
		then UPDATE account SET account.acc_id=new_id WHERE (account.acc_id = curr_acc_id);
		else SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or password incorrect, try again'; 
		end if;
	end if;
END $$
DELIMITER ;