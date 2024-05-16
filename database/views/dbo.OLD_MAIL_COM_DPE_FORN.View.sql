USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_COM_DPE_FORN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--vista per inviare le mail di comunicazione ai fornitori
---------------------------------------------------------------

create view [dbo].[OLD_MAIL_COM_DPE_FORN] as 

select b.IdComFor as IdDoc , a.LNG ,  a.Protocollo , a.Data , a.DataScadenza , a.aziragionesociale 
	from Document_Com_DPE_Fornitori b 
	inner join MAIL_COM_DPE a on idDoc = IdCom

GO
