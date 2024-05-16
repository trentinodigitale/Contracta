USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RIFERIMENTI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[RIFERIMENTI_TESTATA_VIEW] AS
SELECT    

	c.*,
	DC.numord,
	DC.DescrizioneEstesa  as BodyContratto

FROM   
	ctl_doc c 
	inner join document_convenzione DC on c.LinkedDoc=DC.ID

where c.TipoDoc='RIFERIMENTI'

--select * from document_convenzione where id = 402936



GO
