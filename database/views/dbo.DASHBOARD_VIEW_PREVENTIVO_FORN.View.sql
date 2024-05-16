USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PREVENTIVO_FORN]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  view [dbo].[DASHBOARD_VIEW_PREVENTIVO_FORN] as
select 
			u.idpfu as idDestinatario 
			, c.NumOrd as NumeroConvenzione 
			,p.Id
			,p.IdPfu
			,p.TipoDoc
			,p.StatoDoc
			,p.Data
			,p.Protocollo
			,p.Titolo
			,p.StrutturaAziendale
			,p.StrutturaAziendale as ODC_PEG
			,p.DataInvio
			,DOC_Name
			,c.ID as Convenzione
			,p.StatoFunzionale

		from CTL_DOC p
			--inner join 
			, CTL_DOC_value v --Id_Convenzione
			,Document_Convenzione c --on c.ID = p.LinkedDoc
			--inner join 
			,profiliutente  u --on Azi_Dest = pfuidazi
		 where TipoDoc = 'PREVENTIVO_FORN' and p.deleted = 0
			--and StatoDoc <> 'Saved'
			and v.IdHeader = p.id and DSE_ID = 'TESTATA' and DZT_Name = 'Id_Convenzione'
			and c.ID = v.Value --p.Id_Convenzione
			and Azi_Dest = pfuidazi


GO
