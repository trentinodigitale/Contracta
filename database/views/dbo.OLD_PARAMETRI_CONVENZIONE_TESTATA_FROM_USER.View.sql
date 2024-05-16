USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_CONVENZIONE_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_PARAMETRI_CONVENZIONE_TESTATA_FROM_USER] as
select
	p.idpfu as ID_FROM,
	D.*
	
	
from 
PARAMETRI_CONVENZIONE_TESTATA_VIEW	D
	cross join profiliUtente p
where  
	tipodoc='parametri_convenzione' 
	and statofunzionale='confermato'
GO
