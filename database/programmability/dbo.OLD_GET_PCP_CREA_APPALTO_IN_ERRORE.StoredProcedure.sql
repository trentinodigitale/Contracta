USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_GET_PCP_CREA_APPALTO_IN_ERRORE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_GET_PCP_CREA_APPALTO_IN_ERRORE] ( @idUser int , @param varchar(max)='')
AS
BEGIN
	
	--@param se passato contiene id agara

	SET NOCOUNT ON
	declare @idGara as int
	declare @CF_RUP as varchar(100)
	declare @CF_Ente as varchar(100)
	declare @Pfunome as nvarchar(500)
	declare @userLoa as int
	declare @Canale  as varchar(30)
	declare @idService as int
	declare @msgError as nvarchar(max)
	declare @Output_WS_PCP as nvarchar(max)
	declare @DataLast_SPID as varchar(30)
	DECLARE @DateLastRequest as varchar(30)

	--VARIABILE TABLE 
	DECLARE @ListaGareErrore TABLE
		(
		 IdGara int, 
		 Titolo nvarchar(100), 
		 Protocollo varchar(100),
		 CodiceFiscaleEnte varchar(100),
		 CodiceFiscaleRup varchar(100),
		 NominativoRup varchar(500),
		 LOA int,
		 Canale  varchar(100),
		 UltimoAccessoSPID  varchar(100),
		 IdEleborazione  int,
		 MsgError  nvarchar(max),
		 OutputWS  nvarchar(max),
		 DataUltimarichiesta varchar(100)
		) 

	set @userLoa = null

	If @param = '' 
	begin
		--recupero tutte le gare con "crea-appalto" in errore
		--che non hanno un crea-appalto andato bene
		select 
			idrichiesta
				into #Temp_Gare_PCP_InErrore
		from 
			services_integration_request with (nolock)
		where
			operazionerichiesta='crea-appalto' and integrazione='PCP' 
			and msgerror <> '' and statoRichiesta='elaborato'

		--recupero le gare che hanno un cra appalto andato bene
		select 
			idrichiesta 
				into #Temp_Gare_PCP_OK
			from 
				services_integration_request with (nolock)
			where  
				operazionerichiesta='crea-appalto' and statorichiesta='Elaborato' and msgerror=''
		
		--metto in una una nuova temp le gare in errore senza esito Ok
		select 
			distinct
			Gare_Err.idrichiesta 
				into #Temp_Gare_PCP_SoloInErrore
			from 
				#Temp_Gare_PCP_InErrore Gare_Err
					left join #Temp_Gare_PCP_OK  Gare_OK on Gare_OK.idRichiesta = Gare_Err.idRichiesta
			where
				Gare_OK.idRichiesta is null
		

		--faccio un cursore per tutte le gare in errore

		DECLARE crsGareErr CURSOR STATIC FOR 
		
			select idrichiesta from #Temp_Gare_PCP_SoloInErrore

		OPEN crsGareErr
			
		FETCH NEXT FROM crsGareErr INTO @idGara
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
			--recupero RUP della gara
			select 
				@CF_RUP=pfuCodiceFiscale ,
				@Pfunome=pfunome
				from 
					CTL_DOC_Value Rup with (nolock) 
						inner join ProfiliUtente P with (nolock) on P.IdPfu = Rup.value

				where Rup.IdHeader = @idGara and Rup.DSE_ID='InfoTec_comune' and Rup.DZT_Name='UserRUP'

			--recupero LOA e CANALE accesso spid
			if @CF_RUP <> ''
			begin
				select
					top 1 
						@userLoa=LOA, @Canale=Canale,@DataLast_SPID= convert(varchar(20),datainsrecord,120)
					from 
						CTL_LOG_SPID with (nolock) where HTTP_FISCALNUMBER=@CF_RUP
						order by 1 desc
			end

			--recupero codice fiscale ente
			select @CF_Ente	= vatValore_ft
				from CTL_DOC with (nolock)
					inner join DM_Attributi with (nolock) on lnk=azienda and dztNome='codicefiscale'
				where Id = @idGara


			--recupero ultimo errore pcp sulla gara
			select top 1 
				@idService = idrow,
				@Output_WS_PCP = outputWS,
				@msgError = msgerror,
				@DateLastRequest = convert(varchar(20),DateIn,120) 
				from 
					services_integration_request with (nolock)
				where
					idrichiesta = @idGara 
					and operazionerichiesta='crea-appalto' and integrazione='PCP' 
					and msgerror <> '' and statoRichiesta='elaborato'
				order by 1 desc
					
				
			insert into @ListaGareErrore
			 ( IdGara , Titolo , Protocollo , CodiceFiscaleEnte, CodiceFiscaleRup , NominativoRup , LOA ,
					Canale ,UltimoAccessoSPID , IdEleborazione , MsgError ,	 OutputWS,DataUltimarichiesta )
			select 
				@idGara as IdGara,G.Titolo,G.Protocollo,@CF_Ente as CodiceFiscaleEnte , @CF_RUP as CodiceFiscaleRup,@Pfunome as NominativoRup,@userLoa as LOA,
				@Canale as Canale,@DataLast_SPID as UltimoAccessoSPID,@idService as IdEleborazione,@msgError as MsgError,@Output_WS_PCP as OutputWS
				,@DateLastRequest as DataUltimarichiesta
				from 
					ctl_doc G with (nolock)
				where
					G.id=@idGara


		FETCH NEXT FROM crsGareErr INTO @idGara
		END

		CLOSE crsGareErr 
		DEALLOCATE crsGareErr 

		
		drop table #Temp_Gare_PCP_InErrore
		drop table #Temp_Gare_PCP_OK
		drop table #Temp_Gare_PCP_SoloInErrore

		select * from @ListaGareErrore 
			order by 1 asc

	end
	else
	begin
		select 'pippo' as id	
	end

END
GO
