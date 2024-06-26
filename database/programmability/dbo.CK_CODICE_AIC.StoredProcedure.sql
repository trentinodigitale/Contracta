USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_CODICE_AIC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[CK_CODICE_AIC]( @iduser int , @iddoc as int )
AS
begin
	declare @tipodoc as varchar(50)
	declare @Cod varchar(200)
	declare @model_name varchar(200)
	declare @descrizione_campo varchar(200)
	
	select @tipodoc=TipoDoc from ctl_doc with(nolock) where id=@iddoc
	
	IF @tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
	BEGIN
		--recupero modello bando associato
		select @Cod = b.TipoBando 
			from Document_Bando b where b.idHeader = @iddoc
		
		select @model_name=modellobando + '_LOTTI' from Document_Modelli_MicroLotti where codice=@Cod and Deleted=0		

	END  --FINE IF BANDO_GARA

	IF @tipodoc in ('CONVENZIONE' , 'CONVENZIONE_ADD_PRODOTTI' , 'CONVENZIONE_UPD_PRODOTTI' )
	BEGIN
		select @Cod = value
			from ctl_doc_value
				where idHeader = @iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_name='Tipo_Modello_Convenzione'		
		--recupero modello bando associato
		select @model_name='MODELLO_BASE_CONVENZIONI_' + @Cod + '_MOD_Convenzione'
		
	END --FINE IF CONVENZIONE
	
	IF @tipodoc in ('LISTINO_CONVENZIONE')
	BEGIN
		select @Cod = value
			from ctl_doc_value
				where idHeader = @iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_name='Tipo_Modello_Convenzione'
		
		--recupero modello bando associato
		select @model_name='MODELLO_BASE_CONVENZIONI_' + @Cod + '_MOD_PerfListino'
	
		
	END --FINE IF LISTINO_CONVENZIONE

	IF @tipodoc in ('LISTINO_ORDINI')
	BEGIN
		select @Cod = value
			from ctl_doc_value
				where idHeader = @iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_name='Tipo_Modello_Convenzione'
		
		--recupero modello bando associato
		select @model_name='MODELLO_BASE_CONVENZIONI_' + @Cod + '_MOD_ListinoOrdini'
	
		
	END --FINE IF LISTINO_ORDINI

	IF @tipodoc in ('LISTINO_ORDINI_OE')
	BEGIN
		select @Cod = value
			from ctl_doc_value
				where idHeader = @iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_name='Tipo_Modello_Convenzione'
		
		--recupero modello bando associato
		select @model_name='MODELLO_BASE_CONVENZIONI_' + @Cod + '_MOD_PerfListinoOrdini'
	
		
	END --FINE IF LISTINO_ORDINI

	IF @tipodoc in ('OFFERTA')
	BEGIN
		--recupero modello selezionato 
		select @Cod = b.TipoBando 
			from Document_Bando b 
			   inner join CTL_DOC d on b.idHeader = d.LinkedDoc
			where d.id = @iddoc

		--recupero modello bando associato
		set @model_name = 'MODELLI_LOTTI_' + @Cod + '_MOD_Offerta'
	
	END  --FINE IF OFFERTA


	IF iSNULL(@model_name,'')<>''
	BEGIN
		--VERIFICO SE PRESENTE EDITABILE IL CODICE AIC PER QUEL MODELLO		
		select @descrizione_campo=dbo.CNV_ESTESA (MA_DescML,'I') 
			from CTL_ModelAttributeProperties,CTL_ModelAttributes,LIB_DICTIONARY L
				where MAP_MA_MOD_ID=@model_name
					and MAP_MA_MOD_ID=MA_MOD_ID
					and MAP_MA_DZT_Name=MA_DZT_Name
					and MAP_Propety='Editable'
					and isnull(MAP_value,'0')='1'
					and MAP_MA_DZT_Name=DZT_NAME
					and DZT_NAME = 'CodiceAic' 	
	END

	--SE HO TROVATO LA DESCRIZIONE SIGNIFICA CODICE AIC PRESENTE SUL CONTESTO ED E' EDITABILE, QUINDI FACCIAMO LE VERIFICHE	
	IF ISNULL(@descrizione_campo,'') <> ''
	BEGIN
		update 
			Document_MicroLotti_Dettagli 
			set 
				EsitoRiga = isnull(EsitoRiga,'') + 
					case 
						when ISNULL(CodiceAIC,'') <> '' then
							case 								
								--VERIFICO CHE SIA 9 CIFRE
								when LEN(CodiceAIC) <> 9 then '<br>' + @descrizione_campo + ' deve essere di 9 cifre.'
								--se il codice comincia per "E" non deve essere controllato il contro-codice ma resta il controllo della lunghezza a 9 caratteri di cui i restanti otto sono cifre
								when SUBSTRING(CodiceAIC,1,1) = 'E' AND ISNUMERIC(SUBSTRING(CodiceAIC,2,8) ) = 0 then  ''
								--VERIFICO CHE SIA NUMERICO
								when SUBSTRING(CodiceAIC,1,1) <> 'E' and ISNUMERIC(CodiceAIC) = 0 then '<br>' + @descrizione_campo + ' sembra non essere un numero.'
								when SUBSTRING(CodiceAIC,1,1) <> 'E' and ( (	(2*substring(CodiceAIC,2,1)/10) + (2*substring(CodiceAIC,4,1)/10) + (2*substring(CodiceAIC,6,1)/10)
										+ (2*substring(CodiceAIC,8,1)/10) + (2*substring(CodiceAIC,2,1)%10) + (2*substring(CodiceAIC,4,1)%10)
										+ (2*substring(CodiceAIC,6,1)%10) + (2*substring(CodiceAIC,8,1)%10) + substring(CodiceAIC,1,1) 
										+ substring(CodiceAIC,3,1) + substring(CodiceAIC,5,1) + substring(CodiceAIC,7,1) ) % 10 ) <> substring(CodiceAIC,9,1) then '<br>' + @descrizione_campo + ' codice controllo non corretto.'
								else ''
							end
						else ''
					end
				where idheader=@iddoc and TipoDoc = @tipodoc
			
	END

	--FORMULA PRESENTE NEL FOGLIO
		--=+SE.ERRORE(SE([AIC]="";"";SE(LUNGHEZZA([AIC])<>9;"ERR: lunghezza<>9";SE(RESTO(QUOZIENTE(2*DESTRA(SINISTRA([AIC];2);1);10)+QUOZIENTE(2*DESTRA(SINISTRA([AIC];4);1);10)+QUOZIENTE(2*DESTRA(SINISTRA([AIC];6);1);10)+QUOZIENTE(2*DESTRA(SINISTRA([AIC];8);1);10)+
		--RESTO(2*DESTRA(SINISTRA([AIC];2);1);10)+RESTO(2*DESTRA(SINISTRA([AIC];4);1);10)+RESTO(2*DESTRA(SINISTRA([AIC];6);1);10)+RESTO(2*DESTRA(SINISTRA([AIC];8);1);10)+SINISTRA([AIC];1)+DESTRA(SINISTRA([AIC];3);1)+DESTRA(SINISTRA([AIC];5);1)+DESTRA(SINISTRA([AIC];7);1);10)=NUMERO.VALORE(DESTRA([AIC];1));"";"ERR: codice controllo non corretto")));"ERR: sembra non essere un numero")		
	---FINE FORMULA
	--CONTROLLO VALIDITA'
		--SINISTRA([AIC];2 le prime 2 cifre a sinistra
		--DESTRA([AIC];1 la prima cifre a destra
		--QUOZIENTE RISULTATO DIVISIONE
		--RESTO RESTO DELLA DIVISIONE
	--RESTO(
			--QUOZIENTE(2*DESTRA(SINISTRA([AIC];2);1);10) + 
			--QUOZIENTE(2*DESTRA(SINISTRA([AIC];4);1);10) +
			--QUOZIENTE(2*DESTRA(SINISTRA([AIC];6);1);10) +
			--QUOZIENTE(2*DESTRA(SINISTRA([AIC];8);1);10) +
			--RESTO(2*DESTRA(SINISTRA([AIC];2);1);10) + 
			--RESTO(2*DESTRA(SINISTRA([AIC];4);1);10) +
			--RESTO(2*DESTRA(SINISTRA([AIC];6);1);10) + 
			--RESTO(2*DESTRA(SINISTRA([AIC];8);1);10) +
			--SINISTRA([AIC];1) + 
			--DESTRA(SINISTRA([AIC];3);1) + 
			--DESTRA(SINISTRA([AIC];5);1) + 
			--DESTRA(SINISTRA([AIC];7);1);10
		 --) = NUMERO.VALORE(DESTRA([AIC];1))
	--FINE CONTROLLO VALIDITA'
end

GO
