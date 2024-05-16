USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RITIRA_OFFERTA_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  proc [dbo].[OLD_RITIRA_OFFERTA_CREATE_FROM_OFFERTA]( @iddocumento as int, @idPfu as int) 
as
BEGIN
	SET NOCOUNT ON
	declare @Errore as nvarchar(2000)
	declare @Id as int
	set @Errore=''
	set @Id=0
	
	--controllo sullo stato dell'offerta
	IF EXISTS (Select * from ctl_doc where id=@iddocumento and tipodoc='OFFERTA' and statodoc='Saved')
	BEGIN
		SET @Errore='Operazione non consentita per lo stato del documento Offerta'
	END

	-- Può fare il ritiro solo il proprietario dell'offerta, or su idpfu e idpfuincharge
	IF NOT EXISTS ( select id from ctl_doc with(nolock) where id = @iddocumento and ( idpfu = @idPfu or idPfuInCharge = @idPfu ) )
	BEGIN
		SET @Errore='Operazione consentita solo al proprietario del documento'
	END

	--cerca un documento precedente
	select @Id=id from ctl_doc with(nolock) where TipoDoc='RITIRA_OFFERTA' and Deleted=0 and LinkedDoc=@iddocumento

	--CREA il documento
	if @id=0 and  @Errore=''
	BEGIN

		insert into ctl_doc ( idpfu,TipoDoc,LinkedDoc,idPfuInCharge,Titolo,Fascicolo,Azienda,Destinatario_Azi,ProtocolloRiferimento,RichiestaFirma )
			select @idPfu,'RITIRA_OFFERTA',@iddocumento,@idPfu,'Ritiro Offerta Procotollo:' + Protocollo,Fascicolo,Azienda,Destinatario_Azi,ProtocolloRiferimento,RichiestaFirma
			from ctl_doc
			where id=@iddocumento

		set @Id=SCOPE_IDENTITY()

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @id,'FIRMA',0,'NomeUtente',pfuNome
				from ProfiliUtente
			 where IdPfu=@idPfu

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @id,'FIRMA',0,'RuoloUtente',vatValore_FT
				from ProfiliUtente
					inner join DM_Attributi on lnk=pfuIdAzi and dztNome='RuoloRapLeg'
			where IdPfu=@idPfu


	END


	if @Errore=''
	BEGIN		
		select @Id as id 
	END
	if @Errore <> ''
	BEGIN
		select 'ERRORE' as id , @Errore + '~~@TITLE=Attenzione~~@ICON=4'   as Errore
	END

END







GO
