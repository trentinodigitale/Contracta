USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHECK_ODA_TOTALE_EROSO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from carrello_me

--select * from aziende where idazi = 35159186




CREATE PROCEDURE [dbo].[CHECK_ODA_TOTALE_EROSO] 
	(@IdPfu int)
AS
BEGIN

	SET NOCOUNT ON

	declare @idCarrello int;
	declare @TotaleEroso int;
	declare @valoreLimite int;
	declare @cursorTotEroso int;
	declare @aziragionesociale varchar(500);

	set @valoreLimite = [dbo].[PARAMETRI]( 'ODA', 'MAX_SOGLIA_VALORE_ODA', 'DefaultValue', '5000' ,@IdPfu ) 
	set @TotaleEroso = 0;

	update carrello_me set EsitoRiga = '' where idPfu = @idPfu 
	--select * from carrello_me

	update C
			set C.EsitoRiga =
			
				case 
					when i.StatoIscrizione = 'Iscritto' and ca.StatoFunzionale = 'Pubblicato' then ''
					when ca.StatoFunzionale <> 'Pubblicato' then 'Catalogo non pubblicato'
					when i.StatoIscrizione <> 'Iscritto' then 'il fornitore è sospeso dall''albo'
					else C.EsitoRiga --'Articolo non più disponibile'
			
				end
		
		from carrello_ME C

			-- prodotto del catalogo
			inner join		document_microlotti_dettagli D with(nolock )  on C.Id_Product=D.id

			-- catalogo
			inner join CTL_DOC ca with(nolock )  on D.idheader= ca.id

			-- iscrizione all'albo
			inner join ctl_doc_destinatari i with(nolock) on i.idheader = ca.linkeddoc and i.idazi = ca.azienda

			where C.idPfu = @idPfu 


	update C
			set C.EsitoRiga = C.EsitoRiga + 'Il totale per gli articoli del fornitore supera il limite consentito per ODA pari a €' + [dbo].[FormatMoney]( @valoreLimite   )
				
		from carrello_ME C
			
		where C.idPfu = @idPfu 
			and C.fornitore in ( 
							select fornitore 
								from carrello_me 
								where idPfu = @idPfu and EsitoRiga = ''
								group by fornitore 
								having sum ( isnull(PrezzoUnitario * QTDisp, 0) ) > @valoreLimite 
					) 
				and EsitoRiga = ''
				


	--declare totEroso_cursor CURSOR FOR 
	--	select carr.id, isnull(carr.PrezzoUnitario * carr.QTDisp, 0) as totEroso, aziragionesociale from Carrello_ME as carr  
	--			inner join ctl_doc c with(nolock) on carr.id_catalogo = c.id
	--			inner join aziende a with(nolock) on idazi = azienda	
	--		where c.Azienda = @idFornitore and carr.idPfu = @idPfu 
			
	--open totEroso_cursor

	--fetch next from totEroso_cursor into @idCarrello, @cursorTotEroso, @aziragionesociale
	--while @@FETCH_STATUS = 0
	--begin 
	--	set @TotaleEroso = @TotaleEroso + @cursorTotEroso

	--	if @TotaleEroso > @valoreLimite
	--		begin 
	--			--update carrello_me set EsitoRiga = 'Il valore dell''ordine del fornitore '+ @aziragionesociale +' supera il limite previsto'
	--			--	where id = @idCarrello							
	--			update carrello_me set EsitoRiga = 'Il totale per gli articoli del fornitore supera il limite consentito per ODA pari a €' + [dbo].[FormatMoney]( @valoreLimite   )
	--				where id = @idCarrello							

					
	--		end
	--	else
	--		begin 
	--			update carrello_me set EsitoRiga = ''
	--				where id = @idCarrello								
	--		end

	--	FETCH NEXT FROM totEroso_cursor into @idCarrello, @cursorTotEroso, @aziragionesociale;
				
	--end

	--close totEroso_cursor
	--deallocate totEroso_cursor
END

						
						
						
					
GO
