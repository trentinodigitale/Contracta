USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_AFLUPDATE_BKP_METABESE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_AFLUPDATE_BKP_METABESE] as
BEGIN
	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Documents' )
		drop table LibAflUpdate_BKP_LIB_Documents

	select * into LibAflUpdate_BKP_LIB_Documents from  LIB_Documents

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_DocumentSections' )
		drop table LibAflUpdate_BKP_LIB_DocumentSections

	select * into LibAflUpdate_BKP_LIB_DocumentSections from  LIB_DocumentSections

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_DocumentProcess' )
		drop table LibAflUpdate_BKP_LIB_DocumentProcess

	select * into LibAflUpdate_BKP_LIB_DocumentProcess  from   LIB_DocumentProcess

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Models' )
		drop table LibAflUpdate_BKP_LIB_Models

	select * into LibAflUpdate_BKP_LIB_Models from  LIB_Models

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_ModelAttributes' )
		drop table LibAflUpdate_BKP_LIB_ModelAttributes

	select * into  LibAflUpdate_BKP_LIB_ModelAttributes from  LIB_ModelAttributes

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_ModelAttributeProperties' )
		drop table LibAflUpdate_BKP_LIB_ModelAttributeProperties

	select * into LibAflUpdate_BKP_LIB_ModelAttributeProperties from  LIB_ModelAttributeProperties

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Dictionary' )
		drop table LibAflUpdate_BKP_LIB_Dictionary

	select * into LibAflUpdate_BKP_LIB_Dictionary from LIB_Dictionary

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Domain' )
		drop table LibAflUpdate_BKP_LIB_Domain

	select * into LibAflUpdate_BKP_LIB_Domain  from  LIB_Domain

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_LIB_DomainValues' )
		drop table LibAflUpdate_LIB_DomainValues

	select * into LibAflUpdate_LIB_DomainValues from  LIB_DomainValues

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Functions' )
		drop table LibAflUpdate_BKP_LIB_Functions

	select * into LibAflUpdate_BKP_LIB_Functions from  LIB_Functions

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_LIB_Multilinguismo' )
		drop table LibAflUpdate_BKP_LIB_Multilinguismo

	select * into  LibAflUpdate_BKP_LIB_Multilinguismo from  LIB_Multilinguismo

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='LibAflUpdate_BKP_Lib_Services' )
		drop table LibAflUpdate_BKP_Lib_Services

	select * into LibAflUpdate_BKP_Lib_Services from  Lib_Services

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='CtlAflUpdate_BKP_CTL_PARAMETRI' )
		drop table CtlAflUpdate_BKP_CTL_PARAMETRI

	select * into CtlAflUpdate_BKP_CTL_PARAMETRI from  CTL_PARAMETRI

	IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='CtlAflUpdate_BKP_CTL_Relations' )
		drop table CtlAflUpdate_BKP_CTL_Relations
	
	select * into CtlAflUpdate_BKP_CTL_Relations from  CTL_Relations
END
GO
