
-- insert cart : nho fix lai cho nay, no con bi loi
delimiter $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_cart`(
    Quantity INT,
    Book_id CHAR(9),
    Customer_id CHAR(9)
)
BEGIN
declare cost decimal(10,2);
if exists 
(select book.book_id from book where book.book_id=Book_id)
then select Book.price as price into cost from book where book.book_id = Book_id;
	IF  Quantity > (select quantity from book where book.book_id = Book_id) then 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can not update';
    else
		if exists (select book_id,customer_id from cart where cart.book_id=Book_id and cart.customer_id=Customer_id)
		then 
			Update cart
			set cart.book_quantity = cart.book_quantity + Quantity , 
			cart.total_price=cart.total_price+totalcost(cost,Quantity)
			where cart.book_id=Book_id and cart.customer_id=Customer_id;
            update book 
		set quantity = quantity - Quantity
		where book.book_id = Book_id;
		else 
        update book 
		set quantity = quantity - Quantity
		where book.book_id = Book_id;
			INSERT INTO Cart(book_id,book_quantity,total_price,customer_id) VALUES (Book_id,Quantity,totalcost(cost,Quantity),Customer_id);
		end if;
    end if;
else 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Your book you want to add was out of stock';
end if;
END $$
delimiter ;

-- procedure paying de xuat ra  so tien cua khach hang, rank, so luong xep theo tung customer_id
delimiter $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Paying`()
BEGIN
select 
customer_id,
sum(book_quantity) as Quantity,
sum(total_price) as Price,
discount(sum(book_quantity),sum(total_price)) as 'Net Price',
update_rank(sum(book_quantity),'') as 'Rank'
from cart
group by customer_id;
END $$
delimiter ;

-- sap xep income cua tung loai sach theo category
delimiter $$
CREATE PROCEDURE `Income for each category`()
BEGIN
select 
cat_id,
cat_name,
count(quantity) as Qty,
sum(totalcost(quantity,price)) as Income
from book
join category on cat_id=bCat_id
group by cat_id
order by qty asc;
END $$
delimiter ;


-- sap xep income cua tung loai sach theo tac gia
delimiter $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Income for each author`()
BEGIN
select 
bAuthor_id,
sum(quantity) as Qty,
sum(totalcost(quantity,price)) as Income,
author_name as Author 
from book
join author on author_id=bAuthor_id
group by bAuthor_id
order by Income desc;
END $$
delimiter ;