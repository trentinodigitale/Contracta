USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[REFRESH_PERMESSI_UTENTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [dbo].[REFRESH_PERMESSI_UTENTI] (@idazi int = 0 )AS
BEGIN
	set NOCOUNT ON

	select top 0 0 as idpfu,cast('' as nvarchar(max)) as PROF_List , cast( '' as varchar(100)) as aziProfili into #TEMP_WORK
	
	--METTE INSIEME PER OGNI UTENTE PRESENTE NELLA ProfiliUtenteAttrib i profili che trova
	if @idazi > 0 
	BEGIN	
		insert into #TEMP_WORK ( idpfu,PROF_List)
		select distinct
			P.idpfu,
					(select   '@@@' +  attvalue
						FROM ProfiliUtenteAttrib SUB with (nolock)
							--INNER JOIN ProfiliUtente p WITH(NOLOCK) ON p.IDPFU=sub.IDPFU AND p.PFUDELETED=0
							--left outer join Profili_Funzionalita with (nolock) on attvalue = codice  and Profili_Funzionalita.deleted=0		
						WHERE dztNome ='Profilo' and SUB.IdPfu=P.idpfu	--and P.IdPfu>0
						order by attvalue asc
						FOR XML PATH('') 
					) + '@@@' + A.aziprofili AS PROF_List -- into #TEMP_WORK
			from ProfiliUtenteAttrib P with (nolock) 	
				inner join profiliUtente PU with(nolock) on PU.idpfu=P.idpfu and PU.pfuIdAzi=@idazi	
				inner join Aziende A with(nolock) on PU.pfuidazi=A.idazi	
			WHERE P.dztNome ='Profilo'	
	END
	ELSE
	BEGIN	
		insert into #TEMP_WORK ( idpfu,PROF_List,aziProfili)
		select distinct
			P.idpfu,
					(select   '@@@' +  attvalue
						FROM ProfiliUtenteAttrib SUB with (nolock)
							--INNER JOIN ProfiliUtente p WITH(NOLOCK) ON p.IDPFU=sub.IDPFU AND p.PFUDELETED=0
							--left outer join Profili_Funzionalita with (nolock) on attvalue = codice  and Profili_Funzionalita.deleted=0		
						WHERE dztNome ='Profilo' and SUB.IdPfu=P.idpfu	--and P.IdPfu>0
						order by attvalue asc
						FOR XML PATH('') 
					) + '@@@' + A.aziprofili AS PROF_List-- into #TEMP_WORK
					, aziProfili
			from ProfiliUtenteAttrib P with (nolock) 	
				inner join profiliUtente PU with(nolock) on PU.idpfu=P.idpfu		
				inner join Aziende A with(nolock) on PU.pfuidazi=A.idazi	
			WHERE P.dztNome ='Profilo'	
	END
		
	

	--FACCIAMO UNA GROUP BY DI LISTA DI PROFILI
	select distinct max(idpfu) as idpfu, prof_list , aziProfili
		into #t
		from #TEMP_WORK K where PROF_List <> '@@@'
	GROUP BY PROF_List , aziProfili
		
	alter table #t
		add pfufunzionalita nvarchar(max)

	alter table #t
		add pfuprofili nvarchar(max)

	alter table #TEMP_WORK
		add pfufunzionalita nvarchar(max)

	alter table #TEMP_WORK
		add pfuprofili nvarchar(max)

		
	--CALCOLO PER LISTA PROFILI	
	UPDATE T
		SET 
			pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU (idpfu),
			pfuprofili = dbo.MERGE_PFUPROFILO_FROM_IDPFU(idpfu)
		from #t T
		
	--AGGIORNA LA TABELLA DI LAVORO
	update F 
		set 
			F.pfufunzionalita=s.pfufunzionalita,
			F.pfuprofili=s.pfuprofili
	from #TEMP_WORK f
		inner join #t s on s.PROF_List=f.PROF_List and f.aziProfili = s.aziProfili

	CREATE CLUSTERED INDEX IDX_IDPFU ON #TEMP_WORK(idpfu)
	--AGGIORNA LA PROFILI UTENTE
	update P
		set p.Pfufunzionalita=s.pfufunzionalita,
			P.pfuprofili=s.pfuprofili
	from ProfiliUtente P with(index(IX_ProfiliUtente),nolock)
		inner join #TEMP_WORK s with(index(IDX_IDPFU),nolock) on s.IdPfu=P.IdPfu

	drop table #T
	drop table #TEMP_WORK


	---- patch, su alcuni utenti è capitato che non calcola l'elenco dei profili 
	 update profiliutente
	   set pfufunzionalita = dbo.XOR_FUNZIONALITA_FROM_IDPFU( idpfu )
		, pfuProfili  =  dbo.MERGE_PFUPROFILO_FROM_IDPFU( idpfu )
	   where ISNULL( pfuProfili , '' ) = '' OR ISNULL( pfufunzionalita , '' ) = '' 

END 
GO
