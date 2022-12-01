use btl2;
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
	quantity Decimal(10),unit DECIMAL(10)
) 
RETURNS decimal(10)
DETERMINISTIC
BEGIN
    DECLARE total Decimal(10);
    set total = quantity * unit;
	RETURN (total);
END$$
DELIMITER ;


-- function 2: give discount
DELIMITER $$

CREATE FUNCTION discount(
	quantity Decimal(10),cost DECIMAL(10)
) 
RETURNS decimal(10)
DETERMINISTIC
BEGIN
    DECLARE discountlv decimal(10,2);

    IF quantity < 5 THEN
		SET discountlv = 0;
    ELSEIF (quantity >= 5 AND 
			quantity <= 10) THEN
        SET discountlv = 5/100;
    ELSEIF quantity >10 THEN
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
	quantity int , ranks varchar(5)
) 
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    if quantity > 10 then set ranks= 'new';
    elseif (quantity >=10 and quantity <20) then set ranks = 'bronze';
    elseif (quantity >=20 and quantity <50) then set ranks ='silver';
    elseif (quantity >=50) then set ranks = 'gold';
    END IF;
    return ranks;
END$$
DELIMITER ;

select * from book;
select bName,CustomerLevel(quantity) from Book;
select 
bAuthor_id,
sum(quantity) as Qty,
sum(totalcost(quantity,price)) as Price,
discount(sum(quantity),sum(totalcost(quantity,price))) as 'Net Price',
Bname as Name 
from btl2.Book
group by Bname;