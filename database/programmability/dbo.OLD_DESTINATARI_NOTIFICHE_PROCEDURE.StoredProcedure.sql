USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DESTINATARI_NOTIFICHE_PROCEDURE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[OLD_DESTINATARI_NOTIFICHE_PROCEDURE] ( @iddoc int , @contesto  as varchar(200) = '' ) as
BEGIN
	set nocount ON	

	--declare @iddoc INT
	--SET @iddoc=326714
	declare @tipo_operazione as varchar(200)
	declare @TipoBando as varchar(100)	
	declare @DestinatariNotifica as varchar(100)
	declare @DataPresentazioneRisposta as datetime
	declare @IdBando INT
	
	IF @contesto = 'QUESITO' 
	BEGIN 
		select 			
			 @TipoBando=TipoBandoGara,		 
			 @DestinatariNotifica=ISNULL(DestinatariNotifica,'2'), --in assenza viene assunto come default  Chi ha inviato Quesito / Risposta
			 @IdBando=C.ID_ORIGIN,
			 @DataPresentazioneRisposta=DataScadenzaOfferta
			 from Document_Chiarimenti C with(nolock) 
				inner join Document_Bando DB with(nolock)  on DB.idHeader=C.ID_ORIGIN				
			 where id =@iddoc
	END
	ELSE
	BEGIN
		select 			
			 @TipoBando=TipoBandoGara,		 
			 @DestinatariNotifica=ISNULL(DestinatariNotifica,'2'), --in assenza viene assunto come default  Chi ha inviato Quesito / Risposta
			 @IdBando=C.linkeddoc,
			 @DataPresentazioneRisposta=ISNULL(CV.value,DataScadenzaOfferta)
			 from ctl_doc C with(nolock) 
				inner join Document_Bando DB with(nolock)  on DB.idHeader=C.LinkedDoc
				left join ctl_doc_value CV  with(nolock) on CV.IdHeader=C.id and DSE_ID='TESTATA' and DZT_Name='DataPresentazioneRisposte' and value <> ''
			 where id =@iddoc
	END

	
	
	if @TipoBando = '3'  --Tutti gli invitati
	begin
		-- per gli inviti se nella colonna seleziona c'è null va bene lo stesso come se fosse includi
		select distinct Idazi from ctl_doc_destinatari with (nolock) where idheader=@IdBando and isnull(Seleziona,'includi')='includi'
	end
	else
	begin
		--Il comportamento cambia in funzione della scelta del “Destinatari Notifica”
			
		--"Partecipanti dopo scadenza termini" si prende come data termine di presentazione Risposta 
		--oppure nei contesti dove prevista la nuova la data presentazione Risposta 
		if @DestinatariNotifica = '1' 
		BEGIN
			select distinct idazi 
				from ctl_doc_destinatari with (nolock) 
					inner join ctl_doc with (nolock) on linkedDoc=idheader and Tipodoc in ( 'OFFERTA' , 'OFFERTA_ASTA' ,'MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE') and azienda=idazi and Statodoc='Sended' and StatoFunzionale='Inviato' and Deleted = 0
				where idheader = @IdBando and GETDATE() > @DataPresentazioneRisposta
		END
		--b.	Chi ha inviato Quesito / Risposta
		--Vengono presi in considerazione tutti gli OE che hanno manifestato interesse o inviando risposta o sottoponendo un quesito.
		if @DestinatariNotifica = '2' 
		BEGIN
			select distinct idazi 
				from ctl_doc_destinatari with (nolock) 
					inner join ctl_doc with (nolock) on linkedDoc=idheader and Tipodoc in ( 'OFFERTA' , 'OFFERTA_ASTA' ,'MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE') and azienda=idazi and Statodoc='Sended' and StatoFunzionale='Inviato' and Deleted = 0
				where idheader = @IdBando 
									
			union
				
			select distinct P.pfuIdAzi 
				from Document_Chiarimenti with (nolock) 
					inner join ProfiliUtente P with (nolock) on P.IdPfu=UtenteDomanda and P.pfuDeleted=0 and  P.pfuVenditore=1 and P.PfuProfili like '%S%'
				where ID_ORIGIN = @IdBando 
		END		
			
	end
	

END



GO
