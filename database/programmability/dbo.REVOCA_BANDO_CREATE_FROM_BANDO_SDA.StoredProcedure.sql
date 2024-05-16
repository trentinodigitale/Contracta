USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[REVOCA_BANDO_CREATE_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[REVOCA_BANDO_CREATE_FROM_BANDO_SDA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	set @Id=0
	
	declare @Errore as nvarchar(2000)

	declare @IdPfu as INT

	set @Errore = ''
	--controllo se l'utente che sta facendo l'operazione è tra i riferimenti del bando oppure è il RUP
	IF NOT EXISTS (
					
					select * from ctl_doc 
					inner join Document_Bando_Riferimenti  DR on id=DR.idHeader
					inner join Document_Bando_Commissione  DC on id=DC.idHeader and RuoloCommissione='15550'
					where id=@idDoc and ( DR.idpfu=@IdUser or DC.idPfu=@IdUser )

				   )
	BEGIN	
		set @Errore = 'La revoca puo essere creata solo dagli utenti fra i riferimenti del bando oppure dal responsabile del procedimento'
	END
	---controllo se per quel bando esiste una rettifica
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RETTIFICA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di revoca non puo essere creato se non viene conclusa la rettifica in corso sul bando'
	END
	---controllo se per quel bando esiste una proroga/estensione
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='PROROGA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di revoca non puo essere creato se non viene conclusa l''estensione in corso sul bando'
	END

	-- controllo se esiste una revoca in corso
	select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='REVOCA_BANDO' and statofunzionale in ('InLavorazione','InApprove')
	if ( @id IS NULL or @id=0 ) and  @Errore = '' 
	begin 
		
		--inserisco nella ctl_doc		
		insert into CTL_DOC (
				IdPfu, TipoDoc, Titolo,ProtocolloRiferimento, NumeroDocumento, Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck,Caption,Azienda)
			select
				 @idUser ,  'REVOCA_BANDO'  , 'Revoca Bando Num. ' + Protocollo as Titolo , 
				 Protocollo ,CIG , Fascicolo , @idDoc  ,'InLavorazione',@idUser , 'BANDO_SDA','Revoca Bando SDA',Azienda
			from ctl_doc
			inner join document_bando on idHeader=id
			where Id = @idDoc

		set @Id = @@identity	

		--inserisce nello storico la creazione
		insert into CTL_ApprovalSteps (APS_Doc_Type,APS_ID_DOC,APS_State,APS_IsOld,APS_IdPfu)
		values ('REVOCA_BANDO',@Id,'Compiled',1,@idUser)
		
	end

	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	

	if @Errore = ''
	begin
		
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END









GO
