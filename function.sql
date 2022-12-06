use ass2;
DELIMITER $$

CREATE FUNCTION CustomerLevel(
	credit DECIMAL(10)
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE customerLevel VARCHAR(20);

    IF credit = 1 THEN
		SET customerLevel = "Normal";
    ELSEIF (credit >= 2 AND 
			credit <= 4) THEN
        SET customerLevel = "amatuer";
    ELSEIF credit >=5 THEN
        SET customerLevel = "expert";
    END IF;
	RETURN (customerLevel);
END$$
DELIMITER ;

-- function1: calculate total cost 
DELIMITER $$

CREATE FUNCTION totalcost(
	quanity Decimal(10),unit DECIMAL(10)
) 
RETURNS decimal(10)
DETERMINISTIC
BEGIN
    DECLARE total Decimal(10);
    set total = quanity * unit;
	RETURN (total);
END$$
DELIMITER ;


-- function 2: give discount
DELIMITER $$

CREATE FUNCTION discount(
	quanity Decimal(10),cost DECIMAL(10)
) 
RETURNS decimal(10)
DETERMINISTIC
BEGIN
    DECLARE discountlv decimal(10,2);

    IF quanity < 5 THEN
		SET discountlv = 0;
    ELSEIF (quanity >= 5 AND 
			quanity <= 10) THEN
        SET discountlv = 5/100;
    ELSEIF quanity >10 THEN
        SET discountlv = 10/100;
    END IF;
	RETURN cost = cost - cost*discountlv;
END$$
DELIMITER ;


-- function 3: member discount (use funct 2 or 3 only)
DELIMITER $$
CREATE FUNCTION mem_discount(
	ranks varchar(10),cost int
) 
RETURNS int
DETERMINISTIC
BEGIN
    DECLARE discountlv decimal(10,2);

    IF ranks = 'new' THEN
		SET discountlv = 0;
    ELSEIF ranks = 'bronze' THEN
        SET discountlv = 5/100;
    ELSEIF ranks = 'silver' THEN
        SET discountlv = 10/100;
	ELSEIF ranks = 'gold' THEN
	SET discountlv = 15/100;
    END IF;
	RETURN cost = cost - cost*discountlv;
END$$
DELIMITER ;

-- funciton 4: update member card rank
DELIMITER $$
CREATE FUNCTION update_rank (
	quanity int , ranks varchar(5)
) 
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    if quanity > 10 then set ranks= 'new';
    elseif (quanity >=10 and quanity <20) then set ranks = 'bronze';
    elseif (quanity >=20 and quanity <50) then set ranks ='silver';
    elseif (quanity >=50) then set ranks = 'gold';
    END IF;
    return ranks;
END$$
DELIMITER ;

select * from cart;
select book_name, CustomerLevel(book_quanity) from cart a join book b on a.book_id = b.book_id;

select 
bAuthor_id,
sum(quanity) as Qty,
sum(totalcost(quanity,price)) as Price,
discount(sum(quanity),sum(totalcost(quanity,price))) as 'Net Price',
bname as Name 
from ass2.book 
join 
group by a;


-- check login luc goi database thi se goi cai ham nay de phan quyen
DELIMITER $$
CREATE FUNCTION login_check (
	username varchar(30) , passwords varchar(20)
) 
RETURNS boolean
BEGIN
	declare flag boolean;
    if passwords = (select passwords from account where acc_name = username) then set flag = true;
    else set flag = false;
    end if;
    return (flag);
END$$
DELIMITER ;
select login_check('phutruong11', 1234) as flag;

-- 1/ procedure input là book_id = 100000010. In ra acc_name, lname, address, book_name người mà 
-- có lượt mua book_id trên nhiều nhất 
-- 2/ 


-- TEST FUNCTION
-- tạo view tính tổng số sachs và tổng tiền theo từng customer_id
create or replace view f as select customer_id,sum(book_quanity) as quanity, sum(total_price) as total 
from cart group by customer_id;

select * from f;
-- tạo view show ranks ứng với từng customer_id
create or replace view cus_rank as select update_rank(f.quanity,'') as ranks, customer_id, total  from f;

select * from cus_rank;
-- ứng với từng rank thì sẽ có discount tương ứng
select mem_discount(ranks,total), total, ranks from cus_rank group by customer_id;


  
