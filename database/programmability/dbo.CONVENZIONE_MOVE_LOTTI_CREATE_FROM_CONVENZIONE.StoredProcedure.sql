USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONVENZIONE_MOVE_LOTTI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[CONVENZIONE_MOVE_LOTTI_CREATE_FROM_CONVENZIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT

	set @Errore = ''

	
	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento per l'utente
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONVENZIONE_MOVE_LOTTI' ) and StatoFunzionale= 'InLavorazione' and idpfu=@IdUser

		if ISNULL(@id,'') = ''
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user
					 )
				select 
					@IdUser as idpfu ,
					 'CONVENZIONE_MOVE_LOTTI' as TipoDoc ,  
					'Trasferimento Lotti' as Titolo,
					 DC.DescrizioneEstesa as Body, 
					protocollo as ProtocolloRiferimento, 
					C.id as LinkedDoc			
					,azi_dest
					,referentefornitore
					
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = @@identity

				INSERT INTO ctl_doc_value (idheader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','Ambito',Ambito
				from Document_Convenzione where id = @idDoc

				INSERT INTO ctl_doc_value (idheader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','IdentificativoIniziativa',IdentificativoIniziativa
				from Document_Convenzione where id = @idDoc

				Insert into Document_Convenzione_Lotti ( idHeader, Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo )
				select   @id, 'escludi', StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo 
				from Document_Convenzione_Lotti
				where idheader=@idDoc and ISNULL(Residuo,0) > 0  order by idrow

				

		end
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
