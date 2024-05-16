USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_SCADENZARI_CONTRATTI_CAL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_SCADENZARI_CONTRATTI_CAL] as

---RECUPERO LE CONVENZIONI	
select
		Owner as IdPfu,
		convert(varchar(10),Datafine, 126 )  as id, 
		tipoDoc , 
		convert( datetime, convert(varchar(10),Datafine, 126 ))   as DataRiferimento,
		count(*) as Num ,
		1 as bRead ,
		'Convenzione - N ' as Descrizione,
		max(titolo) as titolo ,
		max(azienda) as Azi_Ente,
		max(Destinatario_Azi) as idAziPartecipante 
	from DASHBOARD_VIEW_CONVENZIONI 		
	where StatoFunzionale <> 'InLavorazione'
	group by  Datafine  , tipoDoc , Owner

UNION ALL
	select  
		max(IdPfu) as Idpfu,
		max(id) as id,
		TipoDoc,
		DataRiferimento,
		count(*) as Num ,
		1 as bRead ,
		'Contratti - N' as Descrizione,
		max(titolo) as titolo ,
		max(azienda) as Azi_Ente,
		max(Destinatario_Azi) as idAziPartecipante 
	from 
	(
		--RECUPERO I CONTRATTI
		select
			P.IdPfu as IdPfu,
			convert(varchar(10),DataScadenza, 126 )  as id,		
			--convert(varchar(10),getdate(), 126 )  as id,		
			'CONTRATTI' as tipoDoc , 
			convert( datetime, convert(varchar(10),DataScadenza, 126 ))  as DataRiferimento,
			--convert( datetime, convert(varchar(10),getdate(), 126 ))  as DataRiferimento,
			Titolo,
			Azienda,
			Destinatario_Azi
		from DASHBOARD_VIEW_CONTRATTO_GARA 	
			inner join ProfiliUtente  P with(nolock) on P.pfuidazi=azienda and P.pfuDeleted=0
		where StatoFunzionale <> 'InLavorazione'	

		UNION ALL
		--RECUPERO LE SCRITTURE PRIVARE
		select
				P.IdPfu as IdPfu,
				convert(varchar(10),DataScadenza, 126 )  as id,		
				--convert(varchar(10),getdate(), 126 )  as id,		
				'CONTRATTI' as tipoDoc , 
				convert( datetime, convert(varchar(10),DataScadenza, 126 ))  as DataRiferimento,
				--convert( datetime, convert(varchar(10),getdate(), 126 ))  as DataRiferimento,
				Titolo,
				Azienda,
				Destinatario_Azi
		from DASHBOARD_VIEW_SCRITTURA_PRIVATA 	
			inner join ProfiliUtente  P with(nolock) on P.pfuidazi=azienda and P.pfuDeleted=0
		where StatoFunzionale <> 'InLavorazione'
	) as W
	group by  DataRiferimento  , tipoDoc , IdPfu







GO
