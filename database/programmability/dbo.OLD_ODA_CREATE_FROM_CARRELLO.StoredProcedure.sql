USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ODA_CREATE_FROM_CARRELLO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_ODA_CREATE_FROM_CARRELLO] 
	(@IdDoc int, @IdPfu int)
AS
BEGIN

	SET NOCOUNT ON

	declare @Errore nvarchar(2000)
	declare @aziragionesociale varchar(500)
	declare @idFornitore int
	declare @numeroFornitori int = 0
	declare @idDocumentoNew int
	declare @numeroArticoli int
	declare @numeroArticoliNew int
	declare @Esito bit = 0
	declare @Caption as varchar(100)
	declare @IcoMsg as varchar(10)

	--mi acquisisco il numero articoli nel carrello
	select	
		@numeroArticoli = COUNT(*) 
			from Carrello_ME with(nolock) 
			where idpfu=@IdPfu

	-- verifica la presenza di articoli nel carrello altrimenti esce con errore
	if @numeroArticoli > 0
		begin 
		  --Ciclo per ogni fornitore presente nel carrello
			declare carrello_fornitori_cursor CURSOR FOR 
				select distinct aziragionesociale , c.azienda from carrello_me b with(nolock)	
					inner join ctl_doc c with(nolock) on b.id_catalogo = c.id
					inner join aziende a with(nolock) on idazi = azienda
					where b.idPfu = @IdPfu

			open carrello_fornitori_cursor
		  
			fetch next from carrello_fornitori_cursor into @aziragionesociale, @idFornitore;

			 while @@FETCH_STATUS = 0 and @idFornitore is not null
				Begin
				
					--invochiamo un stored per creare il documento l'ODA
					exec ODA_CREATE_FROM_CARRELLO_FORNITORE @idFornitore, @aziragionesociale, @IdPfu, @idDocumentoNew output
					
					set @numeroFornitori = @numeroFornitori + 1;

					FETCH NEXT FROM carrello_fornitori_cursor into @aziragionesociale, @idFornitore;
				end

			close carrello_fornitori_cursor
			deallocate carrello_fornitori_cursor
		
			--controllo se ci sono rimasti articoli nel carrello
			select	
				@numeroArticoliNew = COUNT(*) 
					from Carrello_ME with(nolock) 
					where idpfu=@IdPfu

			if @numeroFornitori > 1 and @numeroArticoliNew = 0 and @idDocumentoNew > 0
				begin
					set @Errore='Gli ODA creati sono disponibili nella cartella "Cataloghi ME | Ordini di Acquisto"'
					set @Caption ='Attenzione'
					set @IcoMsg = '4'
				end
			else
				begin 

					if @numeroArticoli = @numeroArticoliNew 
						begin
							set @Errore='Attenzione gli articoli nel carrello non è possibile acquistarli controllare la verifica nel campo Esito'
							set @Caption ='Errore'
							set @IcoMsg = '2'
						end
					else if @numeroArticoliNew > 0 and @idDocumentoNew > 0
						begin
							set @Errore='Attenzione alcuni articoli non è possibile acquistarli controllare la verifica nel campo Esito. Gli ODA creati sono disponibili nella cartella "Cataloghi ME | Ordini di Acquisto"'
							set @Caption ='Errore'
							set @IcoMsg = '2'
						end
				end
			
		end 
	else
		begin
			set @Errore='Non ci sono articoli nel carrello'
			set @Caption ='Errore'
			set @IcoMsg = '2'
		end

	if @Errore <> ''
		begin 
			select 'INFO_NOML' as id , @Errore + '~~@TITLE=' + @Caption + '~~@ICON=' + @IcoMsg  as Errore
		end
	else
		
		begin
			select @idDocumentoNew as id , @Errore as Errore
		end
		
		
END

GO
