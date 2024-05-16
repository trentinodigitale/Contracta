USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA] ( @IdPreGara int,  @IdGara int,  @idUser int )
AS
BEGIN
	
	declare @Id_Ric_Cig as int
	declare @TipoDocRic as varchar(200)
	declare @Id_New_Ric_Cig as int
	declare @importoBaseAsta as float
	declare @importoBaseAsta2 as float
	declare @Opzioni as float 
	declare @Oneri as float
	declare @PRIMA_FASE as varchar(10)


	--prendo la richiesta CIG/SMART CIG associata al PREGARA
	select 
		@Id_Ric_Cig = max(id)  
		from 
			ctl_Doc with (nolock) 
		where TIPODOC in ( 'RICHIESTA_CIG','RICHIESTA_SMART_CIG' ) and linkeddoc =@IdPreGara   and StatoFunzionale = 'Inviato' and Deleted =0 
	
	if isnull(@Id_Ric_Cig ,0) <> 0
	begin
		
		--se sono su un primo giro non copio la richiesta CIG del pregara  e non la associo alla gara
		select @PRIMA_FASE = 
					CASE
					   WHEN TipoBandoGara IN('1', '4')
							AND ProceduraGara = '15478' --Negoziata / Avviso
							OR TipoBandoGara IN('2')
							AND ProceduraGara = '15477' -- Ristretta / Bando
					   THEN '1'
					   ELSE '0'
					END 
			from 
			Document_Bando where idHeader = @IdGara

		if @PRIMA_FASE <> '1' 
		begin

			--recupero tipo richiesta
			select @TipoDocRic = TipoDoc from ctl_doc with (nolock) where id = @Id_Ric_Cig

			--faccio una copia della richeista cig / smart cig
			exec COPY_Document @TipoDocRic,@Id_Ric_Cig,@Id_New_Ric_Cig out

			--associo la nuova richiesta alla gara tramite linkeddoc della richiesta
			update 
				ctl_doc 
					set deleted=0, linkeddoc=@IdGara 
				where 
					id = @Id_New_Ric_Cig
		end

		--Riportare luogo istat e CPV dal pregara 
		--cancello prima 
		delete ctl_doc_value where idHeader=@IdGara and DSE_ID = 'InfoTec_SIMOG' and DZT_Name in ('COD_LUOGO_ISTAT','CODICE_CPV','DESC_LUOGO_ISTAT')
		--poi reinserisco
		insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			select @IdGara,DSE_ID,DZT_Name,value
			from 
				ctl_doc_value  with(NOLOCK) 
			where 
				idHeader=@IdPreGara and DSE_ID = 'InfoTec_SIMOG' and DZT_Name in ('COD_LUOGO_ISTAT','CODICE_CPV','DESC_LUOGO_ISTAT')
		
		
		--setto richiesta cig a si sulla gara se non sono sulla prima fase
		if @PRIMA_FASE <> '1' 
		begin
			update 
				document_bando
					set RichiestaCigSimog ='si'
					where idheader = @IdGara
		
		end

		--riporto gli importi dal pregara alla gara
		update 
			N 
			set 
				importoBaseAsta = S.importoBaseAsta , importoBaseAsta2 = S.importoBaseAsta2 ,
					 Opzioni = s.Opzioni , Oneri = s.Oneri
				
			from 
				Document_bando N 
					inner join Document_Bando S on s.idheader = @IdPreGara
			where N.idheader = @IdGara



	end
	else
	begin
		--settare richiesta cig a no sulla gara appoena creata
		update 
			document_bando
				set RichiestaCigSimog ='no'
				where idheader = @IdGara
	end

END 
GO
