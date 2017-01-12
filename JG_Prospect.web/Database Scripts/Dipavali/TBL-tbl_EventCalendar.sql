USE [JGBS_Interview]
GO

/****** Object:  Table [dbo].[tbl_EventCalendar]    Script Date: 12-01-2017 PM 06:26:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_EventCalendar](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CalendarName] [varchar](400) NULL,
	[InsertionDate] [datetime] NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_tbl_EventCalendar] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


