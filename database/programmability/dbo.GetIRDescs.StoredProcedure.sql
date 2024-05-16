USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetIRDescs]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.GetIRDescs    Script Date: 19/09/2000 9.51.06 ******/
CREATE PROCEDURE [dbo].[GetIRDescs] as
SELECT syscolumns.name AS Colonna,
       sysobjects.name AS Tabella
 FROM sysforeignkeys,sysobjects,syscolumns
WHERE fkeyid=sysobjects.id 
  AND fkeyid=syscolumns.id AND colid=fkey
  AND rkeyid=(SELECT id 
                FROM sysobjects 
               WHERE sysobjects.name LIKE 'DescsI') 
  AND sysobjects.name not like 'Descs%'
ORDER BY sysobjects.name
GO
