USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetRegDefault]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetRegDefault] AS
SELECT CAST(rdIdMp AS VARCHAR(10))+'_'+LOWER (RTRIM (rdKey))+'_'+LOWER (RTRIM (rdPath)) AS RKey,

--rdDefValue AS RValue 
dbo.CNV_ESTESA(rdDefValue,'I') as  RValue 

  FROM RegDefault 
 WHERE rdDeleted=0 
GO
