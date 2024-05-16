USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_UPDATE_TOTALI_ODA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_UPDATE_TOTALI_ODA] 
	( @IdOrdinativo int  )
AS
BEGIN
	--PREZZO_OFFERTO_PER_UM 
	--Quantita 
	--AliquotaIva

	--ValoreEconomico ( Quantita * PREZZO_OFFERTO_PER_UM  )
	--VALORE_COMPLESSIVO_OFFERTA ( ValoreEconomico  + IVA )

	-- calcolo il totale di riga
	update Document_MicroLotti_Dettagli 
		set 
			ValoreEconomico = isnull( PREZZO_OFFERTO_PER_UM , 0 ) * isnull( Quantita , 0 ) 
		from Document_MicroLotti_Dettagli 
			where IdHeader = @IdOrdinativo and tipodoc = 'ODA'

	-- calcolo l'iva della riga
	update Document_MicroLotti_Dettagli 
		set 
			VALORE_COMPLESSIVO_OFFERTA = ValoreEconomico + ( ValoreEconomico * isnull( AliquotaIva , 0 ) ) / 100 
		from Document_MicroLotti_Dettagli 
			where IdHeader = @IdOrdinativo and tipodoc = 'ODA'

	declare @TotaleIva float
	declare @TotaleValoreAccessorio float
	declare @TotaleIvaEroso float
	declare @TotaleEroso float

	select 		

			@TotaleIva=sum( VALORE_COMPLESSIVO_OFFERTA ),
			@TotaleIvaEroso=sum( VALORE_COMPLESSIVO_OFFERTA ),
			@TotaleEroso=sum( ValoreEconomico )

		from Document_MicroLotti_Dettagli 
			where IdHeader = @IdOrdinativo and tipoDoc = 'ODA'
	
	--select 		

	--		@TotaleIva=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0) + ( ((Quantita*PREZZO_OFFERTO_PER_UM) + isnull(ValoreAccessorioTecnico, 0)) * isnull(AliquotaIva, 0) /100)),0), 
	--		@TotaleIvaEroso=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0) + ( ((Quantita*PREZZO_OFFERTO_PER_UM) + isnull(ValoreAccessorioTecnico, 0)) * isnull(AliquotaIva, 0) /100)),0),
	--		@TotaleEroso=isnull(sum(Quantita*PREZZO_OFFERTO_PER_UM + isnull(ValoreAccessorioTecnico, 0)),0),
	--		@TotaleValoreAccessorio=isnull(sum(ValoreAccessorioTecnico),0)

	--	from Document_MicroLotti_Dettagli 
	--		where IdHeader = @IdOrdinativo


	update document_ODA 
		set TotaleValoreAccessorio = @TotaleValoreAccessorio, 
			TotaleEroso = @TotaleEroso, 
			TotalIvaEroso = @TotaleIvaEroso, 
			TotalIva = @TotaleIva 

		WHERE idHeader = @IdOrdinativo 

END


GO
