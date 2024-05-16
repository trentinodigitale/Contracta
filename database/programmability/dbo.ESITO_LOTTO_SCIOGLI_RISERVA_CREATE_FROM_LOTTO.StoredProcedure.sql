USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESITO_LOTTO_SCIOGLI_RISERVA_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[ESITO_LOTTO_SCIOGLI_RISERVA_CREATE_FROM_LOTTO] 
	( @idRow int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @id_lotto_offerta as INT
	declare @Errore as nvarchar(2000)
	set @Errore=''
	set @id=0

	--CONTROLLO SE ESISTE UN LOTTO AMMESSO CON RISERVA PER L'OFFERTA SELEZIONATA
	if not exists (	select 
						*	 
					from Document_MicroLotti_Dettagli L 
						inner join Document_PDA_OFFERTE  O on O.IdRow=L.IdHeader
						inner join CTL_DOC C on C.TipoDoc='ESCLUDI_LOTTI' and C.StatoFunzionale='Confermato' and O.IdHeader=C.IdDoc and idAziPartecipante=C.Azienda
						inner join Document_Pda_Escludi_Lotti DE on DE.idHeader=C.id and DE.StatoLotto='AmmessoRiserva' and L.NumeroLotto=DE.NumeroLotto
					where L.id=@idRow and L.TipoDoc='PDA_OFFERTE'
					)
	begin
	   
	   set @Errore = 'Operazione non consentita per l''offerta selezionata il lotto non risulta nello stato di "Ammesso con Riserva"'

	end

	select @id_lotto_offerta=OFFERTA.id 
	from Document_MicroLotti_Dettagli L 
		inner join Document_PDA_OFFERTE  O on O.IdRow=L.IdHeader
		inner join Document_MicroLotti_Dettagli  OFFERTA on OFFERTA.IdHeader=O.IdMsg and OFFERTA.tipodoc='OFFERTA' and L.NumeroLotto=OFFERTA.NumeroLotto and OFFERTA.voce=0		
	where L.id=@idRow and L.TipoDoc='PDA_OFFERTE'	


	--PROVO A CERCARE UN DOCUMENTO PRECEDENTE
	select @Id=C.id 
			from ctl_doc C 
		where C.tipodoc='ESITO_LOTTO_SCIOGLI_RISERVA' and C.LinkedDoc=@id_lotto_offerta and C.StatoFunzionale in ('InLavorazione','Confermato')
	

	---CREO IL DOCUMENTO
	if @Errore='' and @Id=0
	BEGIN
		insert into CTL_DOC (idpfu,TipoDoc,Azienda,Fascicolo,LinkedDoc,IdDoc, NumeroDocumento )
			select @IdUser,'ESITO_LOTTO_SCIOGLI_RISERVA', CTLO.Azienda,  CTLO.Fascicolo , OFFERTA.id as LinkedDoc,L.IdHeader as IdDoc, L.NumeroLotto
					from Document_MicroLotti_Dettagli L 
						inner join Document_PDA_OFFERTE  O on O.IdRow=L.IdHeader
						inner join Document_MicroLotti_Dettagli  OFFERTA on OFFERTA.IdHeader=O.IdMsg and OFFERTA.tipodoc='OFFERTA' and L.NumeroLotto=OFFERTA.NumeroLotto and OFFERTA.voce=0
						inner join ctl_doc CTLO on CTLO.id=OFFERTA.IdHeader and CTLO.tipodoc='OFFERTA'
					where L.id=@idRow and L.TipoDoc='PDA_OFFERTE'	
		
		set @Id=SCOPE_IDENTITY()
	END



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
