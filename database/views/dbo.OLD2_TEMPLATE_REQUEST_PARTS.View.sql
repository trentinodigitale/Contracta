USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_TEMPLATE_REQUEST_PARTS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_TEMPLATE_REQUEST_PARTS] as

		Select template.id as idTemplate ,   t.Row , t.value as REQUEST_PART ,   d.Value  as Descrizione , a.Value as  TEMPLATE_REQUEST_GROUP , replace( k.Value , ' ' , '') as KeyRiga , M.Value as idModulo , isNull( S.Value , '1' ) as Editabile,
				CI.value as CampiInteressati
			from
				CTL_DOC Template with(nolock)
					inner join  CTL_DOC_Value t with(nolock) on  t.idHeader = case when TipoDoc = 'TEMPLATE_REQUEST' then Template.id else Template.idDoc end and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' 
--					inner join  CTL_DOC_Value t with(nolock) on  t.idHeader = Template.id and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' 
					inner join CTL_DOC_Value d with(nolock) on t.idheader = d.idheader and t.Row = d.Row and d.DSE_ID = 'VALORI' and d.DZT_Name = 'DescrizioneEstesa'
					inner join CTL_DOC_Value a with(nolock) on t.idheader = a.idheader and t.Row = a.Row and a.DSE_ID = 'VALORI' and a.DZT_Name = 'TEMPLATE_REQUEST_GROUP'
					inner join CTL_DOC_Value k with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'

					--inner join CTL_DOC_Value M with(nolock) on template.id = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'

					-- recupera le spunte di SelRow per portare solo gli elementi scelti
					left outer join CTL_DOC_Value k2 with(nolock) on k2.idheader = Template.id and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga' and k.Value = k2.Value
					left outer join CTL_DOC_Value S with(nolock) on S.idheader = Template.id  and k2.Row = S.Row and S.DSE_ID = 'VALORI' and S.DZT_Name = 'SelRow'
					
					--spostata sotto per andare in corrispondenza della row del template di contesto
					inner join CTL_DOC_Value M with(nolock) on template.id = M.idheader and s.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'

					-- verifica se la sezione è removibile
					inner join CTL_DOC_Value R with(nolock) on t.idheader = R.idheader and t.Row = R.Row and R.DSE_ID = 'VALORI' and R.DZT_Name = 'Removibile'
					
					inner join CTL_DOC_Value CI with(nolock) on t.idheader = CI.idheader and t.Row = CI.Row and R.DSE_ID = 'VALORI' and CI.DZT_Name = 'CampiInteressati'


		where ( isNull( S.Value , '1' ) = '1' or R.value <> '1')


GO
