USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_UPD_VALORE_OFFERTO_COSTO_FISSO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD_UPD_VALORE_OFFERTO_COSTO_FISSO] ( @idDoc int  ) as
begin

	
	--declare @idDoc   int
	--set @idDoc=81891
	declare @IdBando	int
	declare @Id_mod_Bando	int
	declare @Valore_Offerto	nvarchar(100)
	declare @Base_Asta	nvarchar(100)
	declare @Update as varchar(max)
	declare @CriterioFormulazioneOfferte as varchar(100)
	
	select @IdBando=LinkedDoc from ctl_doc where id=@idDoc

	--recupero criterioformulazioneofferte dal bando
	select @CriterioFormulazioneOfferte = CriterioFormulazioneOfferte from document_bando with (nolock) where idheader = @IdBando

	
	BEGIN
		--SE SONO PRESENTI LOTTI A COSTO FISSO PROCEDO AD INSERIRE NELLA COLONNA VALORE OFFERTO la BASE ASTA
		IF EXISTS ( select * from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando=@IdBando and CriterioAggiudicazioneGara='25532' )
		BEGIN


			select @Id_mod_Bando=id from ctl_doc where LinkedDoc=@IdBando and TipoDoc='CONFIG_MODELLI_LOTTI' and StatoFunzionale='Pubblicato'
			--Recupero i campi del modello Valore Offerto e Base Asta
			select @Base_Asta=value from CTL_DOC_Value where IdHeader=@Id_mod_Bando and DSE_ID='FORMULE' and DZT_Name='FieldBaseAsta'
			select @Valore_Offerto=value from CTL_DOC_Value where IdHeader=@Id_mod_Bando and DSE_ID='FORMULE' and DZT_Name='Operatore1'

			--solo se criterioformulazioneofferte uguale a percentuale 
			if @CriterioFormulazioneOfferte = '15537'
			begin
				set @Base_Asta = 0
			end

			set @Update ='update Document_MicroLotti_Dettagli set ' + @Valore_Offerto + ' = ' + @Base_Asta + ' from Document_MicroLotti_Dettagli D
						inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO DC on DC.idBando=' + cast ( @IdBando as varchar(50))  + ' and DC.N_Lotto=D.NumeroLotto and DC.CriterioAggiudicazioneGara=''25532''
						where idheader=' + cast(@idDoc as varchar(50) )
		
			--print @Update
			exec(@Update) 

		 END	
	END

END
GO
