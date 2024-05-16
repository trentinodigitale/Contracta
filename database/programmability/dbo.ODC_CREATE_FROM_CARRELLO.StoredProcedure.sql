USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ODC_CREATE_FROM_CARRELLO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ODC_CREATE_FROM_CARRELLO] 
	( @IdPfu int  , @idUser int )
AS
BEGIN
	
	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @NumODC_OK as int	
	declare @Caption as varchar(100)
	declare @IcoMsg as varchar(10)

	set @Id = ''
	set @Errore=''
	set @NumODC_OK =0	

	--recupero numero odc creati dal carrello
	select @NumODC_OK=isnull(attvalue,0) from profiliutenteattrib where dztnome='NumeroOrdinativi_FromCarrello' and idpfu=@IdPfu
	
	--controllo se ci sono righe nel carrelo con anomalia
	if exists (select * from carrello where idpfu=@IdPfu)
	begin
		--CI SONO ANOMALIE
		set @Errore = dbo.CNV('Ci sono righe con anomalie. Controllare la colonna Esito','I')
		set @Caption ='Errore'
		set @IcoMsg = '2'

		if @NumODC_OK > 0
		begin	
			set @Errore = @Errore + char(13) + char(10)+ dbo.CNV('Gli ordinativi creati sono disponibili nella cartella "ordinativi di fornitura in lavorazione"','I')
			set @Caption ='Attenzione'
			set @IcoMsg = '4'
		end	
	end
	else
	begin

		set @Caption ='Info'
		set @IcoMsg = '1'
		--NON CI SONO ANOMALIE
		if @NumODC_OK = 1
		begin
			
			--recupero id odc creato e lo apro
			select @Id=isnull(attvalue,0) from profiliutenteattrib where dztnome='LastOrdinativo_FromCarrello' and idpfu=@IdPfu			

		end
		else
			set @Errore = dbo.CNV('Gli ordinativi creati sono disponibili nella cartella "ordinativi di fornitura in lavorazione"','I')	
	end
	
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
		-- rirorna l'errore
		select 'INFO_NOML' as id , @Errore + '~~@TITLE=' + @Caption + '~~@ICON=' + @IcoMsg  as Errore
	
	

END
GO
