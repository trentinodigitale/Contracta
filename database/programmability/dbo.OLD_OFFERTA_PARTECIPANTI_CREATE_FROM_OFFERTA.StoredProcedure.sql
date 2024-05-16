USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OFFERTA_PARTECIPANTI_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_OFFERTA_PARTECIPANTI_CREATE_FROM_OFFERTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdMittente as int
	declare @IdAziMittente as int
	declare @NomeOfferta as nvarchar(150)
	declare @ProtocolloOfferta as varchar(50)
	declare @Oggetto as nvarchar(4000)
	declare @ProtocolloBando as varchar(50)
	declare @Fascicolo as  varchar(50)
	declare @IdDestinatario as int
	declare @TipoDoc as  varchar(50)

	--recupero ultimo doc OFFERTA_PARTECIPANTI publbicato legato all'offerta
	set @Id=-1
	select @Id=id from ctl_doc where tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='Pubblicato' and linkeddoc=@idDoc and deleted=0
	
	
	
	if @Id = '-1' 
	begin
		--recupero info offerta da settare sul doc offerta_partecipanti
		select @IdMittente=idpfu,@IdAziMittente=azienda,@NomeOfferta=titolo,
				@ProtocolloOfferta=Protocollo,@Oggetto=Body,@ProtocolloBando=ProtocolloRiferimento,
				@Fascicolo=Fascicolo,@IdDestinatario=Destinatario_User,@TipoDoc=TipoDoc
		 from ctl_doc where id=@IdDoc


		--generare nuovo protocollo per il doc offerta_partecipante
		insert into CTL_DOC 
			( IdPfu, TipoDoc, Titolo,Protocollo, Body ,Azienda, 
			ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, JumpCheck , StatoFunzionale, StatoDoc, DataInvio ) 
		values 
			( @IdMittente, 'OFFERTA_PARTECIPANTI', @NomeOfferta , @ProtocolloOfferta , @Oggetto, @IdAziMittente ,  
			@ProtocolloBando, @Fascicolo, @IdDoc , @IdDestinatario, @TipoDoc, 'Pubblicato', 'Sended', getdate() )   

		set @Id=@@IDENTITY

	end
	
	-- rirorna l'id del documento
	select @Id as id
	
	
	
END
GO
