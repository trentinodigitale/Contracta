USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_VARIAZIONE_PREZZO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[OLD2_DASHBOARD_SP_VARIAZIONE_PREZZO] ( @idDoc int ) as 
begin
	SET NOCOUNT ON

	
					
	if exists (select odc.id
					from Document_MicroLotti_Dettagli odc with (nolock)
						inner join Document_MicroLotti_Dettagli conv with (nolock) on odc.idHeaderLotto=conv.id 
														and odc.PREZZO_OFFERTO_PER_UM<>conv.PREZZO_OFFERTO_PER_UM 
														and odc.ValoreEconomico<>conv.ValoreEconomico and conv.tipoacquisto <> 'importo'
						inner join ctl_doc convenzione with (nolock) on  conv.IdHeader=convenzione.id and convenzione.Deleted=0
						inner join ctl_doc variazione with (nolock) on convenzione.id=variazione.linkeddoc 
																and variazione.tipodoc='CONVENZIONE_PRZ_PRODOTTI' 
																and variazione.statofunzionale <> 'InLavorazione' and variazione.Deleted=0
					where odc.idheader=@idDoc and odc.TipoDoc='ODC')
					begin
						select 'VARIAZIONE' as esito
					end

					else
					begin 
						select top 0 'variazione' as esito
					end 
			end
GO
