use ass2;
show triggers;
SET SQL_SAFE_UPDATES = 0; 

-- trigger việc insert vào kho sách: nếu không có id của tác giả tồn tại trong kho thì không được insert
DELIMITER $$
CREATE TRIGGER Book_insert BEFORE INSERT ON book 
FOR EACH ROW
BEGIN	
	IF new.bAuthor_id NOT IN (select author_id from author) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
    END IF;
END$$
DELIMITER ;

-- kiểm tra xem sách trong kho có còn đủ không, nếu đủ thì được add vào cart, còn không thì báo lỗi
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
		set new.cart_quanity = new.cart_quanity + new.book_quanity;
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
	 SET new.cart_quanity = ( select cart_quanity from cart where cart_id = new.cart_id and book_id = new.book_id) + new.book_quanity - old.book_quanity;
     SET new.total_price = new.cart_quanity * (select price from book where book_id = new.book_id);
END//
DELIMITER ;	
drop trigger Cart_quanity_update;

-- tính toán lại hàng trong book trước khi update trên cart
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

-- dữ liệu cho việc báo cáo

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

-- PROCEDURE tính trung bình và tổng giá tiền ứng với 1 loại  sản phẩm trong cart

DELIMITER $	
CREATE PROCEDURE revenue_product(
	IN product_id int, 
    OUT total decimal(10,2),
    OUT average decimal(10,2)
)
BEGIN
    DECLARE count int default 0;	
    SET count = (SELECT COUNT(*) FROM cart);
    IF count > 0 THEN 	
		SET total = (SELECT SUM(price * quanity) 
					FROM book WHERE book_id = product_id);
		SET average = (SELECT AVG(price * quanity) 
					FROM book WHERE book_id = product_id);
	ELSE
		SET total = 0;
        SET average = 0;
        SELECT  CONCAT('YOUR PARAMETER ', product_id, 'IS NOT EXISTS!!!') AS 'ERROR';
	END IF;	
END $
DELIMITER ; 	

CALL revenue_product(100000002, @total, @avg);
drop PROCEDURE revenue_product;
SELECT @total, @avg;   

-- --------------------------------------------------------------




