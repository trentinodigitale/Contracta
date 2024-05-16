USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NUOVA_PROCEDURA_CREATE_FROM_ACCORDOQUADRO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[OLD2_NUOVA_PROCEDURA_CREATE_FROM_ACCORDOQUADRO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)

	
	declare @IdPfu as INT

	set @Errore = ''
	
	-- cerca utenti di riferimento
	--IF NOT EXISTS (Select * from ELENCO_RESPONSABILI where idpfu =  @idUser and RUOLO in ('PO','RUP'))
	--BEGIN
	--	set @Errore='Per poter attivare la funzione e necessaria la presenza di un utente di riferimento responsabile a cui inviare il documento in approvazione'
	--END

	if @Errore = '' 
	begin
	
	
		-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted , StrutturaAziendale , Caption)
			select 
					idpfu ,
					'BANDO_GARA',
					pfuidazi as Azienda ,
					1
					,cast( pfuidazi as varchar) + '#' + '\0000\0000' as StrutturaAziendale
					--,cast( pfuidazi as varchar) + '#' + '\0000\0000' as DirezioneEspletante ?????
					--,idpfu as UserRUP
					,'Nuovo Accordo Quadro'
				from profiliutente 
				WHERE idpfu = @IdUser

		set @id = @@identity
		
		-- aggiunge il record sul bando				
		insert into Document_Bando ( idHeader ,  TipoSceltaContraente , DirezioneEspletante , EvidenzaPubblica, ModalitadiPartecipazione , ProceduraGara, TipoBandoGara)
			select 
					@id 
					,'ACCORDOQUADRO'
					,cast( pfuidazi as varchar) + '#' + '\0000\0000' as DirezioneEspletante
					, '1'
					,'16308'
					,'15476'
					,'2'
				from profiliutente 
				WHERE idpfu = @IdUser

		insert into Document_Bando_Riferimenti ( idHeader, idPfu  ) 
			values( @id , @IdUser ) 

		-- aggiunge i modelli personalizzati pr gestire le RDO
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'TESTATA' , 'BANDO_GARA_TESTATA_ACCORDOQUADRO' )
		
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'CRITERI' , 'NUOVA_PROCEDURA_CRITERI_ACCORDOQUADRO' )
		
		insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			values( @id , 'InfoTec_comune' , 'UserRUP' , cast(@IdUser as varchar(20)) )
			
		
		
	end
		


	if @Errore = ''
	begin
		-- rirorna l'id della nuova procedura appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END




















GO
