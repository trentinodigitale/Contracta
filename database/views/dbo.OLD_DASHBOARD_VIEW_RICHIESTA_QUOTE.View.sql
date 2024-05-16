USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_RICHIESTA_QUOTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_RICHIESTA_QUOTE] AS

	select 'CONVENZIONE' as DOCUMENT ,
		DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
		DataFine as expirydate ,
		P.idpfu,
		ISNULL(Q.ImportoRichiesto,0) as ImportoRichiesto, -- Sommatoria delle richieste di quota in approvazione
		ISNULL(AL2.ImportoAllocato,0) as Importo,		  -- Importo allocato
		isnull( Total , 0 ) - ISNULL(AL2.ImportoAllocato,0) as ImportoAllocabile,	-- Valore Convenzione completa - Importo Allocato
		'CONVENZIONE' AS OPEN_DOC_NAME ,
		ISNULL(AL2.ImportoAllocato,0) - dc.TotaleOrdinato as ImportoQuota,	-- residuo allocato. importo alloc. - ordinato
		--dc.TotaleOrdinato,	-- Totale Ordinato presente sulla convenzione
		DC.*  
	from ctl_doc C with(nolock)
			inner join Document_Convenzione  DC with(nolock) on C.ID=DC.ID

			inner join  profiliutente P with(nolock) on  P.pfuvenditore=0 
															and DC.Deleted = 0 
															and DataFine > getdate() 
															and statoconvenzione='Pubblicato' 	
					
			left outer join 
			(
					Select sum(Importo) as ImportoAllocato,LinkedDoc
						from CTL_DOC with(nolock)
								inner join Document_Convenzione_Quote with(nolock) on id = idheader
						where StatoDoc = 'Sended' and TipoDoc='QUOTA' 
						group by (LinkedDoc)
				) as AL2 on AL2.LinkedDoc = DC.id
		
			left outer join Document_Convenzione_Quote_Importo qi with(nolock) on qi.idheader = DC.id and P.pfuidazi=qi.azienda
	
			left join 
			(
				--RICHIESTE	
				Select SUM( ImportoRichiesto) as ImportoRichiesto ,LinkedDoc
					from CTL_DOC with(nolock)
								inner join Document_Convenzione_Quote with(nolock) on id = idheader
						where TipoDoc='RichiestaQuota' and StatoFunzionale='InApprove' and deleted = 0 and StatoDoc <> 'Invalidate'
						group by (LinkedDoc)
				) Q on DC.ID=Q.LinkedDoc

			left join CTL_DOC CO with(nolock) on CO.tipodoc = 'ACCORDO_CREA_CONVENZIONI' and co.deleted = 0 and co.statofunzionale = 'Inviato' 
											and CO.azienda = P.pfuidazi

			left join ctl_doc_value AA with(nolock) on  AA.dse_id = 'enti' and AA.dzt_name = 'IdAzi' and AA.idheader = CO.id and P.pfuidazi = aa.Value
		
	WHERE C.TipoDoc='CONVENZIONE' and DC.GestioneQuote<>'senzaquote' and aa.IdRow is not null

GO
