USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SCHEDA_PRODOTTO_CREATE_FROM_PRODOTTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SCHEDA_PRODOTTO_CREATE_FROM_PRODOTTO] 
	( @idDoc int, @idUser int)
AS
BEGIN

SET NOCOUNT ON

declare @newId int = -1;
select 
		@newId = idRow 
	from CTL_DOC_SECTION_MODEL with(nolock)
	where IdHeader = @idDoc and DSE_ID = 'DETTAGLI_SCHEDA_PRODOTTO'

if @newId = -1
begin

	declare @nomeModello Varchar(500)
	declare @titolo varchar(500);
	declare @idModello int;

	select @idModello = idDoc 
		from CTL_DOC with(nolock)
		where id = (
					select IdHeader 
						from Document_MicroLotti_Dettagli with(nolock)
						where TipoDoc = 'CATALOGO_MEA' and Id = @idDoc
					)

	if @idModello > 0 
		begin	
			select @titolo = Titolo 
				from CTL_DOC with(nolock)
				where id = @idModello

			set @nomeModello = 'MODELLI_MEA_SCHEDA_' + @titolo + '_MOD_Modello';

			insert into CTL_DOC_SECTION_MODEL 
				( IdHeader, DSE_ID, MOD_Name) values 
				( @idDoc, 'DETTAGLI_SCHEDA_PRODOTTO', @nomeModello)

				set @newId = SCOPE_IDENTITY()
		end

		
end

select @idDoc as id
END




GO
