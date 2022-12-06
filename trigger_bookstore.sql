use ass2;
show triggers;
SET SQL_SAFE_UPDATES = 0; 

-- trigger việc insert vào kho sách: nếu không có id của tác giả tồn tại trong kho thì không được insert
DELIMITER $$
CREATE TRIGGER Book_insert BEFORE INSERT ON book 
FOR EACH ROW
BEGIN	
	IF new.bAuthor_id NOT IN (select author_id from author) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update, there is no author in stock';
    END IF;
END$$
DELIMITER ;

SELECT * FROM author;
INSERT INTO book VALUES ('BOOK A',100000010,2,5,3010,'2001',23000,'2015007');


-- kiểm tra xem sách trong kho có còn đủ không, nếu đủ thì được add vào cart, còn không thì báo lỗi
DELIMITER $$
CREATE TRIGGER Book_quanity BEFORE UPDATE ON book 
FOR EACH ROW
BEGIN	
	IF new.quanity < (select book_quanity from cart where book_id = new.book_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not insert';
    END IF;
END$$
DELIMITER ;
DROP TRIGGER Book_quanity;

-- CART TOTAL
-- tính toán tổng sản phẩm có trong cart trước khi update và cập nhật lại số lượng còn lại trong kho 
-- sau khi thêm vào cart
-- kiểm tra nếu số lượng sách đặt quá số lượng sách trong kho thì không cho phép đặt
-- kiểm tra xem sách được đặt có năm trong kho hay không, nếu ko thì thông báo
DELIMITER $$
CREATE TRIGGER Cart_total before INSERT ON Cart 
FOR EACH ROW
BEGIN	
	IF new.book_quanity <= (select quanity from book where book_id = new.book_id)  then 
        SET new.total_price =  new.book_quanity * (select price from book where book_id = new.book_id);
		update book 
		set quanity = quanity - new.book_quanity
 		where book_id = new.book_id;
	ELSEIF  new.book_quanity > (select quanity from book where book_id = new.book_id) then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
	ELSEIF new.book_id not in (select book_id from book) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Your book you want to add was out of stock';
    END IF;
END$$
DELIMITER ;
drop trigger Cart_total;
show triggers;

-- trigger tính toán lại số quantity sau khi update số lượng hàng trong cart
-- tính lại tổng giá tiền ứng với mỗi sản phẩm 
DELIMITER //
CREATE TRIGGER Cart_quanity_update before update ON Cart
FOR EACH ROW
BEGIN
	 SET new.book_quanity = ( select book_quanity from cart where cart_id = new.cart_id and book_id = new.book_id) + new.book_quanity - old.book_quanity;
     SET new.total_price = new.book_quanity * (select price from book where book_id = new.book_id);
	 update book 
	 set  quanity  = quanity - (new.book_quanity - old.book_quanity) 
     where book_id = new.book_id;
END//
DELIMITER ;	
drop trigger Cart_quanity_update;




DELIMITER //
CREATE TRIGGER Cart_after_update after update ON Cart
FOR EACH ROW
BEGIN
	 IF new.book_quanity = 0 then 
     DELETE FROM CART WHERE cart_id = new.cart_id;
     end if;
END//
DELIMITER ;	


-- update lại số lượng sách trong kho sau khi xóa cart
DELIMITER //
CREATE TRIGGER Book_update_after_delete after delete ON cart 
FOR EACH ROW 
BEGIN
     update book 
	 set  quanity  = quanity + old.book_quanity
     where book_id = old.book_id;
END//
DELIMITER ;	
drop trigger Book_update_after_delete;

-- dữ liệu cho việc báo cáo
DELETE FROM `ass2`.`cart` WHERE (`cart_id` = '0');
INSERT INTO Cart VALUES ('0',  null, '1914672',100000001, 4);
INSERT INTO Cart VALUES ('1',  null, '1914672',100000002, 60);
INSERT INTO Cart VALUES ('2',  null, '1914672',100000001, 3);
INSERT INTO Cart VALUES ('4',  null, '2014002',100000004, 3);
INSERT INTO Cart VALUES ('5',  null, '1915140',100000006, 3);
INSERT INTO Cart VALUES ('5',  null, '1915140',100000006, 3);
INSERT INTO Cart VALUES ('6',  null, '1915140',100000010, 3);
INSERT INTO Cart VALUES ('7',  null, '2014002',100000010, 10);
DELETE FROM `ass2`.`cart` WHERE (`customer_id` = 1914672 );
SELECT * FROM ass2.cart;		
SELECT * FROM ass2.book;




-- customer nhap vao mot so luong sach nao do

UPDATE cart
set book_quanity = 10
where book_id = 100000001 and cart_id = '2' and customer_id = '1914672';

-- customer press increase button
UPDATE cart
set book_quanity = book_quanity - 3 
where cart_id = '0' and book_id = '100000001';

UPDATE cart
set book_quanity = book_quanity + 1 
where cart_id = '0' and book_id = '100000001';

-- --------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE add_user_id (
	acc_id		    CHAR(9) , 
    roles 			CHAR(20)
)
BEGIN
  INSERT INTO ACCOUNT VALUES (acc_id,)
	IF account.roles = 'Admin' THEN
		insert into admin.a_id values(account.acc_id);
	ELSEIF account.roles='Customer' then
		insert into customer.c_id  values (account.acc_id);
	ELSEIF account.roles='Provide' then
		insert into supplier.s_id values (account.acc_id);
	END IF;
END$$
DELIMITER ;



