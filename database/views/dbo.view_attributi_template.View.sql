USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_attributi_template]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_attributi_template] as
select  o.name as ViewName , c.name as colonna,'#Document.'+c.name+'#' as colonnatecnica, c.name as id from syscolumns c
      inner join sysobjects o on o.id = c.id
where  o.xtype = 'v' 
GO
