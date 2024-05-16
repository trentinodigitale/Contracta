USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_BANDO_FORN_FROM_BANDO_FORN_QF]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CHIARIMENTI_BANDO_FORN_FROM_BANDO_FORN_QF] as 

SELECT 

	id as ID_FROM  ,
	id as ID_origin, 
	p.idPfu,
	protocollo as protocollobando,
	body as oggetto,
	aziragionesociale,
	azie_mail,
	'BANDO_QF' as document

	
	

	FROM         CTL_DOC  
		cross join profiliutente p
		inner join  aziende a on a.idazi = p.pfuidazi

		
	where 
		TipoDoc='BANDO_QF' 
		
		









GO
