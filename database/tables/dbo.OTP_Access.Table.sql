USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OTP_Access]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OTP_Access](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idPfu] [int] NULL,
	[Messaggio] [varchar](max) NULL,
	[Server_Id] [int] NULL,
	[OTP_Hash] [nvarchar](100) NULL,
	[isReadOTP] [bit] NULL,
	[numRetry] [int] NULL,
	[InsertDate] [datetime] NULL,
	[TemplateHelper] [varchar](max) NULL,
 CONSTRAINT [PK__OTP_Acce__3C872F01DFF21677] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[OTP_Access] ADD  CONSTRAINT [DF__OTP_Acces__isRea__6C1F6909]  DEFAULT ((0)) FOR [isReadOTP]
GO
ALTER TABLE [dbo].[OTP_Access] ADD  CONSTRAINT [DF__OTP_Acces__numRe__6D138D42]  DEFAULT ((0)) FOR [numRetry]
GO
ALTER TABLE [dbo].[OTP_Access] ADD  CONSTRAINT [DF__OTP_Acces__Inser__6E07B17B]  DEFAULT (getdate()) FOR [InsertDate]
GO
