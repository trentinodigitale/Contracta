USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[creditNote_UBLExtension]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[creditNote_UBLExtension] ( @idDoc int ) 
as
begin

select *
	from (
				select 
					1 as ordinamento,
					IdHeader, 
					TipoContributo as TypeCode, 
					'urn:fdc:agid.gov.it:fatturapa:TipoRitenuta::' as ExtensionURI					
				from Document_NoTIER_Prodotti with(nolock)
					where IdHeader = @idDoc and TipoContributo <> 'NA' and TipoContributo <> '' and TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')

			union

				select 
					2 as ordinamento,
					IdHeader, 
					TipoRitenuta as TypeCode, 
					'urn:fdc:agid.gov.it:fatturapa:TipoRitenuta::' as ExtensionURI
				from Document_NoTIER_Prodotti with(nolock)
					where IdHeader = @idDoc and TipoRitenuta <> 'NA' and TipoRitenuta <> '' and TipoDoc_collegato in ('NOTA_DI_CREDITO', 'NOTA_DI_CREDITO_PA')

	) as a
	order by ordinamento

end
GO
