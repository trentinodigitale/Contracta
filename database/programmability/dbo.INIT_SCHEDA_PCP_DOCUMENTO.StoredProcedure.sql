USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INIT_SCHEDA_PCP_DOCUMENTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[INIT_SCHEDA_PCP_DOCUMENTO]  ( @IdDoc int , @Idpfu int, @TipoDocSource varchar(100) )
AS
BEGIN
	
	--SE SONO SULLE GARE (BANDO_GARA,BANDO_SEMPLIFICATO)
	--CHIAMO LA VECCHIA INIT
	if @TipoDocSource in ('BANDO_GARA','BANDO_SEMPLIFICATO')
	BEGIN
		EXEC INIT_SCHEDA_PCP_GARA @IdDoc,@Idpfu
	END
	
	declare @pcp_VersioneScheda as varchar(50)
	declare @pcp_TipoScheda as nvarchar(200)
	declare @Modello_INTEROP_PCP as varchar(100)
	declare @Modello_INTEROP as varchar(100)

	--SE SONO SU ODC FACCIO COSE SPECIFICHE PER ODC
	if @TipoDocSource in ('ODC')
	BEGIN

		--SCHEDA AD4
		declare @Modello_INTEROP_PRODOTTI as varchar(200)
		declare @Modello_PRODOTTI_ODC as varchar(200)
		declare @Modello_PRODOTTI_ODC_PCP as varchar(200)

		set @pcp_VersioneScheda = '01.00.00'
		select @pcp_VersioneScheda = DZT_ValueDef  from LIB_Dictionary with (nolock) where dzt_name='SYS_VERSIONE_PCP'

		set @pcp_TipoScheda = 'AD4'
		

		if not exists (select idrow from Document_PCP_Appalto with (nolock) where idHeader= @IdDoc )
		begin
			INSERT INTO Document_PCP_Appalto 
				( idHeader,pcp_TipoScheda, pcp_VersioneScheda)
				values 
				( @IdDoc , @pcp_TipoScheda, @pcp_VersioneScheda)

		end
		else
		begin
			--aggiorno il tipo e la versione della scheda
			update Document_PCP_Appalto 
				set 
					pcp_TipoScheda =@pcp_TipoScheda , pcp_VersioneScheda=@pcp_VersioneScheda  
				where	
					idHeader = @IdDoc 
		
		end

		delete CTL_DOC_SECTION_MODEL where IdHeader = @IdDoc and DSE_ID in ('INTEROP_PCP','INTEROP')

		--GESTISCO IL MODELLO PER LA SEZIONE 'INTEROP_PCP'
		set @Modello_INTEROP_PCP = 'INTEROP_PCP_GARA_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda
		if not exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PCP)
		BEGIN
			set @Modello_INTEROP_PCP = 'INTEROP_PCP_GARA_' + @pcp_TipoScheda
		END

		if @Modello_INTEROP_PCP <>'' and exists(select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PCP)
		BEGIN
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdDoc , 'INTEROP_PCP' , @Modello_INTEROP_PCP )
		END

		--GESTISCO IL MODELLO PER LA SEZIONE 'INTEROP'
		set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY' 
		if @pcp_VersioneScheda >= '01.00.01'
		BEGIN
			set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda
			if not exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP)
			begin
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY'
			end
		END
		
		if @Modello_INTEROP <>'' and exists(select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP)
		begin
			
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  				values( @IdDoc , 'INTEROP' , @Modello_INTEROP )
		end

		--VADO AD AGGIUNGERE GLI ATTRIBUTI DI GRIGLIA DELLA SCHEDA AD4, se esiste,  AL MODELLO DEI PRODOTTI
		--UTILIZZATO SULL'ODC sezione PRODOTTI
		set @Modello_INTEROP_PRODOTTI ='MODELLO_ATTRIBUTI_INTEROPERABILITA_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda
		if not exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PRODOTTI)
		BEGIN
			set @Modello_INTEROP_PRODOTTI = 'MODELLO_ATTRIBUTI_INTEROPERABILITA_' + @pcp_TipoScheda
		END

		--SE ESISTE IL MODELLO PRODOTTI DELLE COLONNE AGG DELLA SCHEDA AD4
		if exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PRODOTTI)
		BEGIN
			--recupero modello prodotti dell'ODC
			select @Modello_PRODOTTI_ODC=mod_name from CTL_DOC_SECTION_MODEL with (nolock) where IdHeader=@IdDoc and dse_id='PRODOTTI'

			--SE IL MODELLO DI SEZIONE NON E' QUELLO SPECIALIZZATO CON GLI ATTRIB DELLA SCHEDA
			--LO GENERO
			IF right(@Modello_PRODOTTI_ODC,19) <> '_MOD_Ordinativo_AD4'
			BEGIN
				set @Modello_PRODOTTI_ODC_PCP = @Modello_PRODOTTI_ODC + '_' + @pcp_TipoScheda 
				--SE QUESTO MODELLO DEFINITIVO CON GLI ATTRIBTUI AGGIUNTIVI DELLA SCHEDA AD4 NON ESISTE LO CREO
				if not exists (select mod_id from ctl_models with (nolock) where mod_id=@Modello_PRODOTTI_ODC_PCP)
				BEGIN
					--creo il modello per copio dall'originale
					exec CopiaModelloCTL @Modello_PRODOTTI_ODC_PCP,@Modello_PRODOTTI_ODC,'MODELLO_BASE_CONVENZIONI_AD4'

					declare @Prefix_NomeModello as varchar(200)
					set @Prefix_NomeModello = REPLACE(@Modello_PRODOTTI_ODC_PCP,'_MOD_Ordinativo_AD4' ,'')
				
					--al nuovo modello aggiungo le colonne del modello di scheda AD4
					exec CONCATENA_MODELLO_INTEROPERABILITA  @Prefix_NomeModello , 'MOD_Ordinativo_AD4'   ,  @idDoc , 'MODELLO_BASE_CONVENZIONI_AD4' , @Modello_INTEROP_PRODOTTI
				END
			
				--CAMBIO MODELLO SULL'ODC PER LA SEZIONE PRODOTTI SETTANDO QUELLO CON GLI ATTRIB AGGIUNTIVI DELLA SCHEDA AD4
				update 
					CTL_DOC_SECTION_MODEL
						set MOD_Name=@Modello_PRODOTTI_ODC_PCP
					where IdHeader=@IdDoc and dse_id='PRODOTTI'
	
			END

		END

	END

	if @TipoDocSource in ('ODA')
	BEGIN

		--SCHEDA AD5
		set @pcp_VersioneScheda = '01.00.00'
		select @pcp_VersioneScheda = DZT_ValueDef  from LIB_Dictionary with (nolock) where dzt_name='SYS_VERSIONE_PCP'

		set @pcp_TipoScheda = 'AD5'
		
		IF not exists (select idrow from Document_PCP_Appalto with (nolock) where idHeader= @IdDoc )
		BEGIN

			INSERT INTO Document_PCP_Appalto ( idHeader,pcp_TipoScheda, pcp_VersioneScheda)
				VALUES ( @IdDoc , @pcp_TipoScheda, @pcp_VersioneScheda)

		END
		ELSE
		BEGIN

			--aggiorno il tipo e la versione della scheda
			UPDATE Document_PCP_Appalto 
				SET pcp_TipoScheda =@pcp_TipoScheda , 
					pcp_VersioneScheda=@pcp_VersioneScheda  
				WHERE idHeader = @IdDoc 
		
		END

		DELETE CTL_DOC_SECTION_MODEL where IdHeader = @IdDoc and DSE_ID in ('INTEROP_PCP','INTEROP')

		--GESTISCO IL MODELLO PER LA SEZIONE 'INTEROP_PCP'
		set @Modello_INTEROP_PCP = 'INTEROP_PCP_GARA_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda
		IF not exists (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP_PCP)
		BEGIN
			SET @Modello_INTEROP_PCP = 'INTEROP_PCP_GARA_' + @pcp_TipoScheda
		END

		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			VALUES ( @IdDoc , 'INTEROP_PCP' , @Modello_INTEROP_PCP )

		--GESTISCO IL MODELLO PER LA SEZIONE 'INTEROP'
		SET @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda + '_DAL_' + @pcp_VersioneScheda
		IF NOT EXISTS (select mod_id from lib_models with (nolock) where mod_id=@Modello_INTEROP)
		BEGIN
			set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY'
		END

	END --if @TipoDocSource in ('ODA')


END






GO
