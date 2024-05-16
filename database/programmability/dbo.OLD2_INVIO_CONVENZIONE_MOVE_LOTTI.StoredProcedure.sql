USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INVIO_CONVENZIONE_MOVE_LOTTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE   PROCEDURE [dbo].[OLD2_INVIO_CONVENZIONE_MOVE_LOTTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @nuova_conv as varchar(10)
	declare @idconv as INT
	declare @idconvpart as INT
	declare @idnew as INT
	declare @iddacopiare as INT
	declare @idp as INT
	declare @IdNewMod as int

	create table #tmp (idn int)

	set @nuova_conv='NO'
	
	select @idconvpart=linkedDoc from ctl_doc where id=@idDoc

	IF EXISTS (Select * from CTL_DOC_Value where IdHeader = @idDoc and DSE_ID='TESTATA' and DZT_Name = 'Nuova_Convenzione' and ISNULL(Value,0)='1' )
	BEGIN
		set @nuova_conv='SI'		
	END
	--Caso in cui devo creare una nuova convenzione
	IF @nuova_conv = 'SI'
	BEGIN
		----crea la nuova convenzione ed inserisce il riferimento sulla Ctl_doc_value al documento MOVE_LOTTI
		insert into #tmp
			EXEC CONVENZIONE_CREATE_FROM_NEW -1 , @IdUser 
		
		Insert into CTL_DOC_Value (IdHeader , DSE_ID , DZT_Name ,Value )
			values( (select idn from #tmp), 'INFO_AGGIUNTIVE','Id_doc_Trasferimento_Lotto',@idDoc )

	END
	--caso in cui devo creare una nuova integrazione alla convenzione
	ELSE
	BEGIN
		select @idconv=Value from CTL_DOC_Value where IdHeader = @idDoc and DSE_ID='TESTATA' and DZT_Name = 'Convenzione'
		----crea la nuova integrazione ed inserisce il riferimento sulla Ctl_doc_value al documento MOVE_LOTTI
		insert into #tmp
			EXEC CONVENZIONE_CREATE_FROM_CONVENZIONE @idconv , @IdUser
		
		Insert into CTL_DOC_Value (IdHeader , DSE_ID , DZT_Name ,Value )
			values( (select idn from #tmp ), 'INFO_AGGIUNTIVE','Id_doc_Trasferimento_Lotto',@idDoc)

	END


	----Trasferisco sul nuovo documento convenzione oppure integrazione i prodotti e i lotti
	---recupero id del documento appena generato
	Select @idnew=idn from #tmp
	-- Il nuovo documento integrazione alla convenzione ha come idpfu il valore idpfuincharge 
    --se non vuoto altrimenti idpfu della   convenzione di partenza
	If @nuova_conv <> 'SI'
	BEGIN
		update ctl_doc set IdPfu=(Select case when ISNULL(idPfuInCharge,'') <> '' then  idPfuInCharge else idpfu end from CTL_DOC where id= @idconv ) -- @idconvpart)
		where id=@idnew
	END

	--Se sono nel caso di Nuova Convenzione vado a precompilare alcuni campi della stessa
	IF @nuova_conv = 'SI'
	BEGIN
		--informzioni prodotti della convenzione
		insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
			select @idnew,DSE_ID,DZT_Name,Value
				from  CTL_DOC_Value 
				where idheader=@idconvpart and DSE_ID='TESTATA_PRODOTTI'

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name)
			select @idnew, CM.DSE_ID, MOD_Name
				from CTL_DOC_SECTION_MODEL CM with(nolock)
				inner join CTL_DOC C with(nolock) ON C.Id=@idconvpart
				inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=C.TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
			where IdHeader = @idconvpart and CM.DSE_ID=LIB_DocumentSections.DSE_ID

		

		--informzioni della convenzione
		--insert into Document_Convenzione (ID,DOC_Owner,DataCreazione,IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito)
		--	select @idnew,@IdUser,getdate(),IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito
		--		from document_convenzione
		--		where id=@idconvpart

		update U
			set 
				U.ID= @idnew
				, U.DOC_Owner= @IdUser
				, U.DataCreazione= getdate()
				, U.IdentificativoIniziativa= S.IdentificativoIniziativa
				, U.Macro_Convenzione= S.Macro_Convenzione
				, U.CIG_MADRE= S.CIG_MADRE
				, U.RichiestaFirma= S.RichiestaFirma
				, U.GestioneQuote= S.GestioneQuote
				, U.TipoConvenzione= S.TipoConvenzione
				, U.ConAccessori= S.ConAccessori
				, U.Valuta= S.Valuta
				, U.IVA= S.IVA
				, U.TipoImporto= S.TipoImporto
				, U.DataInizio= S.DataInizio
				, U.DataFine= S.DataFine
				, U.RichiediFirmaOrdine= S.RichiediFirmaOrdine
				, U.OrdinativiIntegrativi= S.OrdinativiIntegrativi
				, U.ImportoMinimoOrdinativo= S.ImportoMinimoOrdinativo
				, U.TipoScadenzaOrdinativo= S.TipoScadenzaOrdinativo
				, U.NumeroMesi= S.NumeroMesi
				, U.DataScadenzaOrdinativo= S.DataScadenzaOrdinativo
				, U.Merceologia= S.Merceologia
				, U.Ambito = S.Ambito

			from Document_Convenzione as U 
				INNER JOIN document_convenzione AS S on S.id=@idconvpart
				where U.id = @idnew
		

		--genero la copia del modello CONFIG_MODELLI per la nuova convenzione
		exec GENERA_MODELLO_GARA_CONVENZIONE   @idnew, @IdUser


		--genero i modelli per il nuovo documento CONFIG_MODELLI
		select @IdNewMod=ID from CTL_DOC where LinkedDoc=@idnew and TipoDoc='CONFIG_MODELLI'


		exec GENERA_MODELLI_CONTESTO @IdNewMod, @IdUser


	END




	---cursore per trasferire le righe sul nuovo documento
	declare CurProg Cursor Static for 
	
	Select D.id as iddacopiare 
		from ctl_doc C
			inner join document_convenzione_lotti L on L.idheader=C.id  and L.Seleziona='includi' 
			inner join document_microlotti_dettagli D on D.idheader=C.linkedDoc and D.NUmeroLOtto=L.NUmeroLOtto and D.StatoRiga in ('Trasferito')
		where C.id=@idDoc

	open CurProg

	FETCH NEXT FROM CurProg  INTO @iddacopiare
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,CODICE_REGIONALE )
			select @idnew , 'CONVENZIONE' as TipoDoc,'' as StatoRiga,'' as CODICE_REGIONALE
		
		set @idp = @@identity				

		-- ricopio tutti i valori
		exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@iddacopiare  , @idp , ',Id,IdHeader,TipoDoc,StatoRiga,CODICE_REGIONALE, '		
			
		FETCH NEXT FROM CurProg INTO @iddacopiare
	END 

	CLOSE CurProg
	DEALLOCATE CurProg


	---Trasferisco i lotti cosi come sono, successivamente uno step aggiorna il valori dei lotti
	Insert into Document_Convenzione_Lotti ( idHeader, Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo, SogliaSuperata, DataAlertSoglia)
		select @idnew , Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo, SogliaSuperata, DataAlertSoglia
			from Document_Convenzione_Lotti
			where idheader=@idDoc and Seleziona='includi' 
	
	
	drop table #tmp 


END




GO
