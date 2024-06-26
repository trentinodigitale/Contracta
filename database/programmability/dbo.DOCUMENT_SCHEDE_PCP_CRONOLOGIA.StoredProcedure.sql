USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_SCHEDE_PCP_CRONOLOGIA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DOCUMENT_SCHEDE_PCP_CRONOLOGIA] ( @DocName NVARCHAR(50) , @Section NVARCHAR(50) , @IdDoc INT , @idUser INT, @IdRow INT = 0 )
AS
BEGIN
	
	SET NOCOUNT ON
	
	declare @Idgara as int
	--recupero idgara da iddoc_scheda 

	if @IdRow =  0
	begin

		select  
			top 1 @IdGara = idheader 
			from 
				Document_PCP_Appalto_Schede	with (nolock)
			where 
				IdDoc_Scheda = @IdDoc and bDeleted=0

		--riotrno le righe di innesco della scheda 
		select * from 
		(
			select	
				SI.idRow as idRow,

				SC.IdDoc_Scheda as idRichiesta,

				case 
					when operazioneRichiesta <> 'esitoOperazione' then operazioneRichiesta
					else 'esito-operazione' -- Cambio l'output della vista senza modificare il codice per non rompere eventuali logiche collegate
				end as TipoDoc,
		
				statoRichiesta as Protocollo,
		
				dateIn as Data,
		
				DataExecuted as DataInvio,
		
				msgError as Titolo,

				--inputWS as Name,
				--outputWS as StatoFunzionale,

				case when inputWS = '' or inputWS is null then 'NONE' else '' end as [Name],
				case when outputWS = '' or outputWS is null then 'NONE' else '' end as [StatoFunzionale],

				--CASE 
				--	WHEN CHARINDEX('@@@', datoRichiesto) > 0 THEN 
				--		SUBSTRING(datoRichiesto, 1, CHARINDEX('@@@', datoRichiesto) - 1)
				--	ELSE 
				--		''
				--END as TipoScheda
				Tiposcheda
			from 
				Document_PCP_Appalto_Schede SC with (nolock) 
					inner join Services_Integration_Request SI with (nolock) on SI.idRichiesta = SC.idrow
			where 
				SC.IdDoc_Scheda=@IdDoc
				and integrazione in ( 'PCP' ,  'INTEROPERABILITA' )
				and operazioneRichiesta not in ('CreaScheda', 'esitoOperazioneConfermaScheda')

			union
			--ritorno le righe della Services_Integration_Request che hanno idirichiesta = id della gara
			select	
				SI.idRow as idRow,

				idRichiesta,

				case 
					when operazioneRichiesta <> 'esitoOperazione' then operazioneRichiesta
					else 'esito-operazione' -- Cambio l'output della vista senza modificare il codice per non rompere eventuali logiche collegate
				end as TipoDoc,
		
				statoRichiesta as Protocollo,
		
				dateIn as Data,
		
				DataExecuted as DataInvio,
		
				msgError as Titolo,

				--inputWS as Name,
				--outputWS as StatoFunzionale,

				case when inputWS = '' or inputWS is null then 'NONE' else '' end as [Name],
				case when outputWS = '' or outputWS is null then 'NONE' else '' end as [StatoFunzionale],

				CASE 
				WHEN CHARINDEX('@@@', datoRichiesto) > 0 THEN 
					SUBSTRING(datoRichiesto, 1, CHARINDEX('@@@', datoRichiesto) - 1)
				when CHARINDEX('@@@', datoRichiesto) = 0 THEN datoRichiesto
				ELSE 
					''
				END as TipoScheda
			from
				Services_Integration_Request SI with (nolock) 
			where 
				SI.idrichiesta =@IdGara
				and integrazione in ( 'PCP' ,  'INTEROPERABILITA' )
				and operazioneRichiesta not in ('CreaScheda', 'esitoOperazioneConfermaScheda')

		) V
	
		--A1 29 32 33
		--A2 29 32 33
		--A7_1_2
		--SC1 S3
		where 
			V.TipoScheda in ('A1_29','A1_32','A1_33','A2_29','A2_32','A2_33','SC1','S3')
			order by V.data desc
	end
	else

	begin

		--per controllo sicurezza quando scarico il payload
		select top 1 idrow from Services_Integration_Request with (nolock) where idRow=@IdRow

	end

END


GO
