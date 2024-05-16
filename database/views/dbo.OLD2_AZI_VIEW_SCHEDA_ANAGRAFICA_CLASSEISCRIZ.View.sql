USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_CLASSEISCRIZ]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_CLASSEISCRIZ] as

select 
	distinct 
	--*,
	idVat as id,  
	vatvalore_ft as ClasseIscriz_S , 
	lnk as idAzi ,
	'CLSSE_ISCRIZ' as OPEN_DOC_NAME,
	'MERC_ADDITIONAL_INFO' as MAKE_DOC_NAME,
	--case when dbo.GetInfoADD_FOR_CLASS(vatvalore_ft) = '1' then '../../../images/Domain/Lente.gif'  else '../../../images/Domain/NO_Lente.gif' end as FNZ_OPEN
	case when  CA.dmv_cod is not null then '../../../images/Domain/Lente.gif'  else '../../../images/Domain/NO_Lente.gif' end as FNZ_OPEN


from dm_attributi  dm with (nolock)
	-- recupera il path del nodo selezionato
	left JOIN ClasseIscriz  CI with(nolock) on CI.dmv_cod= dm.vatvalore_ft and CI.dmv_deleted=0
	
	-- RECUPERA TUTTE LE CLASSI CHE PREVEDONO INFORMAZIONI AGGIUNTIVE
	LEFT join ctl_doc D WITH (NOLOCK) ON D.TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and D.Deleted=0 and D.StatoFunzionale in ('Pubblicato')		
	LEFT join CTL_DOC_Value CV  WITH (NOLOCK) on CV.idHeader=d.id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz' 
	
	-- recupera il path delle classi con informazioni aggiuntive
	left join ClasseIscriz CA WITH (NOLOCK)  on CV.value like '%###' + CA.dmv_cod + '###%' and CA.dmv_deleted=0

													-- il cui path contiene il nodo dell'azienda
													and LEFT(CI.DMV_Father,LEN(CA.DMV_Father)) = CA.DMV_Father
	
	where dm.dztnome = 'ClasseIscriz' and dm.idapp = 1

	--and dm.vatvalore_ft = 14247
	--AND lnk=35154315



GO
