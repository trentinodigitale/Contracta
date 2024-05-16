USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_COM_DPE_PLANT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------
--vista per inviare le mail di comunicazione alle direzioni
---------------------------------------------------------------

   CREATE view [dbo].[MAIL_COM_DPE_PLANT] as 

	select b.IdRow as IdDoc , a.LNG ,  a.Protocollo , a.Data , a.DataScadenza , a.aziragionesociale  , a.pfuNome
			 , a.Titolo
			 , a.TestoComunicazione
		from Document_Com_DPE_Plant b 
			inner join MAIL_COM_DPE a on idDoc = IdCom
   

GO
