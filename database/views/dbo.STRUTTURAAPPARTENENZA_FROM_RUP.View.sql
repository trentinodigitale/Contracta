USE [AFLink_TND]
GO
/****** Object:  View [dbo].[STRUTTURAAPPARTENENZA_FROM_RUP]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[STRUTTURAAPPARTENENZA_FROM_RUP] as
select 
	 idpfu as id ,
	 'I' as Lingua,
	 attvalue as DirezioneEspletante,
	 attvalue as StrutturaAziendale
from 
	ProfiliUtenteAttrib with (nolock)
	  
where dztnome='plant'

GO
