USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_FROM_NEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

create view [dbo].[CONVENZIONE_FROM_NEW] as 
select 	distinct 
	1 as ID_FROM ,
	'35152001#\0000\0000\00' + CodProgramma  as Plant
from peg

GO
