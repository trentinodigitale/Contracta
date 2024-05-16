USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ESPD_REQUEST_XML_LOTTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ESPD_REQUEST_XML_LOTTI] AS
	select case when a2.Divisione_lotti = '0' then 'Lotto_' + a2.CIG
				else 'Lotto' + isnull(b.NumeroLotto,'') + '_' + isnull(b.CIG,'') 
			end as ID_LOTTO,
			A.ID AS idProcedura,
			cast( isnull(b.NumeroLotto,'0') as int) as numeroLotto
		from ctl_doc a with(nolock) 
				inner join Document_MicroLotti_Dettagli b with(nolock) on b.IdHeader = a.id and ( b.Voce = 0 or b.voce is null ) and b.TipoDoc = a.TipoDoc
				left join document_bando a2 with(nolock) on a2.idHeader = a.Id


GO
