USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--[OK] per il calcolo importo da allocare
---------------------------------------------------------------

CREATE view [dbo].[DASHBOARD_VIEW_CONVENZIONI_PUBBLICI] as
--CONVENZIONI CON QUOTE LE VEDONO GLI ENTI CHE HANNO UNA QUOTA
select  

	'CONVENZIONE' as DOCUMENT ,
	DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
	DataFine as expirydate ,
	P.idpfu,
	ISNULL(Q.ImportoRichiesto,0) as ImportoRichiesto,
	ISNULL(al.Importo,0) as Importo,
	isnull( Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile,
	CASE
		WHEN Q.ImportoRichiesto  > 0 THEN 'RICHIESTAQUOTA'	
		WHEN Q.Importo  > 0 THEN 'QUOTA'		
		ELSE  ''
	END  AS OPEN_DOC_NAME , 
	Q.ID as IDRICHIESTAQUOTA,
	al.idQuota as IDQUOTA,
	Q.StatoDoc ,
	ImportoQuota - ImportoSpesa as ImportoQuota,
	ImportoSpesa,
	DC.*  

from 
	ctl_doc C inner join 
		Document_Convenzione  DC on C.ID=DC.ID
			inner join  profiliutente P on  P.pfuvenditore=0 
											and DC.Deleted = 0 
											and DataFine > getdate() 
											and statoconvenzione='Pubblicato' 	
	
	
			left outer join (
					Select azienda,Importo,LinkedDoc ,ID as idQuota	
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
					) as AL on al.LinkedDoc = DC.id and P.pfuidazi=al.azienda		
				
			left outer join (
					Select sum(Importo) as ImportoAllocabile,LinkedDoc
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
						group by (LinkedDoc)
					) as AL2 on AL2.LinkedDoc = DC.id --and P.pfuidazi=AL2.azienda			
		
			left outer join 
			--inner join	
				--QUOTE
				Document_Convenzione_Quote_Importo qi on qi.idheader = DC.id and P.pfuidazi=qi.azienda
	
			left join 
			(
				--RICHIESTE	
				Select StatoDoc,pfuidazi as azienda,ImportoRichiesto,Importo,LinkedDoc ,ID	
				from 
					CTL_DOC ,Document_Convenzione_Quote ,profiliutente
				where 
					id=idHeader and StatoDoc <> 'Invalidate' and StatoDoc<>'Saved'  and
					 TipoDoc='RichiestaQuota' 
					and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
					and CTL_DOC.idpfu=profiliutente.idpfu 
			
				)Q on DC.ID=Q.LinkedDoc and P.pfuidazi=Q.azienda
		
WHERE
	C.TipoDoc='CONVENZIONE'
	and DC.GestioneQuote<>'senzaquote'

union all

--CONVENZIONI SENZA QUOTE LE VEDONO TUTTI GLI ENTI SE LA LISTA ENTI SULLA CONV E' VUOTA
select  

	'CONVENZIONE' as DOCUMENT ,
	DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
	DataFine as expirydate ,
	P.idpfu,
	ISNULL(Q.ImportoRichiesto,0) as ImportoRichiesto,
	ISNULL(al.Importo,0) as Importo,
	isnull( Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile,
	CASE
		WHEN Q.ImportoRichiesto  > 0 THEN 'RICHIESTAQUOTA'	
		WHEN Q.Importo  > 0 THEN 'QUOTA'		
		ELSE  ''
	END  AS OPEN_DOC_NAME , 
	Q.ID as IDRICHIESTAQUOTA,
	al.idQuota as IDQUOTA,
	Q.StatoDoc ,
	ImportoQuota - ImportoSpesa as ImportoQuota,
	ImportoSpesa,
	DC.*  

from 
	ctl_doc C inner join 
		Document_Convenzione  DC on C.ID=DC.ID
			inner join  profiliutente P on  P.pfuvenditore=0 
			left outer join (
					Select azienda,Importo,LinkedDoc ,ID as idQuota	
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
					) as AL on al.LinkedDoc = DC.id and P.pfuidazi=al.azienda		
				
			left outer join (
					Select sum(Importo) as ImportoAllocabile,LinkedDoc
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
						group by (LinkedDoc)
					) as AL2 on AL2.LinkedDoc = DC.id --and P.pfuidazi=AL2.azienda			
		
			left outer join	
				Document_Convenzione_Quote_Importo qi on qi.idheader = DC.id and P.pfuidazi=qi.azienda
			
			left outer join	
				Document_Convenzione_Plant E on DC.ID=E.IdHeader and P.pfuidazi=E.AZI_Ente 
				
			
			left join 
			(
				--RICHIESTE	
				Select StatoDoc,pfuidazi as azienda,ImportoRichiesto,Importo,LinkedDoc ,ID	
				from 
					CTL_DOC ,Document_Convenzione_Quote ,profiliutente
				where 
					id=idHeader and StatoDoc <> 'Invalidate' and StatoDoc<>'Saved'  and
					 TipoDoc='RichiestaQuota' 
					and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
					and CTL_DOC.idpfu=profiliutente.idpfu 
			
				)Q on DC.ID=Q.LinkedDoc and P.pfuidazi=Q.azienda
		
WHERE
	C.TipoDoc='CONVENZIONE'
	and DC.Deleted = 0 
	and DataFine > getdate() 
	and statoconvenzione='Pubblicato' 	
	and DC.GestioneQuote='senzaquote'
	AND (select count(*) from Document_Convenzione_Plant where DC.ID=IdHeader)=0
	

union all


--CONVENZIONI SENZA QUOTE LE VEDONO GLI ENTI CHE SONO NELLA LISTA ENTI SE PRESENTE
select  

	'CONVENZIONE' as DOCUMENT ,
	DC.id as IDMSG,isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo,
	DataFine as expirydate ,
	P.idpfu,
	ISNULL(Q.ImportoRichiesto,0) as ImportoRichiesto,
	ISNULL(al.Importo,0) as Importo,
	isnull( Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile,
	CASE
		WHEN Q.ImportoRichiesto  > 0 THEN 'RICHIESTAQUOTA'	
		WHEN Q.Importo  > 0 THEN 'QUOTA'		
		ELSE  ''
	END  AS OPEN_DOC_NAME , 
	Q.ID as IDRICHIESTAQUOTA,
	al.idQuota as IDQUOTA,
	Q.StatoDoc ,
	ImportoQuota - ImportoSpesa as ImportoQuota,
	ImportoSpesa,
	DC.*  

from 
	ctl_doc C inner join 
		Document_Convenzione  DC on C.ID=DC.ID
			inner join  profiliutente P on  P.pfuvenditore=0 
											and DC.Deleted = 0 
											and DataFine > getdate() 
											and statoconvenzione='Pubblicato' 	
	
	
			left outer join (
					Select azienda,Importo,LinkedDoc ,ID as idQuota	
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
					) as AL on al.LinkedDoc = DC.id and P.pfuidazi=al.azienda		
				
			left outer join (
					Select sum(Importo) as ImportoAllocabile,LinkedDoc
					from 
						CTL_DOC 
						inner join Document_Convenzione_Quote on id = idheader
					where 
						StatoDoc = 'Sended' and TipoDoc='QUOTA' 
						group by (LinkedDoc)
					) as AL2 on AL2.LinkedDoc = DC.id --and P.pfuidazi=AL2.azienda			
		
			left outer join	
				Document_Convenzione_Quote_Importo qi on qi.idheader = DC.id and P.pfuidazi=qi.azienda
			
			inner join	
				Document_Convenzione_Plant E on DC.ID=E.IdHeader and P.pfuidazi=E.AZI_Ente
			
			left join 
			(
				--RICHIESTE	
				Select StatoDoc,pfuidazi as azienda,ImportoRichiesto,Importo,LinkedDoc ,ID	
				from 
					CTL_DOC ,Document_Convenzione_Quote ,profiliutente
				where 
					id=idHeader and StatoDoc <> 'Invalidate' and StatoDoc<>'Saved'  and
					 TipoDoc='RichiestaQuota' 
					and (StatoFunzionale='InApprove' or StatoFunzionale='Approved' or StatoFunzionale='InLavorazione')
					and CTL_DOC.idpfu=profiliutente.idpfu 
			
				)Q on DC.ID=Q.LinkedDoc and P.pfuidazi=Q.azienda
		
WHERE
	C.TipoDoc='CONVENZIONE'
	and DC.GestioneQuote='senzaquote'
GO
