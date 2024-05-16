USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_ASTA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[BANDO_ASTA_CREATE_FROM_USER] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @Idazi as int
	
	declare @IdPfu as INT

	--set @Errore = ''
	
	-- cerca utenti di riferimento
	--IF NOT EXISTS (Select * from ELENCO_RESPONSABILI where idpfu =  @idUser and RUOLO in ('PO','RUP'))
	--BEGIN
	--	set @Errore='Per poter attivare la funzione e necessaria la presenza di un utente di riferimento responsabile a cui inviare il documento in approvazione'
	--END

	--if @Errore = '' 
	--begin
	
	--recupero azienda utente loggato
	set @Idazi=0
	select @Idazi=pfuidazi from profiliutente where idpfu=@IdUser and pfudeleted=0
	
	-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
	INSERT into 
		CTL_DOC ( IdPfu,  TipoDoc, Azienda , titolo , versione)
		values

			(@IdUser, 'BANDO_ASTA', @Idazi ,'Senza Titolo' , '2' )	


	set @id = SCOPE_IDENTITY()
		
	-- aggiunge il record sul bando				
	insert into Document_Bando 
		( idHeader , TipoProceduraCaratteristica,EvidenzaPubblica)
		values
			(	@id ,'Asta','0' )
			
		
	--aggiungo riga vuota nella tabella Document_dati_protocollo
	insert into Document_dati_protocollo
		(idHeader)
		values
		(@id)

	--aggiungo riga nella tabella document_Asta
	insert into document_Asta 
		( idHeader )
		values
		(	@id  )
		
	--end
		


	--if @Errore = ''
	--begin
		-- rirorna l'id della nuova procedura appena creata
		select @Id as id
	
	--end
	--else
	--begin
		-- rirorna l'errore
	--	select 'Errore' as id , @Errore as Errore
	--end
END



GO
