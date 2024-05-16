USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_RUBRICA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[DASHBOARD_SP_VIEW_RUBRICA]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @nIsExcel						int = 0
)
as
	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ruolo as varchar(1500)
	
	set nocount on

	--set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	--print @Param
	
	--recupero i parametri Profilo e UserRole 
    set @Profilo = dbo.GetParam( 'Profilo' , @Param ,1)
	set @Ruolo = dbo.GetParam( 'UserRole' , @Param ,1)
	

	--print 	@Profilo
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_RUBRICA' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	set @SQLCmd = ''

	--se sto facendo EXCEL metto in una tabella TEMP le descrizioni per il campo StatoUtenti
	if @nIsExcel = 1
	BEGIN
		set @SQLCmd = '
			select 
				DMV_DM_ID as Dominio, DMV_Cod as Codice , isnull( cast( ML_Description as nvarchar(4000)) , Dmv_descML)  as Descrizione
					into #Desc_Domini
				from LIB_DomainValues with (nolock)
					left outer join LIB_Multilinguismo with (nolock) on ML_KEY = DMV_DescML and ML_LNG=''I''
				where DMV_DM_ID in (''statoutenti'',''TIPO_AMM_ER'')

			'
	END


	set @SQLCmd =  @SQLCmd +
			'
			select 
				idpfu,aziLog,aziRagioneSociale,EmailComunicazioni,pfuE_Mail,pfuCell,pfuCognome,pfuDataCreazione,pfulogin,pfunomeutente,pfuTel,PrimoLivelloStruttura,StatoUtenti,TIPO_AMM_ER,pfuCodiceFiscale as CodiceFiscale
				
					into #Temp 
			from DASHBOARD_VIEW_RUBRICA 
			
			'

	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd + ' WHERE ' + @SQLWhere
	
	--aggiungo la condizione sul profilo
	if @Profilo <> '' 
	begin
		if @SQLWhere='' 
			set @SQLCmd=@SQLCmd + ' WHERE '
		else
			set @SQLCmd=@SQLCmd + ' AND '

		set   @SQLCmd=@SQLCmd + ' idpfu in (select idpfu from 	profiliutenteattrib with (nolock) where dztnome=''Profilo'' and attvalue=''' + @Profilo + ''')'
	end

	--aggiungo la condizione 'se l'idpfu non è ente mostro 0 record'
	if (SELECT COUNT(*) FROM ProfiliUtente WHERE IdPfu = @IdPfu and substring(pfuFunzionalita,2,1)=1) = 0
	begin
		--l'idpfu NON è ente
		if @SQLWhere='' 
			set @SQLCmd=@SQLCmd + ' WHERE '
		else
			set @SQLCmd=@SQLCmd + ' AND '

		set   @SQLCmd=@SQLCmd + ' 1 = 0 '
	end

	--aggiungo la condizione sul ruolo
	if 	@Ruolo <> '' 
	begin
		if @SQLWhere='' and @Profilo=''
			set @SQLCmd=@SQLCmd + ' WHERE '
		else
			set @SQLCmd=@SQLCmd + ' AND '

		set   @SQLCmd=@SQLCmd + ' idpfu in (select idpfu from 	profiliutenteattrib with (nolock) where dztnome=''UserRole'' and attvalue=''' + @Ruolo + ''')'
	end


	set @SQLCmd = @SQLCmd + '
	
		--select  ' + case when cast( @Top as varchar(10)) = '-1' then '' else ' top ' + cast( @Top as varchar(10))  end  + '
		
			
		select * 
				into #ProfiliUtente_UserRole 
			from 
				ProfiliUtenteAttrib with (nolock) 
			where dztNome = ''UserRole'' and idpfu in (select idpfu from #Temp)


		select * 
				into #ProfiliUtente_Profili 
			from 
				ProfiliUtenteAttrib with (nolock) 
			where dztNome = ''Profilo''  and idpfu in (select idpfu from #Temp)

		select 
			P.idpfu as idutente   
		
		'
		
	if @nIsExcel = 0
	BEGIN
		set @SQLCmd = @SQLCmd + 
		'			

			,REPLACE(
				REPLACE
				(
				''<table class=table_ruoli_utenti>''  +
	
						(    
						
						SELECT  ''<tr><td>'' + isnull( cast( ML_Description as nvarchar(4000)) , DMV_DescML ) + ''</td>'' +	
							''<td>'' + CONVERT( varchar(10) , isnull(SUB.DataUltimaMod,getdate()) , 103 ) + ''</td>''
							+
							''</tr>''
							AS [text()]
							--FROM ProfiliUtenteAttrib SUB
							from #ProfiliUtente_UserRole SUB
									inner join dbo.LIB_DomainValues with (nolock) on DMV_DM_ID = ''UserRole'' and DMV_Cod = attvalue 
									left outer join LIB_Multilinguismo with (nolock) on ML_KEY = DMV_DescML and ML_LNG = ''I''
							WHERE
								SUB.IdPfu = p.IdPfu
								--AND dztNome = ''UserRole''
								order by isnull(SUB.DataUltimaMod,getdate())  desc
								FOR XML PATH('''') 
							)

				+ ''</table>''
				,''&lt;'',''<''
				)
			,''&gt;'',''>'') AS RuoloUtente
			
			,REPLACE(

				REPLACE
				(

				''<table class=table_profili_utenti>''  +

					
							(  SELECT ''<tr><td>''  +  ISNULL(cast( Descrizione as nvarchar(500)),'''') + ''</td>''
							+	
								case when SUB.DataUltimaMod is not null then 	''<td>'' + CONVERT( varchar(10) , isnull(SUB.DataUltimaMod,getdate()) , 103 ) + ''</td>''
								else '''' end 
							+
							''</tr>''

						AS [text()]
							--FROM ProfiliUtenteAttrib SUB
							from #ProfiliUtente_Profili SUB
									left outer join Profili_Funzionalita with (nolock) on attvalue = codice  and Profili_Funzionalita.deleted=0
									--left outer join dbo.LIB_Multilinguismo with (nolock) on ML_KEY = cast( Descrizione as nvarchar(500)) and ML_LNG = ''I''
							WHERE
							SUB.IdPfu = p.IdPfu 
							--AND dztNome = ''Profilo''
							order by isnull(SUB.DataUltimaMod,getdate())  desc
							FOR XML PATH('''') 
							)
				+ ''</table>''
				,''&lt;'',''<''
				)
			,''&gt;'',''>'') AS pfuprofili
		'
	END

	--se sto facendo excel aggiungo le colonne utili all'excel
	if @nIsExcel = 1
	BEGIN
		set @SQLCmd = @SQLCmd +
		'
		,STUFF(
			(SELECT   
					'', '' + isnull( cast( ML_Description as nvarchar(4000)) , DMV_DescML ) 	
						AS [text()]
						--FROM ProfiliUtenteAttrib SUB
						from #ProfiliUtente_UserRole SUB
								inner join dbo.LIB_DomainValues with (nolock) on DMV_DM_ID = ''UserRole'' and DMV_Cod = attvalue 
								left outer join LIB_Multilinguismo with (nolock) on ML_KEY = DMV_DescML and ML_LNG = ''I''
						WHERE
							SUB.IdPfu = p.IdPfu
							--AND dztNome = ''UserRole'' 
							FOR XML PATH('''')  
			)	, 1,1,'''') as RuoloUtenteExcel


		,STUFF(
			(SELECT   
				'', '' + ISNULL(cast( Descrizione as nvarchar(500)),'''')
						AS [text()]
						--FROM ProfiliUtenteAttrib SUB
						from #ProfiliUtente_Profili SUB
								left outer join dbo.Profili_Funzionalita with (nolock) on attvalue = codice and Profili_Funzionalita.deleted=0
								--left outer join LIB_Multilinguismo with (nolock) on ML_KEY = cast( Descrizione as nvarchar(500)) and ML_LNG = ''I''
						WHERE
							SUB.IdPfu = p.IdPfu 
							--AND dztNome = ''Profilo'' 
							FOR XML PATH('''')  
			)	, 1,1,'''') as pfuprofiliExcel 		
				
			, DescSU.Descrizione as CampoTesto_1
			, DescPrimoLivello.Descrizione as CampoTesto_2
			, DescSecondoLivello.Descrizione as CampoTesto_3

		'
	END

	set @SQLCmd = @SQLCmd +
	'
			
		into #Temp2
		from #Temp p
	'
	--aggiungo left join per risolvere IL CAMPO StatoUtenti
	if @nIsExcel = 1	
	BEGIN
		set @SQLCmd = @SQLCmd +
			'
			inner join #Desc_Domini DescSU on DescSU.dominio=''StatoUtenti'' and DescSU.Codice = p.StatoUtenti
			inner join #Desc_Domini DescPrimoLivello on  DescPrimoLivello.dominio=''TIPO_AMM_ER'' and DescPrimoLivello.Codice = p.PrimolivelloStruttura
			inner join #Desc_Domini DescSecondoLivello on DescSecondoLivello.dominio=''TIPO_AMM_ER'' and DescSecondoLivello.Codice = p.TIPO_AMM_ER
				
			'
	END
--		select  ' + case when cast( @Top as varchar(10)) = '-1' then '' else ' top ' + cast( @Top as varchar(10))  end  + '
			
	set @SQLCmd = @SQLCmd +	
		'
		select 
			t.* , p.* 
				from 
					#Temp t left outer  join (select * from #Temp2 as p ) as p on p.idutente = t.idpfu

		'


set @SQLCmd=@SQLCmd + ' order by pfucognome , pfunomeutente , idpfu '

--print @SQLCmd
exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount







GO
