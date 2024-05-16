USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_LISTA_LOTTO_ECO_FILE_PENDING]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_LISTA_LOTTO_ECO_FILE_PENDING] AS

	select distinct od.id as idRow,		-- id della riga del lotto offerto
					m.id as idHeader,	-- id della Document_MicroLotti_Dettagli utilizzato come chiave di ingresso
					dof.Protocollo as ProtocolloOfferta
		from Document_MicroLotti_Dettagli m with(nolock) 
				inner join Document_PDA_OFFERTE o with(nolock) on o.idheader = m.IdHeader
				inner join Document_MicroLotti_Dettagli od with(nolock) on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = m.NumeroLotto and od.voce = 0 
				inner join ctl_doc dof with(Nolock) on dof.id = o.IdMsg -- offerta
				inner join ctl_doc da with(nolock) on da.LinkedDoc = o.IdMsg and da.tipodoc = 'OFFERTA_ALLEGATI' and da.Deleted = 0
				inner join Document_Offerta_Allegati al with(nolock) on al.Idheader = da.Id and al.numeroLotto = m.NumeroLotto and al.SectionName = 'ECONOMICA' and al.statoFirma = 'SIGN_PENDING'
		--where m.id = 223139
GO
