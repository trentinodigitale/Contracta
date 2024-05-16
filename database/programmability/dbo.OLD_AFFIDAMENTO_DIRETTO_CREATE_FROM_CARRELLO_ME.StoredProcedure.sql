USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFFIDAMENTO_DIRETTO_CREATE_FROM_CARRELLO_ME]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_AFFIDAMENTO_DIRETTO_CREATE_FROM_CARRELLO_ME] 
	(@idDoc int, @IdPfu int  )
AS
BEGIN
	
	set nocount on

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @NumDOC_OK as int	
	declare @Caption as varchar(100)
	declare @IcoMsg as varchar(10)

	set @Id = ''
	set @Errore=''
	set @NumDOC_OK =0	

	set @IcoMsg = '2'
	set @Caption ='Errore'
	--controllo che ci sono articoli nel carrello_me per l'utente
	if not exists(
			select id FROM carrello_me with (nolock) where Idpfu=@IdPfu
			)
	begin
		
		set @Errore = 'Per creare l''affidamento diretto e'' necessario almeno un prodotto'
		select 'Errore' as id , @Errore as Errore
		return
	end

	--if @Errore = ''
	--begin

		--chiamo la stored per creare gli Affidamneti diretti dal carrello ME
		exec AFFIDAMENTO_DIRETTO_CREATE_FROM_CARRELLO_ME_PROCESSO @IdPfu,@IdPfu



		--recupero numero odc creati dal carrello
		select @NumDOC_OK=isnull(attvalue,0) from profiliutenteattrib where dztnome='NumeroAffidamentiDiretti_FromCarrello_ME' and idpfu=@IdPfu
	
		--controllo se ci sono righe nel carrelo con anomalia
		if exists (select * from carrello_me where idpfu=@IdPfu)
		begin
			--CI SONO ANOMALIE
			set @Errore = dbo.CNV('Ci sono righe con anomalie. Controllare la colonna Esito','I')
			set @Caption ='Errore'
			set @IcoMsg = '2'

			if @NumDOC_OK > 0
			begin	
				set @Errore = @Errore + char(13) + char(10)+ dbo.CNV('Gli Affidamenti Diretti creati sono disponibili nella cartella "Affidamenti Diretti Semplificati | Affidamenti Diretti"','I')
				set @Caption ='Attenzione'
				set @IcoMsg = '4'
			end	
		end
		else
		begin

			set @Caption ='Info'
			set @IcoMsg = '1'
			--NON CI SONO ANOMALIE
			if @NumDOC_OK = 1
			begin
			
				--recupero id odc creato e lo apro
				select @Id=isnull(attvalue,0) from profiliutenteattrib where dztnome='LastAffidamentoDiretto_FromCarrello_ME' and idpfu=@IdPfu			

			end
			else
				set @Errore = dbo.CNV('Gli Affidamenti Diretti creati sono disponibili nella cartella "Affidamenti Diretti Semplificati | Affidamenti Diretti"','I')	
		end

	--end

	if @Errore=''
		-- rirorna id doc creato
		--select @Id as id , @Errore as Errore
		select @Id as id, 'BANDO_GARA' as TYPE_TO , 'BANDO_GARA' as JSCRIPT
	else
		-- rirorna l'errore
		select 'INFO_NOML' as id , @Errore + '~~@TITLE=' + @Caption + '~~@ICON=' + @IcoMsg  as Errore
	
	

END
GO
