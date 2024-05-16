USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_NUOVIQUESITI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MSG_LINKED_NUOVIQUESITI]
AS
select  
		id
       ,a.Fascicolo       
       , b.idpfu
      --, case when DOC_NAME is null then 1 else 0 end as bread 
	  ,0 as bread
      , '_1' as tipo 
      , ProtocolloBando
      , Protocol as Protocollo
      , aziragionesociale as Titolo
      --, a.linkeddoc
      , 'Sent' as StatoDoc
      , a.DataCreazione as Data
	
      , 'DETAIL_CHIARIMENTI' as OPEN_DOC_NAME

--select * 
from CHIARIMENTI_PORTALE_BANDO a ,
profiliutente b where idpfu=utentedomanda
--and Stato='Sended'
GO
