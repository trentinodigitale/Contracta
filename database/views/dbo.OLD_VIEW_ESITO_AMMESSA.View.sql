USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ESITO_AMMESSA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create VIEW [dbo].[OLD_VIEW_ESITO_AMMESSA] as 
select C.*,O.IdHeader as idPda from ctl_doc C inner join document_pda_offerte O on C.linkeddoc=O.idrow and O.Idmsg=C.IdDoc
where C.tipodoc='esito_ammessa' 
GO
