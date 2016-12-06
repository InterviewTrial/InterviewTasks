USE [JGBS]
GO

GO
/****** Object:  StoredProcedure [dbo].[UDP_BulkInstallUser]    Script Date: 11/8/2016 3:07:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UDP_BulkInstallUser]
@XMLDOC2 xml
as
begin
SET NOCOUNT ON; 
create table #table_xml
(
FirstName varchar(50),
LastName varchar(50),
Email varchar(50),
phone VARCHAR(50),
Designation VARCHAR(50),
Status VARCHAR(50),
Notes VARCHAR(50),
PrimeryTradeId int,
SecondoryTradeId VARCHAR(50),
Source VARCHAR(50),
UserType VARCHAR(50),
Email2 VARCHAR(50),
Phone2 VARCHAR(50),
CompanyName VARCHAR(50),
SourceUser VARCHAR(50),
DateSourced VARCHAR(50)
, ActionTaken VARCHAR(2)
)


create table #UploadableData
(
	FirstName varchar(50),
	LastName varchar(50),
	Email varchar(50),
	phone VARCHAR(50),
	Designation VARCHAR(50),
	Status VARCHAR(50),
	Notes VARCHAR(50),
	PrimeryTradeId int,
	SecondoryTradeId VARCHAR(50),
	Source VARCHAR(50),
	UserType VARCHAR(50),
	Email2 VARCHAR(50),
	Phone2 VARCHAR(50),
	CompanyName VARCHAR(50),
	SourceUser VARCHAR(50),
	DateSourced VARCHAR(50),
	ActionTaken VARCHAR(2)
)


declare @rowexistcnt int
insert into #table_xml
	(FirstName,LastName,Email,phone,[Designation],[Status],[Notes],[PrimeryTradeId],[SecondoryTradeId],[Source],[UserType],[Email2],[Phone2],[CompanyName],[SourceUser],[DateSourced] ,ActionTaken)
SELECT
       [Table].[Column].value('(firstname/text()) [1]','VARCHAR(50)') AS FirstName,
       [Table].[Column].value('(lastname/text()) [1]','VARCHAR(50)') AS LastName,
       [Table].[Column].value('(Email/text()) [1]','VARCHAR(50)') AS Email,
	   [Table].[Column].value('(phone/text()) [1]','VARCHAR(50)') AS phone,
	   [Table].[Column].value('(Designation/text()) [1]','VARCHAR(50)') AS Designation,
	   [Table].[Column].value('(status/text()) [1]','VARCHAR(20)') AS status,
	   [Table].[Column].value('(Notes/text()) [1]','VARCHAR(50)') AS Notes,
	   [Table].[Column].value('(PrimeryTradeId/text()) [1]','int') AS PrimeryTradeId,
	   [Table].[Column].value('(SecondoryTradeId/text()) [1]','VARCHAR(50)') AS SecondoryTradeId,
	   [Table].[Column].value('(Source/text()) [1]','VARCHAR(50)') AS Source,
	   [Table].[Column].value('(UserType/text()) [1]','VARCHAR(50)') AS EmaUserType,
	   [Table].[Column].value('(Email2/text()) [1]','VARCHAR(50)') AS Email2,
	   [Table].[Column].value('(Phone2/text()) [1]','VARCHAR(50)') AS Phone2,
	   [Table].[Column].value('(CompanyName/text()) [1]','VARCHAR(50)') AS CompanyName,
	   [Table].[Column].value('(SourceUser/text()) [1]','VARCHAR(50)') AS SourceUser,
	   [Table].[Column].value('(DateSourced/text()) [1]','VARCHAR(50)') AS DateSourced ,
	   'U'
     
      FROM
      @XMLDOC2.nodes('/ArrayOfUser1/user1')AS [Table]([Column])	

	  --select @rowexistcnt = count(*) from tblInstallUsers inner join #table_xml on  tblInstallUsers.Phone =#table_xml.phone or tblInstallUsers.Email = #table_xml.Email 
	  select @rowexistcnt = count(*) from #table_xml where phone Not in
									(select phone from tblInstallUsers where phone != '') or 
									Email Not in(select Email from tblInstallUsers where Email != '')

	  --insert into #UploadableData
			--(FirstName,LastName,Email,phone,Designation,Status,Notes,PrimeryTradeId,SecondoryTradeId,Source,UserType,Email2,Phone2,CompanyName,SourceUser,DateSourced)
	  --select FirstName,LastName,Email,phone,Designation,Status,Notes,PrimeryTradeId,SecondoryTradeId,Source,UserType,Email2,Phone2,CompanyName,SourceUser,DateSourced
	  ----select #table_xml.FirstName,#table_xml.LastName,#table_xml.Email,#table_xml.phone,#table_xml.Designation,#table_xml.Status,#table_xml.Notes,#table_xml.PrimeryTradeId,#table_xml.SecondoryTradeId,#table_xml.Source,#table_xml.UserType,#table_xml.Email2,#table_xml.Phone2,#table_xml.CompanyName,#table_xml.SourceUser,#table_xml.DateSourced 
	  
	  --from #table_xml 
	  --  #table_xml where 
			--	phone IN (select phone from tblInstallUsers where phone != '') or 
			--	Email IN (select Email from tblInstallUsers where Email != '')

		--inner join tblInstallUsers on  #table_xml.phone = tblInstallUsers.Phone  
		--or #table_xml.Email = tblInstallUsers.Email 

if(@rowexistcnt>0)
BEGIN

UPDATE #table_xml 
				SET ActionTaken = 'I'
			where 
				phone NOT IN (select phone from tblInstallUsers where phone != '') or 
				Email NOT IN (select Email from tblInstallUsers where Email != '')

INSERT INTO tblInstallUsers
	  	 ([FristName],[LastName],[Email],[Phone],[Designation],[Status],[Notes],[PrimeryTradeId],[SecondoryTradeId],[Source],[UserType],[Email2],[Phone2],[CompanyName],[SourceUser],[DateSourced])
    select FirstName,LastName,Email,phone,Designation,Status,Notes,PrimeryTradeId,SecondoryTradeId,Source,UserType,Email2,Phone2,CompanyName,SourceUser,DateSourced 
			from #table_xml 
				where phone NOT IN(select phone from tblInstallUsers where phone != '') 
				or 
				Email NOT IN(select Email from tblInstallUsers where Email != '')


		


	  SELECT * FROM #table_xml
  END
   ELSE

	SELECT * FROM #table_xml
	--select * from #UploadableData 
	--inner join #table_xml on  tblInstallUsers.Phone =#table_xml.phone --or tblInstallUsers.Email =user1.Email 
	 
	  return;
END


GO

/****** Object:  StoredProcedure [dbo].[UDP_BulkUpdateInstallUser]    Script Date: 11/8/2016 3:06:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UDP_BulkUpdateInstallUser]
@XMLDOC2 xml
, @UpdatedBy varchar(250)
, @result int out
as
begin
SET NOCOUNT ON; 

set @result =0

create table #table_xml
(
	FirstName varchar(50),
	LastName varchar(50),
	Email varchar(50),
	phone VARCHAR(50),
	Designation VARCHAR(50),
	Status VARCHAR(50),
	Notes VARCHAR(50),
	PrimeryTradeId int,
	SecondoryTradeId VARCHAR(50),
	Source VARCHAR(50),
	UserType VARCHAR(50),
	Email2 VARCHAR(50),
	Phone2 VARCHAR(50),
	CompanyName VARCHAR(50),
	SourceUser VARCHAR(50),
	DateSourced VARCHAR(50)
)

declare @rowexistcnt int
insert into #table_xml(FirstName,LastName,Email,phone,[Designation],[Status],[Notes],[PrimeryTradeId],[SecondoryTradeId],[Source],[UserType],[Email2]
						,[Phone2],[CompanyName],[SourceUser],[DateSourced])
SELECT
       [Table].[Column].value('(firstname/text()) [1]','VARCHAR(50)') AS FirstName,
       [Table].[Column].value('(lastname/text()) [1]','VARCHAR(50)') AS LastName,
       [Table].[Column].value('(Email/text()) [1]','VARCHAR(50)') AS Email,
	   [Table].[Column].value('(phone/text()) [1]','VARCHAR(50)') AS phone,
	   [Table].[Column].value('(Designation/text()) [1]','VARCHAR(50)') AS Designation,
	   [Table].[Column].value('(status/text()) [1]','VARCHAR(20)') AS status,
	   [Table].[Column].value('(Notes/text()) [1]','VARCHAR(50)') AS Notes,
	   [Table].[Column].value('(PrimeryTradeId/text()) [1]','int') AS PrimeryTradeId,
	   [Table].[Column].value('(SecondoryTradeId/text()) [1]','VARCHAR(50)') AS SecondoryTradeId,
	   [Table].[Column].value('(Source/text()) [1]','VARCHAR(50)') AS Source,
	   [Table].[Column].value('(UserType/text()) [1]','VARCHAR(50)') AS EmaUserType,
	   [Table].[Column].value('(Email2/text()) [1]','VARCHAR(50)') AS Email2,
	   [Table].[Column].value('(Phone2/text()) [1]','VARCHAR(50)') AS Phone2,
	   [Table].[Column].value('(CompanyName/text()) [1]','VARCHAR(50)') AS CompanyName,
	   [Table].[Column].value('(SourceUser/text()) [1]','VARCHAR(50)') AS SourceUser,
	   [Table].[Column].value('(DateSourced/text()) [1]','VARCHAR(50)') AS DateSourced
     
      FROM
      @XMLDOC2.nodes('/ArrayOfUser1/user1')AS [Table]([Column])	

	--  select @rowexistcnt = count(*) from tblInstallUsers inner join #table_xml on  tblInstallUsers.Phone =#table_xml.phone or tblInstallUsers.Email = #table_xml.Email 
	
	


	INSERT INTO AuditTrail_UserUpdate ([FirstName],[LastName],[Email],[phone],[Designation],[Status],[Notes],[PrimeryTradeId],[SecondoryTradeId],[Source]
           ,[UserType],[Email2],[Phone2],[CompanyName],[SourceUser],[DateSourced],[UpdateOn],[ActionType] ,[UpdatedByUserLoginID])

	SELECT [FristName]
      ,U.[LastName]
      ,U.[Email]
      ,U.[phone]
      ,U.[Designation]
      ,U.[Status]
      ,U.[Notes]
      ,U.[PrimeryTradeId]
      ,U.[SecondoryTradeId]
      ,U.[Source]
      ,U.[UserType]
      ,U.[Email2]
      ,U.[Phone2]
      ,U.[CompanyName]
      ,U.[SourceUser]
      ,U.[DateSourced]      
	  , GETDATE()
	  ,'Old Record'
	  ,		@UpdatedBy
FROM tblInstallUsers U ,#table_xml

 WHERE 	U.Email = #table_xml.Email
			or  U.Phone = #table_xml.Phone


	UPDATE [dbo].[tblInstallUsers]
   SET [FristName] = #table_xml.FirstName
      ,[LastName] = #table_xml.LastName
      ,[Email] = #table_xml.Email
      ,[Phone] = #table_xml.phone
      ,[Designation] = #table_xml.Designation
      ,[Status] = #table_xml.Status
	  ,[UserType] = #table_xml.UserType
	  ,[Email2] = #table_xml.Email2
	  ,[Phone2] = #table_xml.Phone2
	  ,[CompanyName] = #table_xml.CompanyName
	  ,[SourceUser] = #table_xml.SourceUser
	  ,[DateSourced] = #table_xml.DateSourced
      ,[PrimeryTradeId] = #table_xml.PrimeryTradeId 
      ,[SecondoryTradeId] = #table_xml.SecondoryTradeId
      ,[Source] = #table_xml.Source
      ,[Notes] = #table_xml.Notes

	  FROM #table_xml

	 WHERE 
	 
			tblInstallUsers.Email = #table_xml.Email
			or 
			tblInstallUsers.Phone = #table_xml.Phone

	 set @result =1
 
end

 