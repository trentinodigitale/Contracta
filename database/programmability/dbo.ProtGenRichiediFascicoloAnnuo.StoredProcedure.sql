USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ProtGenRichiediFascicoloAnnuo]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec ProtGenRichiediFascicoloAnnuo @idVProtGen , @IdUser , @tipoDoc , @linkedDoc , @fascicoloGenerale , @tipoDocCollegato ,@jumpCheck,  @contesto, @esitoRichiestaFascicolo output

CREATE PROCEDURE [dbo].[ProtGenRichiediFascicoloAnnuo] (
		 @idVProtGen varchar(50) , 
		 @IdUser int , 
		 @tipoDoc varchar(500),
		 @linkedDoc INT,
		 @fascicoloGenerale varchar(500),
		 @tipoDocCollegato varchar(500),
		 @jumpCheck varchar(500),
		 @contesto varchar(200),
		 @aoo varchar(200),
		 @output INT out)
AS
BEGIN

	declare @annoFascicolo varchar(100)
	declare @newid INT

	declare @descFascicolo varchar(500)
	declare @idConf INT

	SET @output = 0
	SET @idConf = -1
	SET @descFascicolo = NULL
	set @annoFascicolo = '-1'

	SELECT   @idConf = id
			,@descFascicolo = fascicolo
		from Document_protocollo_docER with(nolock) 
		where deleted = 0 and isnull(contesto,'') = @contesto and tipodoc = @tipoDoc and isnull(jumpCheck,'') = @jumpCheck and algoritmo = 'F002.1' and isnull(aoo,'') = isnull(@AOO,'') 

	--IF isnull(@fascicoloGenerale,'') <> '' and @idConf <> -1
	IF @idConf <> -1
	BEGIN

		IF isnull(@fascicoloGenerale,'') <> '' 
		BEGIN

			set @annoFascicolo =  dbo.GetColumnValue (@fascicologenerale, '.', 1)

			IF isnumeric(@annoFascicolo) <> 1 
			BEGIN
				set @annoFascicolo = '-1'
			END

		END

		-- Se l'anno del fascicolo non corrisponde con l'anno corrente
		IF cast(@annoFascicolo as int) <> year(getdate())
		BEGIN

			-- Se è stata già fatta la richiesta per questo fascicologenerale di partenza, esco.
			IF EXISTS ( select * from v_protgen_fascicoli with(nolock) where deleted = 0 and tipoDoc = @tipoDocCollegato and fascicoloOrigine = @fascicoloGenerale and isnull(fascicoloNuovo,'') = '' and isnull(aoo,'') = isnull(@AOO,'')  )
			BEGIN

				-- BLOCCO L'AVANZAMENTO DI STATO DEL RECORD. Tale semaforo viene ripulito sul chiamante ad ogni chiamata di questa stored
				IF EXISTS ( select * from v_protgen_dati with(nolock) where idheader = @idVProtGen and dzt_name = 'BLOCCA_AVANZAMENTO_STATO' )
				BEGIN 
						
					UPDATE v_protgen_dati 
						set value = 'IN-ATTESA-DI-FASCICOLO-ANNUALE' 
						where idheader = @idVProtGen and dzt_name = 'BLOCCA_AVANZAMENTO_STATO'

				END
				ELSE
				BEGIN
						
					INSERT v_protgen_dati( IdHeader, DZT_Name, Value, data )
									VALUES ( @idVProtGen, 'BLOCCA_AVANZAMENTO_STATO','IN-ATTESA-DI-FASCICOLO-ANNUALE' , getdate()) 

				END

				SET @output = 1
				return 0

			END

			-- inserisco la richiesta di nuovo protocollo ed esco dalla stored senza avanzare di stato del record
			INSERT INTO [v_protgen_fascicoli]
						([data]
						,[dataAssegnazione]
						,[deleted]
						,[fascicoloOrigine]
						,[fascicoloNuovo]
						,[idDoc]
						,[tipoDoc]
						,[errore]
						,[descFascicolo]
						,[aoo])
					VALUES
						(getdate()
						,NULL
						,0
						,@fascicoloGenerale
						,''
						,@linkedDoc
						,@tipoDocCollegato
						,''
						,@descFascicolo
						,@aoo)

			set @newid = SCOPE_IDENTITY()

			-- Schedulo la richiesta di fascicolo
			insert into CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
				values( @newid , @iduser , 'PROT_GEN' , 'RICHIESTA_FASCICOLO' )

			-- BLOCCO L'AVANZAMENTO DI STATO DEL RECORD. Tale semaforo viene ripulito sul chiamante ad ogni chiamata di questa stored
			IF EXISTS ( select * from v_protgen_dati with(nolock) where idheader = @idVProtGen and dzt_name = 'BLOCCA_AVANZAMENTO_STATO' )
			BEGIN 
						
				UPDATE v_protgen_dati 
					set value = 'IN-ATTESA-DI-FASCICOLO-ANNUALE' 
					where idheader = @idVProtGen and dzt_name = 'BLOCCA_AVANZAMENTO_STATO'

			END
			ELSE
			BEGIN
						
				INSERT v_protgen_dati( IdHeader, DZT_Name, Value, data )
								VALUES ( @idVProtGen, 'BLOCCA_AVANZAMENTO_STATO','IN-ATTESA-DI-FASCICOLO-ANNUALE' , getdate()) 

			END		

			SET @output = 1
			RETURN 0

		END

	END

END






GO
