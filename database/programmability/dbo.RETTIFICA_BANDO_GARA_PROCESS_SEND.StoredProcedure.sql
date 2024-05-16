USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_BANDO_GARA_PROCESS_SEND]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RETTIFICA_BANDO_GARA_PROCESS_SEND]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @idmsg INT
	declare @inviti as varchar(10)
	declare @idazi INT
	declare @motivaz_ret as Nvarchar(4000)
	declare @isubtype as varchar(10)
	declare @OLD_DataTermineQuesiti as varchar(19)
	declare @Old_DataPresentazioneRisposte as varchar(19)
	declare @Old_DataSeduta as varchar(19)
	declare @DataTermineQuesiti as varchar(19)
	declare @DataPresentazioneRisposte as varchar(19)
	declare @DataSeduta as varchar(19)
	declare @RichiestaQuesito as char(1)



	--recupero azienda del mittente
	select @idazi=pfuidazi from profiliUtente where idpfu=@IdUser and pfudeleted=0

	---recupero idmsg della gara 
	select @idmsg=LinkedDoc from ctl_doc where id=@idDoc

	---sentinella per capire se la gara prevede invitati
	select @inviti= case when TipoBandoGara =  '3' then 'si' 
					else 'no' end ,@RichiestaQuesito=RichiestaQuesito
		from document_bando  
		where idheader=@idmsg


	---Recupero la descrizione da anteporre alla descrizione
	--set @motivaz_ret = dbo.CNV('RETTIFICA_GARA_MSG_BANDO_GARA', 'I' )

	set @motivaz_ret = ''

	--recupero la motivazione messa sulla rettifica
	select @motivaz_ret=@motivaz_ret + '
		' + cast(Note as varchar(4000)) from ctl_doc where id=@idDoc

	--recupero le date da sostituire
	select @OLD_DataTermineQuesiti=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='OLD_DataTermineQuesiti'

	select @Old_DataPresentazioneRisposte=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='Old_DataPresentazioneRisposte'

	select @Old_DataSeduta=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='Old_DataSeduta'

	select @DataTermineQuesiti=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='DataTermineQuesiti'

	select @DataPresentazioneRisposte=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='DataPresentazioneRisposte'

	select @DataSeduta=Value 
		from CTl_DOC_VALUE 
			where idheader=@idDoc and DSE_ID='TESTATA'
				 and DZT_Name='DataSeduta'			 			 			 						 

	--faccio le replace al template 
	IF @RichiestaQuesito = '1'
	BEGIN
		set @motivaz_ret= replace(@motivaz_ret,'<OLD_DataTermineQuesiti>', convert(varchar(10),cast(@OLD_DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@OLD_DataTermineQuesiti as datetime),108))
		set @motivaz_ret= replace(@motivaz_ret,'<DataTermineQuesiti>', convert(varchar(10),cast(@DataTermineQuesiti as datetime),103) + ' ' + convert(varchar(8),cast(@DataTermineQuesiti as datetime),108))
	END

	set @motivaz_ret= replace(@motivaz_ret,'<Old_DataPresentazioneRisposte>', convert(varchar(10),cast(@Old_DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataPresentazioneRisposte as datetime),108))
	set @motivaz_ret= replace(@motivaz_ret,'<DataPresentazioneRisposte>', convert(varchar(10),cast(@DataPresentazioneRisposte as datetime),103) + ' ' + convert(varchar(8),cast(@DataPresentazioneRisposte as datetime),108))
	set @motivaz_ret= replace(@motivaz_ret,'<Old_DataSeduta>', convert(varchar(10),cast(@Old_DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@Old_DataSeduta as datetime),108))
	set @motivaz_ret= replace(@motivaz_ret,'<DataSeduta>', convert(varchar(10),cast(@DataSeduta as datetime),103) + ' ' + convert(varchar(8),cast(@DataSeduta as datetime),108))
	



	
	CREATE TABLE #TempDest  ( IdAzi  int ) ; 

	--ESEGUE LA STORED CHE RECUPERA EVENTUALI DESTINATARI
	insert into #TempDest
		exec DESTINATARI_NOTIFICHE_PROCEDURE  @idDoc 

	--se prevede trova record nella tempdest crea le comunicazioni
	--IF @inviti = 'si' 
	IF EXISTS ( Select idazi from #TempDest)
	BEGIN
		Insert into CTL_DOC (IdPfu,TipoDoc,StatoDoc,Data,Titolo,Body,
							Azienda,ProtocolloRiferimento,Fascicolo,Note,LinkedDoc,JumpCheck,Destinatario_Azi,idPfuInCharge , Caption)
				
			select	@IdUser,'PDA_COMUNICAZIONE_GARA','Saved',getdate(),
						'Comunicazione Rettifica gara Num. ' + c.Protocollo,c.Body,
						@idazi,c.Protocollo,c.Fascicolo,@motivaz_ret,@idDoc,'0-RETTIFICA_BANDO_GARA',d.IdAzi,@IdUser , 'Comunicazione Rettifica gara'
				from Ctl_doc c
					inner join document_bando b on b.idheader=c.id
					--inner join ctl_doc_destinatari d on d.idheader=c.id and d.seleziona='includi'
					cross join #TempDest d
					--inner join profiliUtente p on p.pfuidazi=d.idazi and p.pfudeleted=0
				where c.id = @idmsg

				
		--inserisco sulle singole comunicazioni gli allegati messi sulla proroga se presenti
		IF EXISTS (select * from CTL_DOC_ALLEGATI  where idHeader=@idDoc)
		BEGIN
			Insert into CTL_DOC_ALLEGATI (idHeader,Descrizione,Allegato)
				Select id,Descrizione,Allegato
					from CTL_DOC_ALLEGATI
						inner join CTL_DOC on LinkedDoc=@idDoc and Tipodoc='PDA_COMUNICAZIONE_GARA'
					where idHeader=@idDoc
		END
				
		--inserisco il dirigente su tutte le comunicazioni
		insert into ctl_doc_value
			select id,'DIRIGENTE',0,'UserDirigente',@IdUser 
				from ctl_doc 
				where LinkedDoc=@idDoc
					and  TipoDoc='PDA_COMUNICAZIONE_GARA'
		
	END


	SET NOCOUNT OFF
END




GO
