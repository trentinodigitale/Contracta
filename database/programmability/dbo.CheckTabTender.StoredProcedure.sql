USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CheckTabTender]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Controllo stato tab tender 
Data:  3/4/2003
*/
CREATE PROCEDURE [dbo].[CheckTabTender] (@iIdTender INT, @iTrStatus TINYINT,@iTab TINYINT,@iIdMsg INT, @iRetStatus TINYINT  OUTPUT)
AS
SET NOCOUNT ON
DECLARE @iCount INT
DECLARE @iIfZero VARCHAR(1)
SET @iRetStatus = 2
IF @iIdMsg=-1
   BEGIN
	SELECT @iCount=COUNT(distinct substring(trOpenTab,@iTab,1) ) 
	  FROM TenderReply
	 WHERE IdTender=@iIdTender and trStatus=@iTrStatus
	IF @iCount=1
	   BEGIN
		SELECT TOP 1 @iIfZero=substring(trOpenTab,@iTab,1)  
		  FROM TenderReply
		 WHERE IdTender=@iIdTender and trStatus=@iTrStatus
		IF @iIfZero='1'
		   BEGIN
			SET @iRetStatus=1
		   END
		ELSE
		   BEGIN
			SET @iRetStatus=0
		   END
	   END
	ELSE
	   BEGIN
		IF @iCount>1
	   	   BEGIN
			SET @iRetStatus=0
		   END
	   END
   END
ELSE
   BEGIN
	SELECT @iCount=COUNT(distinct substring(trOpenTab,@iTab,1) ) 
	  FROM TenderReply
	 WHERE IdMsg=@iIdMsg AND IdTender=@iIdTender and trStatus=@iTrStatus
	IF @iCount=1
	   BEGIN
		SELECT TOP 1 @iIfZero=substring(trOpenTab,@iTab,1)  
		  FROM TenderReply
		 WHERE  IdMsg=@iIdMsg AND IdTender=@iIdTender and trStatus=@iTrStatus
		IF @iIfZero='1'
		   BEGIN
			SET @iRetStatus=1
		   END
		ELSE
		   BEGIN
			SET @iRetStatus=0
		   END
	   END
	ELSE
	   BEGIN
		IF @iCount>1
	   	   BEGIN
			SET @iRetStatus=0
		   END
	   END
   END
SET NOCOUNT OFF
GO
