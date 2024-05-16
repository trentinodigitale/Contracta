USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DropTempTables]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[DropTempTables]
AS

DECLARE @strDrop              VARCHAR(8000)

SET @strDrop = '
if exists (select * from sysobjects where name = ''TempMPIF'' and xtype = ''u'')
 drop table TempMPIF
if exists (select * from sysobjects where name = ''TempAct'' and xtype = ''u'')
 drop table TempAct
if exists (select * from sysobjects where name = ''TempDF'' and xtype = ''u'')
drop table TempDF
if exists (select * from sysobjects where name = ''TempTid'' and xtype = ''u'')
drop table TempTid
if exists (select * from sysobjects where name = ''TempTdr'' and xtype = ''u'')
drop table TempTdr
if exists (select * from sysobjects where name = ''TempAp'' and xtype = ''u'')
drop table TempAp
if exists (select * from sysobjects where name = ''TempApAt'' and xtype = ''u'')
drop table TempApAt
if exists (select * from sysobjects where name = ''TempCA'' and xtype = ''u'')
drop table TempCA
if exists (select * from sysobjects where name = ''TempCT'' and xtype = ''u'')
drop table TempCT
if exists (select * from sysobjects where name = ''TempDoc'' and xtype = ''u'')
drop table TempDoc
if exists (select * from sysobjects where name = ''TempDzt'' and xtype = ''u'')
drop table TempDzt
if exists (select * from sysobjects where name = ''TempFNZU'' and xtype = ''u'')
drop table TempFNZU
if exists (select * from sysobjects where name = ''TempFT'' and xtype = ''u'')
drop table TempFT
if exists (select * from sysobjects where name = ''TempFnc'' and xtype = ''u'')
drop table TempFnc
if exists (select * from sysobjects where name = ''TempFncGrp'' and xtype = ''u'')
drop table TempFncGrp
if exists (select * from sysobjects where name = ''TempMF'' and xtype = ''u'')
drop table TempMF
if exists (select * from sysobjects where name = ''TempMPAC'' and xtype = ''u'')
drop table TempMPAC
if exists (select * from sysobjects where name = ''TempMPC'' and xtype = ''u'')
drop table TempMPC
if exists (select * from sysobjects where name = ''TempMPDoc'' and xtype = ''u'')
drop table TempMPDoc
if exists (select * from sysobjects where name = ''TempMPFC'' and xtype = ''u'')
drop table TempMPFC
if exists (select * from sysobjects where name = ''TempMPG'' and xtype = ''u'')
drop table TempMPG
if exists (select * from sysobjects where name = ''TempMPMA'' and xtype = ''u'')
drop table TempMPMA
if exists (select * from sysobjects where name = ''TempMpm'' and xtype = ''u'')
drop table TempMpm
if exists (select * from sysobjects where name = ''TempPA'' and xtype = ''u'')
drop table TempPA
if exists (select * from sysobjects where name = ''TempPF'' and xtype = ''u'')
drop table TempPF
if exists (select * from sysobjects where name = ''TempPRC'' and xtype = ''u'')
drop table TempPRC
if exists (select * from sysobjects where name = ''TempPRCA'' and xtype = ''u'')
drop table TempPRCA
if exists (select * from sysobjects where name = ''TempRD'' and xtype = ''u'')
drop table TempRD
if exists (select * from sysobjects where name = ''TempTP'' and xtype = ''u'')
drop table TempTP
if exists (select * from sysobjects where name = ''TempMlng'' and xtype = ''u'')
drop table TempMlng'

EXEC (@strDrop)

GO
