USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_COPY_FROM_ISTANZA_AlboOperaEco]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[OLD_ISTANZA_COPY_FROM_ISTANZA_AlboOperaEco]( @idDoc as int , @oldIdDoc as int, @idpfu as int ) 
as
--@idDoc nuovo id
--@oldIdDoc id istanza precedente
--@idpfu -20 fisso per adesso
--riceve l'id della nuova istanza creata, il linkeddoc è il bando, prevdoc istanza precedente

declare @IdAzi int

declare @Valore nvarchar (4000)
declare @RagSoc		nvarchar( 500)
declare @NaGi nvarchar( 500)
declare @INDIRIZZOLEG nvarchar( 500)
declare @LOCALITALEG nvarchar( 500)
declare @CAPLEG nvarchar( 500)
declare @PROVINCIALEG nvarchar( 500)
declare @NUMTEL nvarchar( 500)
declare @NUMTEL2 nvarchar( 500)
declare @NUMFAX nvarchar( 500)
declare @EMail nvarchar( 500)
declare @PIVA nvarchar( 500)
declare @NomeRapLeg varchar(500)
declare @CognomeRapLeg varchar(500)
declare @CFRapLeg varchar(500)
declare @TelefonoRapLeg varchar(500)
declare @CellulareRapLeg varchar(500)
declare @EmailRapLeg varchar(500)
declare @RuoloRapLeg varchar(500)
--recupero azienda associata all'istanza
Select @IdAzi=azienda from CTL_DOC where id=@idDoc
--recupero tutti i valori
Select 	 @RagSoc=aziRagioneSociale 
		,@NaGi=aziIdDscFormasoc 
		,@INDIRIZZOLEG=aziIndirizzoLeg
		,@LOCALITALEG=aziLocalitaLeg 
		,@CAPLEG=aziCAPLeg
		,@PROVINCIALEG=aziProvinciaLeg
		,@NUMTEL=aziTelefono1
		,@NUMTEL2=aziTelefono2 
		,@NUMFAX=aziFAX
		,@EMail=aziE_Mail
		,@PIVA=aziPartitaIVA 
from Aziende where idazi = @IdAzi

--aggiorna i valori sulla nuova istanza
update CTL_DOC_Value set Value=@RagSoc  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'RagSoc' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@NaGi from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'NaGi' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@INDIRIZZOLEG  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'INDIRIZZOLEG' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@LOCALITALEG  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'LOCALITALEG' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@CAPLEG from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'CAPLEG' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@PROVINCIALEG  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'PROVINCIALEG' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@NUMTEL  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'NUMTEL' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@NUMTEL2  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'NUMTEL2' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@NUMFAX  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'NUMFAX' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@EMail  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'EMail' and DSE_ID='TESTATA'
update CTL_DOC_Value set Value=@PIVA  from CTL_DOC_Value where idHeader = @IdDoc and DZT_Name = 'PIVA' and DSE_ID='TESTATA'


execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'NomeRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'CognomeRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'LocalitaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'DataRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'CFRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'TelefonoRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'CellulareRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'EmailRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ResidenzaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ProvResidenzaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'IndResidenzaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'CapResidenzaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ProvinciaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'RuoloRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'NumProcura' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'DelProcura' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'NumRaccolta' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'codicefiscale' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'SettoriCCNL' , @IdDoc ,'DISPLAY_ABILITAZIONI' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ClasseIscriz' , @IdDoc ,'DISPLAY_ABILITAZIONI' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ANNOCOSTITUZIONE' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'SedeCCIAA' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'IscrCCIAA' , @IdDoc ,'TESTATA' 

execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'EmailRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'StatoRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'StatoResidenzaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'StatoResidenzaRapLeg2' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'StatoRapLeg2' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'LocalitaRapLeg2' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ProvResidenzaRapLeg2' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ResidenzaRapLeg2' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ProvinciaRapLeg' , @IdDoc ,'TESTATA' 
execute Upd_CTL_DOC_Value_DA_DMATTR_TRY @IdAzi, 'ProvinciaRapLeg2' , @IdDoc ,'TESTATA' 



---SE NON HO RECUPERATO CLASSI ISCRIZIONE DA DM_ATTRIBUTI PROVO A PRENDERLE DAL PREV DOC
IF NOT EXISTS ( select * from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' and ISNULL(value,'')<>'' )
BEGIN
	declare @previst as int
	set @previst=0
	select @previst=prevdoc from ctl_doc where id=@idDoc
	if @previst > 0
	BEGIN
		update CTL_DOC_Value set value=(Select value from CTL_DOC_Value where IdHeader=@previst and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' )
		where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' 
	END
END


---RIMUOVO LE CLASSIISCRIZ NON PRESENTI NEL DOMINIO 
DECLARE @classi_ok as varchar(MAX)
set @classi_ok='###'

select @classi_ok=@classi_ok + items + '###' from dbo.Split((select value from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz'),'###')
inner join ClasseIscriz on DMV_Cod=items and dmv_deleted=0

update CTL_DOC_Value set value=@classi_ok
 where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' 

declare @classi_OK_PATH as nvarchar(max)

set @classi_OK_PATH=dbo.RIPULISCE_CLASSIISCRIZ_NON_BUONE_BANDO ( @idDoc , @classi_ok )

 
---RIMUOVO LE CLASSIISCRIZ NON PRESENTI SUL BANDO

--declare @classi_bando as nvarchar(max)
--declare @classi_ist as nvarchar(max)
--declare @path_classi_bando as nvarchar(max)
--declare @path_classi_ist as nvarchar(max)
--declare @classi_OK_PATH as nvarchar(max)
--set @classi_OK_PATH='###'

--select @classi_bando=ClasseIscriz from Document_Bando where idHeader=(select linkeddoc from ctl_doc where id=@idDoc)
--select @classi_ist=value from CTL_DOC_Value  where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' 

----FACCIO 2 CURSORI A CASCATA PER VERIFICARE SE LE CLASSI INSERITE SUL DOCUMENTO VANNO BENE CON QUELLE DEL BANDO
--	declare CurProg Cursor Static for 

--		select DMV_Father as path_classi_ist
--			from dbo.split(@classi_ist,'###')
--				inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0		

--	open CurProg

--	FETCH NEXT FROM CurProg INTO @path_classi_ist
--		WHILE @@FETCH_STATUS = 0 
--			BEGIN	

--			declare CurProg2 Cursor Static for 
--				select DMV_Father as path_classi_bando
--					from dbo.split(@classi_bando,'###')
--						inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0

--				open CurProg2
--				FETCH NEXT FROM CurProg2 INTO @path_classi_bando
--					WHILE @@FETCH_STATUS = 0
--						BEGIN
--							if ( LEFT(@path_classi_ist,LEN(@path_classi_bando)) = @path_classi_bando )
--							BEGIN
						
--									set @classi_OK_PATH=@classi_OK_PATH + @path_classi_ist + '###'  
--									break;							

--							END
				
--				FETCH NEXT FROM CurProg2 INTO @path_classi_bando
--						END

--						CLOSE CurProg2
--						DEALLOCATE CurProg2

--	FETCH NEXT FROM CurProg  INTO @path_classi_ist
--			 END 

--	CLOSE CurProg
--	DEALLOCATE CurProg		

	--NELLA TEMP CI SONO I CODICI DELLE CLASSI CHE NON POSSO AVERE SULL'ISTANZA
	select distinct DMV_Cod into #temp
		from dbo.Split(@classi_OK_PATH,'###')
	inner join ClasseIscriz on DMV_Father=items

	set @classi_ok='###'

	select 
		@classi_ok=@classi_ok + DMV_Cod + '###' 
	from #temp

	update CTL_DOC_Value set value=@classi_ok
		where IdHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_Name='ClasseIscriz' 

	 drop table #temp
---FINE RIMUOVO LE CLASSIISCRIZ NON PRESENTI SUL BANDO

--select DSE_ID,MA_MOD_ID from dbo.LIB_DocumentSections
--inner join LIb_Models on MOD_ID=DSE_MOD_ID
--inner join LIb_ModelAttributes on MOD_ID=MA_MOD_ID 
--where MOD_ID like 'Istanza_albooperaeco%' and  MA_DZT_NAME='IscrCCIAA' 

--mi vado a recuperare l'allegato del Patto Integrità messo in configurazione e lo metto sulla table della firma e sull'istanza 
delete from CTL_DOC_SIGN where idheader=@idDoc
	insert into CTL_DOC_SIGN (IdHEader,F1_SIGN_ATTACH,F2_SIGN_HASH)
		select @idDoc,SIGN_ATTACH,SIGN_HASH from Document_Parametri_Abilitazioni DP
		inner join ctl_doc on idheader=id
		where DP.tipodoc='ALBO' and DP.deleted=0

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select @idDoc,'DISPLAY_ABILITAZIONI',0,'F1_SIGN_ATTACH',SIGN_ATTACH
			 from Document_Parametri_Abilitazioni DP
			inner join ctl_doc on idheader=id
			where DP.tipodoc='ALBO' and DP.deleted=0
	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select @idDoc,'DISPLAY_ABILITAZIONI',0,'F2_SIGN_HASH',SIGN_HASH
			 from Document_Parametri_Abilitazioni DP
			inner join ctl_doc on idheader=id
			where DP.tipodoc='ALBO' and DP.deleted=0
			        
--SE IL CAMPO IscrCCIAA non è un numerico lo svuoto in creazione
IF EXISTS ( Select * from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA' and ISNUMERIC(Left(Value,10))=0 ) 
BEGIN
	update CTL_DOC_Value set value=''
	where IdHeader=@idDoc and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA'
END











GO
