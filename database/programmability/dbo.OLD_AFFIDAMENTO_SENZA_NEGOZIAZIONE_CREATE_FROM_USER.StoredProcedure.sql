USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFFIDAMENTO_SENZA_NEGOZIAZIONE_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_AFFIDAMENTO_SENZA_NEGOZIAZIONE_CREATE_FROM_USER] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as int
	declare @IdAzi as int
	declare @Errore varchar(1000) = ''
	declare @pcp_VersioneScheda varchar(50)
	declare @valoreImportoLotto float
	declare @Modello_INTEROP varchar(500)
	declare @pcp_TipoScheda varchar(50)

	set @Modello_INTEROP = ''

	--Recupero l'azienda
	select 
		@IdAzi = pfuIdAzi
		from
			ProfiliUtente with(nolock)
		where idpfu = @IdUser

	--Vado sulla document_bando
	--select 
	--	@valoreImportoLotto = importobaseasta 
	--	from Document_bando with (nolock)
	--	where idheader = @idDoc

	--recupero la versione della PCP da una SYS
	set @pcp_VersioneScheda = '01.00.00'

	select @pcp_VersioneScheda = DZT_ValueDef  from LIB_Dictionary with (nolock) where dzt_name='SYS_VERSIONE_PCP'


	IF @Errore = ''

	BEGIN	
		set @Id = -1	
		
		if @Id = -1 
		begin
			--Creo il Record principale CTL_DOC con tipodoc AFFIDAMENTO_SENZA_NEGOZIAZIONE
			insert into CTL_DOC ( IdPfu,Titolo, TipoDoc, Azienda ,idPfuInCharge ,Destinatario_Azi,Destinatario_User, Versione) 
				values ( @IdUser,'', 'AFFIDAMENTO_SENZA_NEGOZIAZIONE', @IdAzi , @IdUser  ,NULL,NULL, '2')

			--Recupero l'id del documento appena creato
			set @Id = SCOPE_IDENTITY()

			--Creo il record nella Document_bando
			Insert into Document_Bando(idheader,TipoSoglia)
			select
				@Id,
				'sotto' as TipoSoglia

			--Creo il record per la tabella Document_PCP_Appalto
			Insert into Document_PCP_Appalto(idheader, pcp_TipoScheda,pcp_VersioneScheda)
			select
				@Id,
				'AD5',
				@pcp_VersioneScheda

			--Creo il record per la tabella Document_E_FORM_CONTRACT_NOTICE
			Insert into Document_E_FORM_CONTRACT_NOTICE(idheader, CN16_CODICE_APPALTO, cn16_CallForTendersDocumentReference_ExternalRef)
			select
				@Id as idHeader,
				lower(newid()) as CN16_CODICE_APPALTO,
				'https://dati.anticorruzione.it/superset/dashboard/appalti/'

			--Inserisco nella CTL_DOC value RigaZero
			insert into CTL_DOC_VALUE(idheader,DSE_ID,DZT_Name,value)
			select
				@id,
				'TESTATA_PRODOTTI' as DSE_ID,
				'RigaZero' as DZT_Name,
				'1' as Value

			--Inserisco la riga UserRUP vuota nella CTL_DOC_VALUE
			insert into CTL_DOC_VALUE(idheader,DSE_ID,Row,DZT_Name,value)
			select
				@id,
				'InfoTec_comune' as DSE_ID,
				0 as Row,
				'UserRUP' as DZT_Name,
				'' as Value

			--Inserisco nella CTL_DOC value isDescrizioneEditabile
			insert into CTL_DOC_VALUE(idheader,DZT_Name,value)
			select
				@id,
				'isDescrizioneEditabile' as DZT_Name,
				'1' as Value

			--Inserisco una riga nella Document_Microlotti_dettagli
			insert into Document_MicroLotti_Dettagli(idheader,tipodoc,numerolotto,numeroriga,voce,descrizione)
			select
				@id as idheader,
				'AFFIDAMENTO_SENZA_NEGOZIAZIONE' as tipodoc,
				1 as numerolotto,
				0 as numeroriga,
				--0 as numeroriga, --non funziona con riga a 0
				0 as voce,
				'Singolo lotto' as descrizione

			
			--Recupero dalla PCP_Appalto il tiposcheda
			select 
				@pcp_TipoScheda = isnull(pcp_TipoScheda,'')
				from Document_PCP_Appalto with(nolock) 
				where idheader = @id

			--per la prima versione delle schede AD utilizzo un modello CN16 senza attributi 
			if @pcp_VersioneScheda < '01.00.01'
			begin
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_EMPTY' 
			end
			else
			begin
				set @Modello_INTEROP = 'INTEROP_GARA_CN16_' + @pcp_TipoScheda
			end

			--Setto il modello da utilizzare nella SectionModel

			if @Modello_INTEROP <>'' and exists(select mod_id from lib_models with (nolock) where mod_id = @Modello_INTEROP)
			begin
			
				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
  					values( @Id , 'INTEROP_PCP' , @Modello_INTEROP )
			end

		end
	
	END

	
	IF @Errore = ''
	BEGIN
		select @Id as id
	END
	ELSE
	BEGIN
		select 'Errore' as id , @Errore as Errore
	END

END





GO
