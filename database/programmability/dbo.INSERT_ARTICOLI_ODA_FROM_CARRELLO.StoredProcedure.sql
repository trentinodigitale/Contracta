USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INSERT_ARTICOLI_ODA_FROM_CARRELLO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[INSERT_ARTICOLI_ODA_FROM_CARRELLO] 
	( @IdOrdinativo int, @IdPfu int )
AS
BEGIN
	declare @pfuIdAzi int 
	declare @idCarrello int
	declare @idProdotto int
	declare @idCatalogo int
	declare @qta int
	declare @valoriColonneMicrolotti varchar(500)
	--declare @TotaleIva int
	--declare @TotaleValoreAccessorio int
	--declare @TotaleIvaEroso int
	--declare @TotaleEroso int

--mi recuperi i dati del fornitore
	select @pfuIdAzi = pfuIdAzi 
		from ProfiliUtente where IdPfu = @idPfu

	DECLARE crsArticoliPerFornitori CURSOR STATIC FOR 
				select b.id, b.Id_Product, b.Id_Catalogo, b.QTDisp 
					from Carrello_ME b
						inner join ctl_doc c with(nolock) on b.id_catalogo = c.id
						inner join aziende a with(nolock) on idazi = azienda	
						where b.idPfu = @idPfu

	OPEN crsArticoliPerFornitori
	FETCH NEXT FROM crsArticoliPerFornitori INTO @idCarrello, @idProdotto, @idCatalogo, @qta
				WHILE @@FETCH_STATUS = 0
					BEGIN
						declare @Filter as nvarchar(max)
						set @Filter = 'id=' + cast(@idProdotto as varchar(50)) 	
						set @valoriColonneMicrolotti = cast (@qta as varchar(100)) + ',' + cast (@idProdotto as varchar(100))
						
						exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idCatalogo, @IdOrdinativo, 'IdHeader', 'id', @Filter, 'Quantita,idHeaderLotto', @valoriColonneMicrolotti, 'id'					
												
						--cancello gli articoli  dal carrello
						delete Carrello_ME where id= @idCarrello

						FETCH NEXT FROM crsArticoliPerFornitori INTO @idCarrello, @idProdotto, @idCatalogo, @qta
					END
					
			CLOSE crsArticoliPerFornitori 
			DEALLOCATE crsArticoliPerFornitori 	

	update Document_MicroLotti_Dettagli set TipoDoc = 'ODA' where IdHeader = @IdOrdinativo			

	exec UPDATE_TOTALI_ODA @IdOrdinativo
	--select 		
	--	@TotaleIva=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0) + ( ((Quantita*PREZZO_OFFERTO_PER_UM) + isnull(ValoreAccessorioTecnico, 0)) * isnull(AliquotaIva, 0) /100)),0), 
	--	@TotaleIvaEroso=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0) + ( ((Quantita*PREZZO_OFFERTO_PER_UM) + isnull(ValoreAccessorioTecnico, 0)) * isnull(AliquotaIva, 0) /100)),0),
	--	@TotaleEroso=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0)),0),
	--	@TotaleValoreAccessorio=isnull(sum(ValoreAccessorioTecnico),0)
	--	from Document_MicroLotti_Dettagli 
	--		where IdHeader = @IdOrdinativo


		--update document_ODA set TotaleValoreAccessorio = @TotaleValoreAccessorio, TotaleEroso = @TotaleEroso, TotalIvaEroso = @TotaleIvaEroso, TotalIva = @TotaleIva
		--	WHERE idHeader = @IdOrdinativo 
END






GO
