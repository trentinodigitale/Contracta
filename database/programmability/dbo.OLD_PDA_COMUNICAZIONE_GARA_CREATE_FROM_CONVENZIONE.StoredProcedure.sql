USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_CONVENZIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @Mandataria as nvarchar(10)
	declare @ReferenteFornitore as nvarchar(20)
	declare @DescrizioneEstesa as nvarchar(MAX)
	declare @idazi as nvarchar(20)
	

	set @Id = 0
	set @Errore=''

	--VERIFICA SE SULLA CONVENZIONE E' PRESENTE IL FORNITORE e OGGETTO
	IF EXISTS ( Select * from Document_Convenzione where id=@idDoc and ( ISNULL(Mandataria,'')='' or  ISNULL(ReferenteFornitore,'')='' or ISNULL(cast(DescrizioneEstesa as nvarchar(max)),'')='' ) )
	BEGIN 
		set @errore = 'Sulla convenzione valorizzare correttamente i campi "Oggetto Convenzione completa", "Fornitore" e il "Firmatario/Referente Convenzione"'
	END

	----VERIFICA SE SONO STATI CREATI IL LISTINO OPPURE IL CONTRATTO
	--IF NOT EXISTS ( Select * from Ctl_doc where LinkedDoc=@idDoc and StatoDoc = 'Sended' and tipodoc in ('CONTRATTO_CONVENZIONE','LISTINO_CONVENZIONE') )
	--BEGIN 
	--	set @errore = 'Prima di inviare la Comunicazione bisogna Inviare il Listino oppure il Contratto'
	--END


	select 
		@Mandataria=Mandataria,
		@ReferenteFornitore=ReferenteFornitore,
		@DescrizioneEstesa=DescrizioneEstesa
	from Document_Convenzione where id=@idDoc


	--VERIFICO SE PER CASO ESISTE UN DOCUMENTO IN CORSO
	select @id=id from ctl_doc where TipoDoc='PDA_COMUNICAZIONE_GARA' 
					and Deleted=0 and Destinatario_Azi=@Mandataria and Destinatario_User=@ReferenteFornitore 
					and LinkedDoc=@idDoc and StatoFunzionale='InLavorazione'

	--CREAZIONE COMUNICAZIONE
	if @Errore='' and @Id = 0
	BEGIN

		select @idazi=pfuidazi from ProfiliUtente where idpfu=@IdUser

		Insert into CTL_DOC (IdPfu,TipoDoc,StatoDoc,Data,Titolo,Body,
							 Azienda,ProtocolloRiferimento,Fascicolo,Note,LinkedDoc,JumpCheck,Destinatario_Azi,Destinatario_User)
			 select	@IdUser,'PDA_COMUNICAZIONE_GARA','Saved',getdate(),
						 'Comunicazione al Fornitore della Convenzione',dc.DescrizioneEstesa,
						 @idazi,ISNULL(c.Protocollo,''),ISNULL(c.Fascicolo,''),'',@idDoc,'1-COMUNICAZIONE_FORNITORE_CONVENZIONE',@Mandataria,@ReferenteFornitore
				from Ctl_doc c 
						inner join Document_Convenzione DC on DC.id=c.Id
				where c.id=@idDoc

			
		set @id=SCOPE_IDENTITY()

		--inserisco il dirigente 
		insert into ctl_doc_value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			 select @id,'DIRIGENTE',0,'UserDirigente',@IdUser 

		insert into ctl_doc_value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			 select @id,'DIRIGENTE',0,'CIG',CIG_MADRE
				    from Document_Convenzione where id=@idDoc 
					

	END


	if @Errore=''
	begin

		exec CAMPI_NOT_EDITABLE_CONVENZIONE  @idDoc , @IdUser 

		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END




GO
