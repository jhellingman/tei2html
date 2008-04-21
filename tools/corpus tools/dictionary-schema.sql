if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scannos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scannos]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Dyads]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Dyads]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NewWords]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[NewWords]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OldWords]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[OldWords]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Words]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Words]
GO

CREATE TABLE [dbo].[Dyads] (
	[first] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL ,
	[second] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL ,
	[count] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[NewWords] (
	[word] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[OldWords] (
	[word] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Words] (
	[word] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL ,
	[wordcount] [int] NULL ,
	[documentcount] [int] NULL ,
	[modernword] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
) ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROC scannos @a char(4), @b char(4) 
AS 
select w1.word, w1.wordcount, w2.word, w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, @a, @b) = replace(w1.word, @a, @b) and
		w1.word <> w2.word
	order by w1.wordcount DESC

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

