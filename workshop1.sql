use GSSWEB
go


/*01*/----------------------------------------------------------------
select KEEPER_ID,
	   USER_CNAME as CName,
	   USER_ENAME as EName,
	   YEAR(LEND_DATE) as BorrowYear,
	   COUNT(YEAR(LEND_DATE)) as BorrowCnt
from BOOK_LEND_RECORD,
	 MEMBER_M
where KEEPER_ID=USER_ID
group by KEEPER_ID,
		 USER_CNAME,
		 USER_ENAME,
		 YEAR(LEND_DATE)
order by KEEPER_ID

/*02*/-------------------------------------------------------------
select top 5 Rec.BOOK_ID,BOOK_NAME,
	   count(Rec.BOOK_ID) as [QTY]
from BOOK_LEND_RECORD as Rec,
	 BOOK_DATA
where Rec.BOOK_ID = BOOK_DATA.BOOK_ID
group by Rec.BOOK_ID,BOOK_NAME
order by [QTY] desc

/*03*/----------------------------------------------------------

;with [2019LendRecord]
as (
	select MONTH(LEND_DATE) as [2019 month], count(MONTH(LEND_DATE)) as Cnt
	from BOOK_LEND_RECORD
	where year(LEND_DATE) = '2019'
	group by MONTH(LEND_DATE)
   )
select case 
		when [2019 month] >= 1 and [2019 month] <= 3 then '2019/01~2019/03'
		when [2019 month] >= 4 and [2019 month] <= 6 then '2019/04~2019/06'
		when [2019 month] >= 7 and [2019 month] <= 9 then '2019/07~2019/09'
		when [2019 month] >= 10 and [2019 month] <= 12 then '2019/10~2019/12'
	   end as [Quarter],
	   sum(Cnt) as Cnt
from [2019LendRecord]
group by case 
			when [2019 month] >= 1 and [2019 month] <= 3 then '2019/01~2019/03'
			when [2019 month] >= 4 and [2019 month] <= 6 then '2019/04~2019/06'
			when [2019 month] >= 7 and [2019 month] <= 9 then '2019/07~2019/09'
			when [2019 month] >= 10 and [2019 month] <= 12 then '2019/10~2019/12'
	     end


/*04*/--------------------------------------------------------
;with ClassRecord 
as(
	select BOOK_CLASS_NAME as BookClass,
		   Rec.BOOK_ID as BookId,
		   BOOK_NAME as BookName,
		   count(BOOK_NAME) as Cnt
	from BOOK_LEND_RECORD as Rec
		 inner join BOOK_DATA as D on D.BOOK_ID=Rec.BOOK_ID
		 inner join BOOK_CLASS as C on C.BOOK_CLASS_ID = D.BOOK_CLASS_ID 
	group by BOOK_CLASS_NAME,
			 Rec.BOOK_ID,
			 BOOK_NAME
)
select *
from (select ROW_NUMBER() over (partition by BookClass order by Cnt desc,BookId) as seq , *
	  from ClassRecord
	 ) as a
where a.seq <= 3
order by BookClass


/*5*/---------------------------------------------------------------------

;with Year_Lend_Record 
as(
	select year(LEND_DATE) as [Year], 
		   D.BOOK_CLASS_ID as ClassId ,
		   BOOK_CLASS_NAME as ClassName,
		   count(year(LEND_DATE)) as cnt
	from BOOK_LEND_RECORD as Rec
		 inner join BOOK_DATA as D on D.BOOK_ID=Rec.BOOK_ID
		 inner join BOOK_CLASS as C on C.BOOK_CLASS_ID = D.BOOK_CLASS_ID 
	group by year(LEND_DATE),D.BOOK_CLASS_ID,BOOK_CLASS_NAME
)
select ClassId, 
	   ClassName,
	   sum(case  when [Year]=2016 then cnt else 0 end) as [CNT2016],
	   sum(case  when [Year]=2017 then cnt else 0 end) as [CNT2017],
	   sum(case  when [Year]=2018 then cnt else 0 end) as [CNT2018],
	   sum(case  when [Year]=2019 then cnt else 0 end) as [CNT2019]
from Year_Lend_Record 
group by ClassId, ClassName
order by ClassId

/*06*/-----------------------------------------------------

;with Year_Lend_Record 
as(
	select Rec.BOOK_ID as BookId,
		   year(LEND_DATE) as [Year], 
		   D.BOOK_CLASS_ID as ClassId ,
		   BOOK_CLASS_NAME as ClassName
	from BOOK_LEND_RECORD as Rec
		 inner join BOOK_DATA as D on D.BOOK_ID=Rec.BOOK_ID
		 inner join BOOK_CLASS as C on C.BOOK_CLASS_ID = D.BOOK_CLASS_ID 
)
select ClassId, ClassName, 
	   [2016] as [CNT2016], 
	   [2017] as [CNT2017], 
	   [2018] as [CNT2018], 
	   [2019] as [CNT2019]
from Year_Lend_Record
pivot( count(BookId) for [Year] in ([2016], [2017], [2018], [2019])
	 ) as pivot1
order by ClassId


/*07*/--------------------------------------------------------
create view LendDetail
as
select Rec.BOOK_ID as [書本ID],
	   convert(varchar(10),BOOK_BOUGHT_DATE,111) as [購書日期],
	   convert(varchar(10),LEND_DATE,111) as [借閱日期],
	   (Class.BOOK_CLASS_ID +'-'+ BOOK_CLASS_NAME) as [書籍類別],
	   (KEEPER_ID + '-' + USER_CNAME +'('+USER_ENAME+')') as [借閱人],
	   (BOOK_STATUS + '-' +CODE_NAME) as [狀態],--BOOK_AMOUNT
	   (BOOK_AMOUNT) as [購書金額]
from BOOK_LEND_RECORD as Rec
	 inner join BOOK_DATA as D on D.BOOK_ID=Rec.BOOK_ID
	 inner join BOOK_CLASS as Class on Class.BOOK_CLASS_ID = D.BOOK_CLASS_ID 
	 inner join BOOK_CODE as Code on Code.CODE_ID = D.BOOK_STATUS
	 inner join MEMBER_M as M on M.USER_ID = Rec.KEEPER_ID
where USER_CNAME = '李四' 

select * from LendDetail order by [購書金額] desc
--drop view LendDetail

/*08*/--------------------------------------------------------

insert into BOOK_LEND_RECORD
	(BOOK_ID,KEEPER_ID,LEND_DATE)
values('2004','0002','2019-01-02')

update BOOK_LEND_RECORD
set LEND_DATE = '2019/01/02'
where KEEPER_ID='0002'
	
--select * from BOOK_LEND_RECORD

select * from LendDetail order by [購書金額] desc


/*09*/------------------------------------------------------------------

delete from BOOK_LEND_RECORD where BOOK_ID = '2004' and KEEPER_ID = '0002'

select * from LendDetail order by [購書金額] desc

