USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[GetMaxNo]    Script Date: 12-01-2017 AM 10:20:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[GetMaxNo] 
	-- Add the parameters for the stored procedure here
	@colname varchar(200),
    @tblname varchar(200)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	exec( 'SELECT max('+@colname+') as maxno from '+@tblname+'  ')
	
END
