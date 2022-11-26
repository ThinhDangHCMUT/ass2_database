use ass2;

show triggers;
SET SQL_SAFE_UPDATES = 0; 

DELIMITER $$
CREATE TRIGGER Book_quanity BEFORE UPDATE ON book 
FOR EACH ROW
BEGIN	
	IF new.quanity < (select book_quanity from cart where book_id = new.book_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER Book_quanity;

DELIMITER $$
CREATE TRIGGER Cart_total before INSERT ON Cart 
FOR EACH ROW
BEGIN	
	IF new.book_quanity <= (select quanity from book where book_id = new.book_id)  then 
		set new.cart_quanity = new.cart_quanity + new.book_quanity;
        SET new.total_price =  new.book_quanity * (select price from book where book_id = new.book_id);
		update book 
		set quanity = quanity - new.book_quanity
 		where book_id = new.book_id;
	ELSEIF  new.book_quanity > (select quanity from book where book_id = new.book_id) then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
    END IF;
END$$
DELIMITER ;
drop trigger Cart_total;

show triggers;
-- trigger quannity sau moi lan them 1 item
DELIMITER //
CREATE TRIGGER Cart_quanity_update before update ON Cart
FOR EACH ROW
BEGIN
	 SET new.cart_quanity = ( select cart_quanity from cart where cart_id = new.cart_id and book_id = new.book_id) + new.book_quanity - old.book_quanity;
     SET new.total_price = new.cart_quanity * (select price from book where book_id = new.book_id);
END//
DELIMITER ;	
drop trigger Cart_quanity_update;

DELIMITER //
CREATE TRIGGER Book_quanity_update before update ON cart 
FOR EACH ROW 
BEGIN
     update book 
	 set  quanity  = quanity - (new.book_quanity - old.book_quanity) 
     where book_id = new.book_id;
END//
DELIMITER ;	
drop trigger Book_quanity_update;



INSERT INTO Cart VALUES ('a1915140', 0, 0, '1915140' ,100000002,3);
INSERT INTO Cart VALUES ('a1915140', 0, 0, '' ,100000004,6);
INSERT INTO Cart VALUES ('a1915140', 0, 0, '' ,100000001,3);
DELETE FROM `ass2`.`cart` WHERE (`cart_id` = 'a1915140');
INSERT INTO Cart VALUES ('a1914672', 0, 121212, '1914672',100000001, 4);
DELETE FROM `ass2`.`cart` WHERE (`cart_id` = 'a1914672');
SELECT * FROM ass2.cart;		
SELECT * FROM ass2.book;
-- customer nhap vao mot so luong sach nao do

UPDATE cart
set book_quanity = 10
where cart_id = 'a1915140' and book_id = 100000002;

-- customer press increase button
UPDATE cart
set book_quanity = book_quanity - 1 
where cart_id = 'a1914672' and book_id = '100000001';

UPDATE cart
set book_quanity = book_quanity + 1 
where cart_id = 'a1915140' and book_id = '100000002';

use ass2;



