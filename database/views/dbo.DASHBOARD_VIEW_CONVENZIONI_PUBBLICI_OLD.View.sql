USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI_OLD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI_OLD] as
select  

	DC.*  , 
	'CONVENZIONE' as DOCUMENT ,
	DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
	DataFine as expirydate ,
	P.idpfu,
	ISNULL(Q.ImportoRichiesto,0) as ImportoRichiesto,
	ISNULL(Q.Importo,0) as Importo,
	CASE
		WHEN Q.ImportoRichiesto  > 0 THEN 'RICHIESTAQUOTA'	
		WHEN Q.Importo  > 0 THEN 'QUOTA'		
		ELSE  ''
	END  AS OPEN_DOC_NAME , 
	Q.ID as IDQUOTA,
	Q.StatoDoc 
from 
		Document_Convenzione  DC
		
		inner join 
		
		
		(
			--RICHIESTE
			Select StatoDoc,pfuidazi as azienda,ImportoRichiesto,Importo,LinkedDoc ,ID
			from 
				CTL_DOC ,Document_Convenzione_Quote ,profiliutente
			where 
				id=idHeader and StatoDoc<>'Invalidate' and --StatoDoc<>'Saved'  and
				 TipoDoc='RichiestaQuota' 
				and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
				and CTL_DOC.idpfu=profiliutente.idpfu 
				--and isnull(importo,0)=0
				
			union 


			--QUOTE ASSEGNATE DALL'ENTE
			Select StatoDoc, C.azienda  , D.ImportoRichiesto , D.Importo , C.LinkedDoc ,C.ID 
			from 
				CTL_DOC C,Document_Convenzione_Quote D 
			where 
				C.id= idHeader and StatoDoc<>'Invalidate' and StatoDoc<>'Saved'  and
				TipoDoc='Quota' and isnull(D.importo,0)>0 and isnull(D.importorichiesto,0)=0
				and isnull(C.Azienda,0)>0 
				
				and cast(azienda as varchar(20)) + '-' + cast(LinkedDoc as varchar(20)) not in (
					Select --pfuidazi as azienda + '-' + LinkedDoc 
							cast( pfuidazi as varchar(20)) + '-' + cast(LinkedDoc as varchar(20))
					from 
						CTL_DOC ,Document_Convenzione_Quote ,profiliutente
					where 
						id=idHeader and StatoDoc<>'Invalidate' and --StatoDoc<>'Saved'  and
						 TipoDoc='RichiestaQuota' 
						and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
						and CTL_DOC.idpfu=profiliutente.idpfu 
				)
				
		)Q 
		
		on Q.LinkedDoc=DC.ID

		inner join  
		profiliutente P 
		on  P.pfuvenditore=0 and P.pfuidazi=Q.azienda
		
		
where 
	DC.Deleted = 0 and DataFine > getdate() and statoconvenzione='Pubblicato'


union all

select  

	DC.*  , 
	'CONVENZIONE' as DOCUMENT ,
	DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
	DataFine as expirydate ,
	P.idpfu,
	0 as ImportoRichiesto,
	0 as Importo,
	''  AS OPEN_DOC_NAME , 
	-1 as IDQUOTA,
	'' as StatoDoc 
from 
	Document_Convenzione  DC
	inner join  
	profiliutente P on  P.pfuvenditore=0 		
	and Dc.id not in 
		
		(
			 
			Select LinkedDoc
			from 
				CTL_DOC ,Document_Convenzione_Quote ,profiliutente
			where 
				id=idHeader and StatoDoc<>'Invalidate' and --StatoDoc<>'Saved'  and
				 TipoDoc='RichiestaQuota' 
				and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
				and CTL_DOC.idpfu=profiliutente.idpfu
				
			union all
			Select LinkedDoc
			from 
				CTL_DOC ,Document_Convenzione_Quote
			where 
				id=idHeader and StatoDoc<>'Invalidate' and StatoDoc<>'Saved'  and
				TipoDoc='Quota' and isnull(importo,0)>0
				and isnull(Azienda,0)>0
		) 
		
		and DC.Deleted = 0 and DataFine > getdate() and statoconvenzione='Pubblicato'
GO
