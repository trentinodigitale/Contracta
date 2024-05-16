USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Listino_Ordini_OE_Prodotti_View]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[Document_Listino_Ordini_OE_Prodotti_View] as 

select D.* 
	
	, case  
		when d.StatoRiga = 'Inserted' then '' 
		when d.StatoRiga in ('Saved','Deleted','') then dbo.GetPos(DM.value,'###',4)
		else ''	 
	  end as 	NotEditable
	  
	, case 
			when D.StatoRiga ='Deleted' then '../toolbar/ripristina.png'
			else '../toolbar/Delete_Light.GIF'
		end as 	FNZ_DEL
	--,
	--DM.value
	from Document_MicroLotti_Dettagli D with (nolock)
																				
			--salgo sul documento
			inner join ctl_doc LO with (nolock)  on LO.id=D.idheader and LO.tipodoc=D.tipodoc

			--salgo sul modello specifico legato alla convezione
			inner join ctl_doc M  with (nolock) on M.LinkedDoc = LO.LinkedDoc and M.tipodoc ='CONFIG_MODELLI'
			--vado a prendere l'informazione per le colonne non editabili 
			--da considerare
			left join CTL_DOC_Value DM with (nolock) on DM.IdHeader = M.id and DM.dse_id='STATO_MODELLO' and DM.DZT_Name ='colonne_non_editabili'
		


		where 
			D.tipodoc='LISTINO_ORDINI_OE'
			--and  D.idheader=431291

GO
