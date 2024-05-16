USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_REPORT_REGISTRAZIONI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select  count(*) 
--	from aziende 
--		inner join profiliutente on pfuidazi = idazi and pfudeleted = 0 
--	where aziacquirente > 0 and azideleted = 0 


--select * from profiliutente where pfudatacreazione is null

--update profiliutente set pfudatacreazione = getdate() where pfudatacreazione is null


CREATE view [dbo].[OLD_DASHBOARD_VIEW_REPORT_REGISTRAZIONI] as 

	-- recupero tutti i periodi utili
	select P.AnnoMese ,P.AnnoMese as AnnoMese_RPT_Iscriz_DA , P.AnnoMese  as AnnoMese_RPT_Iscriz_A , NumEnti ,  NumOE , NumUtentiPA , NumUtentiOE , numIscrittiME , numIscrittiSDA
		from ( -- PERIODI PRESENTI

			select convert( varchar(7 ) ,  aziDataCreazione , 121) as AnnoMese
				from aziende with (nolock)
				where azideleted = 0 and aziDataCreazione is not null
			union
			select convert( varchar(7 ) , p.pfuDataCreazione , 121) as AnnoMese
				from aziende a with (nolock)
					inner join profiliutente p with (nolock) on a.idazi = p.pfuIdAzi and p.pfuDeleted = 0  
				where p.pfuDataCreazione is not null
			union 
				select distinct convert( varchar(7 ) , D.DataIscrizione , 121) as AnnoMese 
					from ctl_doc B with (nolock)
						inner join CTL_DOC_Destinatari D with (nolock) on B.id = D.idheader 
	
					where B.tipodoc in  ( 'BANDO' , 'BANDO_SDA' )
						and B.Deleted = 0
						and StatoIscrizione is not null 
						and D.DataIscrizione is not null 
			) as P


		-- numero utenti PA e ME  ??? gli utenti cessati devono essere contati ??? al momento no
		left outer join ( --Numero utenze PA e OE
			select AnnoMese 
						,sum(  case when a.aziAcquirente > 0 then NumUtenti  else 0 end) as NumUtentiPA 
						,sum(  case when a.aziVenditore > 0 then NumUtenti  else 0 end) as NumUtentiOE 
				from 
					(
					--select convert( varchar(7 ) , p.pfuDataCreazione , 121) as AnnoMese , idazi ,  count(*) as NumUtenti , aziAcquirente , aziVenditore
					select convert( varchar(7 ) , p.pfuDataCreazione , 121) as AnnoMese , idazi ,  1 as NumUtenti , aziAcquirente , aziVenditore
						from aziende a with (nolock)
							inner join profiliutente p with (nolock) on a.idazi = p.pfuIdAzi and p.pfuDeleted = 0  
						where a.aziDeleted = 0
						--group by convert( varchar(7 ) , p.pfuDataCreazione , 121) , idazi , aziAcquirente , aziVenditore
					) as a
					group by AnnoMese 
			) as N on n.AnnoMese = P.AnnoMese

		-- numero utenti PA e ME  ??? gli utenti cessati devono essere contati ??? al momento no
		left outer join ( --Numero utenze PA e OE
			select AnnoMese , sum( case when a.aziAcquirente > 0 then 1 else 0 end )  as NumEnti 
							, sum( case when a.aziVenditore > 0 then 1 else 0 end )  as NumOE

				from 
					(
					select convert( varchar(7 ) , a.aziDataCreazione , 121) as AnnoMese , idazi ,   aziAcquirente , aziVenditore
						from aziende a with (nolock)
							--inner join profiliutente p on a.idazi = p.pfuIdAzi and p.pfuDeleted = 0  
						where a.aziDeleted = 0
						group by convert( varchar(7 ) ,  a.aziDataCreazione , 121) , idazi , aziAcquirente , aziVenditore
					) as a
					group by AnnoMese 
			) as A on A.AnnoMese = P.AnnoMese


		left outer join ( --Numero Iscritti SDA e ME

			select AnnoMese , sum( case when tipodoc  = 'BANDO' then 1 else 0 end ) as numIscrittiME 
					,  sum( case when tipodoc  = 'BANDO_SDA' then 1 else 0 end ) as numIscrittiSDA
				from  (
						select distinct convert( varchar(7 ) , D.DataIscrizione , 121) as AnnoMese , B.tipodoc  , D.idAzi  

							from ctl_doc B with (nolock)
								inner join CTL_DOC_Destinatari D with (nolock) on B.id = D.idheader 
								inner join aziende A with (nolock) on A.IdAzi=D.IdAzi and A.aziDeleted=0

							where B.tipodoc in  ( 'BANDO' , 'BANDO_SDA' )
								and B.Deleted = 0
								and StatoIscrizione in ('Iscritto','Sospeso')

						) as a
					Group By AnnoMese
			) as I on I.AnnoMese = P.AnnoMese

	where P.AnnoMese is not null




GO
