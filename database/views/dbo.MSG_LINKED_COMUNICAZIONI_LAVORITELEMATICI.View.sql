USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_COMUNICAZIONI_LAVORITELEMATICI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MSG_LINKED_COMUNICAZIONI_LAVORITELEMATICI]
AS
select  
		a.idrow as id
       ,a.Fascicolo       
       , b.idpfu
      --, case when DOC_NAME is null then 1 else 0 end as bread 
	  ,0 as bread
      , '189' as tipo 
      , a.Protocol as ProtocolloBando
      , a.ProtocolloGenerale as Protocollo
      , 'Comunicazione Esclusione' as Titolo
      --, a.linkeddoc
      , a.Stato as StatoDoc
      , a.DataInvio as Data
      , 'COM_ESCLUSIONE' as OPEN_DOC_NAME

--select * 
from Document_Esclusione_view a ,
profiliutente b where pfuidazi=fornitore
and Stato='Sended'
GO
