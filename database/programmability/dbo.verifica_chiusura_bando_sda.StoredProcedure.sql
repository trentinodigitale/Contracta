USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[verifica_chiusura_bando_sda]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[verifica_chiusura_bando_sda]
(
	@protocolloSDA VARCHAR(250) = ''
)
AS
BEGIN

	--LA STORED VIENE CHIAMATA DALLA LIB_SERVICES E LAVORA SU TUTTI GLI SDA( CHIAMATA PRIVA DI PARAMETRI )
	--SE LA STORED VIENE INVECE INVOCATA CON IL REGISTRO DI SISTEMA DI UNO SDA, PARAMETRO @protocolloSDA, VIENE FATTA LA VERIFICA DI CHIUSURA PER QUELLO
	--E NEL CASO QUESTO SDA NON POSSA ESSERE CHIUSO VIENE DATO IN OUTPUT, COME SELECT, IL MOTIVO DELLA MANCATA CHIUSURA

	SET NOCOUNT ON
	
	declare @motivazioneMancataChiusura as varchar(1000)
	declare @DATA_CONFRONTO as  datetime
	declare @id_SDA int

	--creo tabella temporanea degli SDA da esaminare
	SELECT  SDA.id , 		
		TipoBandoGara, 
		ProceduraGara, 
		SDA.DataInvio,
		SDA.StatoFunzionale, 
		SDA.Protocollo,
		isnull(SDA.DataScadenza,GETDATE())  as DATA_CONFRONTO
			INTO #SDADaEsaminare
		FROM ctl_doc SDA with(nolock)
			inner join Document_Bando b with(nolock) ON b.idHeader = SDA.id			
		WHERE SDA.tipodoc in ( 'BANDO_SDA') and SDA.deleted = 0 and SDA.StatoFunzionale not in ( 'Chiuso', 'InApprove', 'InLavorazione', 'Rifiutato', 'Revocato' , 'Sospeso')  
		and getdate() > isnull(SDA.DataScadenza,GETDATE())


	--se è richiesta una gara specifica 
	IF ( @protocolloSDA <> '' )
	BEGIN
		-- rimuovo dalla tabella temporanea tutte le altre
		DELETE FROM #SDADaEsaminare WHERE Protocollo <> @protocolloSDA 
	END

	IF ( @protocolloSDA <> '' ) AND NOT EXISTS ( select id from #SDADaEsaminare )
	BEGIN
		set @motivazioneMancataChiusura = 'La gara richiesta non verrà chiusa perchè ha uno stato funzionale fra Chiuso,InApprove,InLavorazione,Rifiutato,Revocato,Sospeso OPPURE non è stata raggiunta la "Presentare le domande di ammissione entro il:"'
	END

	DECLARE curs CURSOR STATIC FOR     		
		select Id ,DATA_CONFRONTO from  #SDADaEsaminare

	OPEN curs
	FETCH NEXT FROM curs INTO @id_SDA,@DATA_CONFRONTO
	----------------------------------------
	-- ITERO SUGLI SDA
	----------------------------------------
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--select @id_SDA,@DATA_CONFRONTO

		-----------------------------------------------
		-- traccio le istanze non valutate che sto per annullare
		------------------------------------------------
		insert into ctl_approvalsteps 
			(APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld) 
				select TipoDoc,id,'Invalidate','Instanza Annullata per chiusura automica del Bando alla scadenza','','base',idpfu,0 
					from CTL_DOC
						where TipoDoc like 'ISTANZA_SDA%' 
							and LinkedDoc=@id_SDA
							and Deleted=0
							and (  StatoDoc = 'Saved' or StatoFunzionale in ('InValutazione','AttesaIntegrazione') )
       
		-----------------------------------------------
		-- annullare le istanze non valutate ( salvate, inviate ed in valutazione )
		------------------------------------------------
		update CTL_DOC 
			set  StatoDoc='Invalidate' , StatoFunzionale = 'Annullato'
			where TipoDoc like 'ISTANZA_SDA%' 
				and LinkedDoc=@id_SDA
				and Deleted=0
				and (  StatoDoc = 'Saved' or StatoFunzionale in ('InValutazione','AttesaIntegrazione') )
       
	   -- mettere lo SDA a chiuso
	   UPDATE ctl_doc set StatoFunzionale = 'Chiuso' where id = @id_SDA
		
		UPDATE dati
				set DataChiusura =  GETDATE()
			from ctl_doc SDA
				inner join Document_Bando dati ON dati.idHeader = SDA.Id
			where SDA.id = @id_SDA

	FETCH NEXT FROM curs INTO @id_SDA,@DATA_CONFRONTO

	END  

	CLOSE curs   
	DEALLOCATE curs	

	-- se è stata richiesta la verifica di chiusura e non è stata chiusura la gara richiesta, do la motivazione in output
	IF @protocolloSDA <> '' and NOT EXISTS ( select * from #SDADaEsaminare )
	BEGIN
		select @motivazioneMancataChiusura as motivazione
	END

	drop table #SDADaEsaminare
END

GO
