USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ESITO_AMMESSA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_ESITO_AMMESSA] as 
select C.*,O.IdHeader as idPda from ctl_doc C inner join document_pda_offerte O on C.linkeddoc=O.idrow and O.Idmsg=C.IdDoc
where C.tipodoc like 'esito_ammessa%' 

GO
