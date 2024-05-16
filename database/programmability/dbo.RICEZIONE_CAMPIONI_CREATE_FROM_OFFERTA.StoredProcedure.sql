USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICEZIONE_CAMPIONI_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[RICEZIONE_CAMPIONI_CREATE_FROM_OFFERTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdMittente as int
	declare @IdAziMittente as int
	declare @ProtocolloOfferta as varchar(50)
	declare @Oggetto as nvarchar(4000)
	declare @ProtocolloBando as varchar(50)
	declare @Fascicolo as  varchar(50)
	declare @IdDestinatario as int
	declare @TipoDoc as  varchar(50)
	declare @IdPDA as int
	declare @Errore as nvarchar(2000)
	declare @IdLast as int
	--select * from document_pda_offerte where idheader=58951	


	set @Errore=''
	
	--recupero id della pda
	select 
		 @IdPDA=PO.Idheader, @TipoDoc=O.TipoDoc
	from 
		document_pda_offerte PO 
		left outer join ctl_doc O on PO.idmsg=O.id and PO.TipoDoc=O.TipoDoc and O.deleted=0
		left outer join ctl_doc O2 on PO.Idheader=O2.id and O2.TipoDoc='PDA_MICROLOTTI'
	where 
		PO.idmsg=@idDoc and  O2.Deleted=0

	--if 	@TipoDoc is null 
	--	set @TipoDoc='55;171'
	
	--recupero protocollobando dalla PDA
	select @ProtocolloBando=ProtocolloRiferimento from ctl_doc where id=@IdPDA
	
	--recupero ultimo doc RICEZIONE_CAMPIONI publbicato legato all'offerta
	set @Id=-1
	select @Id=id from ctl_doc where tipodoc='RICEZIONE_CAMPIONI' and IdDoc=@IdPDA and linkeddoc=@idDoc and deleted=0 and StatoFunzionale in ('InLavorazione','Confermato')
	
	if @Id = '-1' 
	begin
		
		--prima di crearlo controllo che stato riga dell'offerta non sia ammessa/esclusa
		set @Errore='Operazione non consentita:necessario annullare esito ammessa/esclusa'
		if not exists (select * from document_pda_offerte where idmsg=@idDoc and Idheader=@IdPDA and statopda in ('1','2','22'))
		
		begin
			set @Errore=''	
			--recupero info offerta da settare sul doc offerta_partecipanti
			select @IdMittente=idpfu,@IdAziMittente=azienda,
					@ProtocolloOfferta=Protocollo,@Oggetto=Body,
					@Fascicolo=Fascicolo,@IdDestinatario=Destinatario_User,@TipoDoc=TipoDoc
			 from ctl_doc where id=@IdDoc


		
			insert into CTL_DOC 
				( IdPfu, TipoDoc, Body ,Azienda, IdDoc,
				ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, JumpCheck , StatoFunzionale, StatoDoc ) 
			values 
				( @IdUser, 'RICEZIONE_CAMPIONI', @Oggetto, @IdAziMittente , @IdPDA,
				@ProtocolloOfferta, @Fascicolo, @IdDoc , @IdDestinatario, @TipoDoc, 'InLavorazione', 'Saved' )   

			set @Id=@@IDENTITY

			--memorizzo info aggiuntive nella ctl_doc_value
			insert into CTL_DOC_VALUE
			(IdHeader, DSE_ID, Row, DZT_Name, Value	)
			values
			(@Id, 'TESTATA', 0, 'ProtocolloBando', @ProtocolloBando	)



			--se esiste un doc ESCLUDI_LOTTI ANNULLATO riporto le righe nel nuovo doc
			set @IdLast=-1
			select top 1 @IdLast=id from ctl_doc where tipodoc='RICEZIONE_CAMPIONI' and IdDoc=@IdPDA and linkeddoc=@idDoc and StatoFunzionale ='Annullato' and deleted=0  order by id desc
			if (@IdLast != -1)
			begin

				insert into Document_Pda_Ricezione_Campioni
				(IdHeader, NumeroLotto, CIG, Descrizione, CampioneRicevuto)
				select 
					@Id,NumeroLotto, CIG, Descrizione,CampioneRicevuto
					from 
						Document_Pda_Ricezione_Campioni
					where 	
						idheader = @IdLast
			end
			else
			begin
				--aggiungo tutti i lotti a cui il fornitore sta partecipando
				insert into Document_Pda_Ricezione_Campioni
				(IdHeader, NumeroLotto, CIG, Descrizione)
				select 
					@Id,NumeroLotto, CIG, Descrizione
					from 
						document_microlotti_dettagli where idheader=@idDoc and tipodoc=@TipoDoc and voce=0
			end


			

		end

	end
	
	if @Errore=''

		-- rirorna l'id del documento
		select @Id as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end

	
	
	
	
END



GO
