use ass2;

CREATE TABLE Account 
(	acc_name		VARCHAR(15)	NOT NULL,
	acc_id		    CHAR(9)  PRIMARY KEY,			
	lname		    VARCHAR(15)	NOT NULL,
	date_of_birth   DATE,
	address	        VARCHAR(30),
	sex		        CHAR(1),
	roles       	CHAR(20)  NOT NULL,
	passwords	    VARCHAR(20),
	username		VARCHAR(30)  NOT NULL
-- --	CONSTRAINT 	fk_emp_superssn	FOREIGN KEY (superssn) 
-- --				REFERENCES Employee(ssn)
);


CREATE TABLE Supplier
(
    s_id          char(9) PRIMARY KEY,
    s_rating      char(1),
    income        decimal(10,2),
    CONSTRAINT FK_Supplier FOREIGN KEY (s_id) REFERENCES Account(acc_id)
);

CREATE TABLE Customer 
(
    c_id        char(9) PRIMARY KEY,
    CONSTRAINT FK_Customer FOREIGN KEY (c_id)
    REFERENCES Account(acc_id)
);

CREATE TABLE Admin 
(   
    a_id        char(9) PRIMARY KEY,
    CONSTRAINT FK_Admin FOREIGN KEY (a_id)
    REFERENCES Account(acc_id)
);

CREATE TABLE Publisher 
(
    name       varchar(20) PRIMARY KEY,
    address    varchar(30)
);

CREATE TABLE Author 
(
    author_id  char(9) PRIMARY KEY
);

ALTER TABLE AUTHOR  add bName varchar(20);

CREATE TABLE Category 
(
    cat_id    char(9) PRIMARY KEY,
    cat_name  varchar(20)
);



CREATE TABLE Book
(
    book_name       varchar(20) NOT NULL,
    book_id         CHAR(9) PRIMARY KEY,
    edition         char(9) ,
    quanity         INT NOT NULL,
    bAuthor_id      char(9),
    bName           varchar(20),
    bCat_id         char(9),
    price           DECIMAL(10,2) NOT NULL
--    CONSTRAINT FK_author_id FOREIGN KEY (bAuthor_id)
--    REFERENCES Author(author_id),
--    CONSTRAINT FK_cat_id FOREIGN KEY (bCat_id)
--    REFERENCES Category(cat_id),
--    CONSTRAINT FK_pub_name FOREIGN KEY (bName)
--    REFERENCES Publisher(name)
);
ALTER TABLE BOOK DROP bName;

-- ALTER TABLE BOOK NO CHECK CONSTRAINT ALL;
DROP TABLE BOOK;

CREATE TABLE CART (
    cart_id CHAR(9) PRIMARY KEY,
    quanity INT NOT NULL,
    total_price INT NOT NULL,
    customer_id CHAR(9)
);

ALTER TABLE CART
ADD CONSTRAINT fk_cus FOREIGN KEY (customer_id) REFERENCES customer(c_id);

ALTER TABLE CART
DROP CONSTRAINT fk_cus;

ALTER TABLE CART
ADD CONSTRAINT FK_book_ids FOREIGN KEY (book_id) REFERENCES Book(book_id);

ALTER TABLE CART
DROP CONSTRAINT FK_book_ids;

CREATE TABLE Include
(
    i_book_id char(9) PRIMARY KEY ,
    i_cart_id char(9) ,
    CONSTRAINT FK_book_id FOREIGN KEY (i_book_id)
    REFERENCES Book(Book_id) ON DELETE CASCADE	,
    CONSTRAINT FK_cart_id FOREIGN KEY (i_cart_id)
    REFERENCES Cart(cart_id) ON DELETE CASCADE
);
alter table include
drop constraint FK_cart_id;


CREATE TABLE FEEDBACK
(
    f_book_id   char(9) ,
    f_id        char(9) PRIMARY KEY,
    b_rating    char(1),
    feedback_cmt    varchar(30),
    CONSTRAINT FK_f_book_id FOREIGN KEY (f_book_id)
    REFERENCES Book(Book_id) ON DELETE CASCADE,
    CONSTRAINT FK_f_id FOREIGN KEY (f_id)
    REFERENCES Customer(c_id) ON DELETE CASCADE
);

CREATE TABLE NAME_tb
(
    n_author_id  char(9) PRIMARY KEY,
    name_tb       varchar(30),
    CONSTRAINT FK_author_id FOREIGN KEY (n_author_id)
    REFERENCES Author(author_id) ON DELETE CASCADE
);

CREATE TABLE PROVIDED_BY
(
    p_book_id   char(9) primary key,
    voucher     varchar(9),
    CONSTRAINT FK_p_book_id FOREIGN KEY (p_book_id)
    REFERENCES Book(book_id) ON DELETE CASCADE
);

CREATE TABLE MEMBER_CARD
(
    member_id      char(9) primary key, 
    discount       varchar(10),
    ranks          varchar(5),
    m_customer_id  char(9),
    CONSTRAINT FK_m_customer_id FOREIGN KEY (m_customer_id)
    REFERENCES Customer(c_id) ON DELETE CASCADE
);

CREATE TABLE D_DISCOUNT
(   
    d_member_id   char(9) primary key,
    d_id           char(9),      
    discount    varchar(10),
    CONSTRAINT FK_d_member_id FOREIGN KEY (d_member_id)
    REFERENCES Member_card(member_id) ON DELETE CASCADE,
    CONSTRAINT FK_d_id FOREIGN KEY (d_id)
    REFERENCES Customer(c_id) ON DELETE CASCADE
);


INSERT INTO book VALUES ('BOOK A',100000001,2,5,3001,'2001',23000);
INSERT INTO book VALUES ('BOOK B',100000002,3,5,3002,'2001',25000);
INSERT INTO book VALUES ('BOOK C',100000003,2,5,3003,'2003',50000);
INSERT INTO book VALUES ('BOOK D',100000004,2,5,3004,'2002',70000);
INSERT INTO book VALUES ('BOOK E',100000006,2,5,3001,'2002',100000);
INSERT INTO book VALUES ('BOOK F',100000010,2,5,3002,'2002',80000);
INSERT INTO book VALUES ('BOOK G',100000007,3,50,3003,'2002',80000);

INSERT INTO author VALUE ('3001', 'TRAN DANG KHOA');
INSERT INTO author VALUE ('3002', 'NGUYEN NGOC ANH');
INSERT INTO author VALUE ('3003', 'TRANG HA');
INSERT INTO author VALUE ('3004', 'HA VU');



INSERT INTO account VALUES ('thinhdang','2014591','Thinh', STR_TO_DATE('2002-11-14', '%Y-%m-%d') ,'Go Cong, Tien Giang','M', 'Admin', '123456');
INSERT INTO account VALUES ('toanvo','2010709','Toan', STR_TO_DATE('2002-06-14', '%Y-%m-%d') ,'Quan 2, Ho Chi Minh','M', 'Provider', '123456');
INSERT INTO account VALUES ('phutruong','1914672','Phu', STR_TO_DATE('2001-02-14', '%Y-%m-%d') ,'Tan An, Long An','M', 'Customer', '123456');
INSERT INTO account VALUES ('thanhle','1915140','Thanh', STR_TO_DATE('2001-03-14', '%Y-%m-%d') ,'Long Thanh, Dong Nai','M', 'Customer', '123456');
INSERT INTO account VALUES ('tuonglau','2015007','Tuong', STR_TO_DATE('2001-07-14', '%Y-%m-%d') ,'Long Thanh, Dong Nai','M', 'Provider', '123456');

INSERT INTO admin VALUES ('2014591', '8000000');

INSERT INTO Supplier VALUE ('2010709', '5', '7000000');
INSERT INTO Supplier VALUE ('2015007', '5', '10000000');


INSERT INTO Customer VALUE ('1915140');
INSERT INTO Customer VALUE ('1914672');



use ass2;

show triggers;


DELIMITER $$
CREATE TRIGGER Book_quanity BEFORE UPDATE ON book 
FOR EACH ROW
BEGIN	
	IF new.quanity < (select book_quanity from cart where book_id = new.book_id) THEN
    SET new.quanity = (select quanity from book where book_id = new.book_id);
    END IF;
END$$
DELIMITER ;

DROP TRIGGER Book_quanity;

DELIMITER $$
CREATE TRIGGER Cart_total before INSERT ON Cart 
FOR EACH ROW
BEGIN	
	-- IF new.book_quanity <= (select quanity from book where book_id = new.book_id)  then 
		set new.cart_quanity = new.cart_quanity + new.book_quanity;
		update book 
		set quanity = quanity - new.book_quanity
		where book_id = new.book_id;
	-- ELSEIF  new.book_quanity > (select quanity from book where book_id = new.book_id) then 
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
--     END IF;
END$$
DELIMITER ;
drop trigger Cart_total;

show triggers;
-- trigger quannity sau moi lan them 1 item
DELIMITER //
CREATE TRIGGER Cart_quanity_update before update ON Cart
FOR EACH ROW
BEGIN
	 SET new.cart_quanity = old.cart_quanity + new.book_quanity - old.book_quanity;
     update book 
	 set quanity = quanity - 1
	 where book_id = ( select book_id from cart where book_id = new.book_id);
END//
DELIMITER ;
drop trigger Cart_quanity_update;


drop trigger Book_quanity_update;

INSERT INTO Cart VALUES ('a1915140', 0, 222222, '1915140',100000001,3);
DELETE FROM `ass2`.`cart` WHERE (`cart_id` = 'a1915140');
INSERT INTO Cart VALUES ('a1914672', 0, 121212, '1914672',100000001, 4);
DELETE FROM `ass2`.`cart` WHERE (`cart_id` = 'a1914672');
SELECT * FROM ass2.cart;
SELECT * FROM ass2.book;





SELECT book_name, bName 
from author 
join book on author_id = bAuthor_id;

use ass2;
SELECT * FROM 
book join author on bAuthor_id = author_id;


 

alter user 'root'@'localhost' identified WITH mysql_native_password by 'D@ngthinh1402'




