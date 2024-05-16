USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_NUOVA_PROCEDURA_CREATE_FROM_rdo]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_NUOVA_PROCEDURA_CREATE_FROM_rdo] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)

	
	declare @IdPfu as INT

	set @Errore = ''
	
	-- cerca utenti di riferimento
	IF NOT EXISTS (Select * from ELENCO_RESPONSABILI where idpfu =  @idUser and RUOLO in ('PO','RUP'))
	BEGIN
		set @Errore='Per poter attivare la funzione e necessaria la presenza di un utente di riferimento responsabile a cui inviare il documento in approvazione'
	END

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
					--,cast( pfuidazi as varchar) + '#' + '\0000\0000' as DirezioneEspletante
					--,idpfu as UserRUP
					,'Nuova RdO'
				from profiliutente 
				WHERE idpfu = @IdUser

		set @id = @@identity
		
		-- aggiunge il record sul bando				
		insert into Document_Bando ( idHeader ,  TipoProceduraCaratteristica , DirezioneEspletante , EvidenzaPubblica)
			select 
					@id 
					--,cast( pfuidazi as varchar) + '#' + '\0000\0000' as StrutturaAziendale
					,'RDO'
					,cast( pfuidazi as varchar) + '#' + '\0000\0000' as DirezioneEspletante
					, '0'
					
					--,idpfu as UserRUP
				
				from profiliutente 
				WHERE idpfu = @IdUser

		insert into Document_Bando_Riferimenti ( idHeader, idPfu  ) 
			values( @id , @IdUser ) 

		-- aggiunge i modelli personalizzati pr gestire le RDO
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'TESTATA' , 'BANDO_GARA_TESTATA_RDO' )


		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'CRITERI' , 'NUOVA_PROCEDURA_CRITERI_RDO' )

	
		-- NON DEVO PIU' FARLO. NON E' PIU PREVISTA LA DOPPIA FASCICOLAZIONE
		-- SE E' ATTIVO IL PROTOCOLLO GENERALE INSERISCO UN MODELLO DINAMICO PER L'RDO SPECIFICO PER I DATI DI PROTOCOLLO.
		--IF EXISTS ( select id from LIB_Dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and DZT_ValueDef = 'YES' )
		--BEGIN
		--	INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
		--		VALUES ( @id , 'PROTOCOLLO' , 'DOCUMENT_DATI_PROTOCOLLO_RDO' )
		--END
		
		--inserisco soglia importo forniture dal documento parametri RDO
		insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_forniture',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='1'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'

		--inserisco soglia importo servizi dal documento parametri RDO
		insert into CTL_DOC_VALUE (idheader,DSE_ID,DZT_NAME,VALUE)
			select 	@id,'PARAMETRI','Importo_servizi',c2.value
				from ctl_doc
				inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DETTAGLI' and c1.dzt_name='Tipologia' and c1.Value='3'
				inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DETTAGLI' and c2.dzt_name='Importo'  and C1.Row=C2.Row
			where tipodoc='PARAMETRI_RDO' and deleted=0 and StatoFunzionale='Confermato'
		
	end
		
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END


















GO
