USE [Igloo_Test]
GO
/****** Object:  Table [dbo].[usr_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_task](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[usr_name] [varchar](50) NULL,
	[usr_status] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[task](
	[task_id] [int] IDENTITY(1,1) NOT NULL,
	[task_name] [varchar](50) NULL,
	[task_created] [datetime] NULL,
	[task_completed] [datetime] NULL,
	[task_status] [bit] NULL,
	[usr_id] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[wv_Details]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[wv_Details]
AS
SELECT        a.task_id, a.task_name, CASE WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(MINUTE, [task_created], GETDATE()) AS VARCHAR(8)) WHEN [task_completed] IS NOT NULL THEN CAST(DATEDIFF(MINUTE, [task_created], 
                         [task_completed]) AS VARCHAR(8)) END AS min, CASE WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(HOUR, [task_created], GETDATE()) AS VARCHAR(8)) WHEN [task_completed] IS NOT NULL 
                         THEN CAST(DATEDIFF(HOUR, [task_created], [task_completed]) AS VARCHAR(8)) END AS hour, CASE WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(DAY, [task_created], GETDATE()) AS VARCHAR(8)) 
                         WHEN [task_completed] IS NOT NULL THEN CAST(DATEDIFF(DAY, [task_created], [task_completed]) AS VARCHAR(8)) END AS day, b.id,
						 [task_created],[task_completed]
FROM            dbo.task AS a INNER JOIN
                         dbo.usr_task AS b ON a.usr_id = b.id
GO
/****** Object:  StoredProcedure [dbo].[SP_dele_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_dele_task]
					@id int
					

AS

BEGIN
	delete from [dbo].[task]
	where [task_id]=@id
END




GO
/****** Object:  StoredProcedure [dbo].[SP_dele_user]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_dele_user]
					@id int

AS

BEGIN
	delete from [dbo].[usr_task]
	where [id]=@id
END




GO
/****** Object:  StoredProcedure [dbo].[SP_Detail_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_Detail_task]
						@id bigint,
						@Date1 varchar(10),
						@Date2 varchar(10),
						@opt int


AS

BEGIN
	if @opt=0
	begin
		SELECT COUNT([task_completed])task_finished,
		COUNT([task_name])task_number,
		(COUNT([task_name])-COUNT([task_completed]))task_pending
		FROM [dbo].[task]
		WHERE [usr_id]=@id
		AND (convert(varchar(10),[task_created],101) >=RTRIM(LTRIM(@Date1))  
				AND  convert(varchar(10),[task_created],101) <=RTRIM(LTRIM(@Date2)))

	end

	if @opt=1
	begin
		SELECT [task_id],[task_name],
		CASE 
			WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(MINUTE,[task_created],GETDATE())AS VARCHAR(8))
			WHEN [task_completed] IS NOT NULL THEN CAST(DATEDIFF(MINUTE,[task_created],[task_completed])AS VARCHAR(8))
		END AS [min],

		CASE 
			WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(HOUR,[task_created],GETDATE())AS VARCHAR(8))
			WHEN [task_completed] IS NOT NULL THEN CAST(DATEDIFF(HOUR,[task_created],[task_completed])AS VARCHAR(8))
		END as [hour],

		CASE 
			WHEN [task_completed] IS NULL THEN CAST(DATEDIFF(DAY,[task_created],GETDATE())AS VARCHAR(8))
			WHEN [task_completed] IS NOT NULL THEN CAST(DATEDIFF(DAY,[task_created],[task_completed])AS VARCHAR(8))
		END as [day]
		FROM [dbo].[task]
		WHERE [usr_id]=@id
		AND (convert(varchar(10),[task_created],101) >=RTRIM(LTRIM(@Date1))  
				AND  convert(varchar(10),[task_created],101) <=RTRIM(LTRIM(@Date2)))
	end

	if @opt=2
	begin
		SELECT  [task_id],[task_name],
		CONVERT(varchar(10),[task_created],101)[task_created],
		CONVERT(varchar(10),[task_completed],101)[task_completed]
		FROM [dbo].[task]
		WHERE [usr_id]=@id
		 AND (convert(varchar(10),[task_created],101) >=RTRIM(LTRIM(@Date1))  
				AND  convert(varchar(10),[task_created],101) <=RTRIM(LTRIM(@Date2)))
	end

	if @opt=3
	begin
	SELECT 'Total' as total,
	sum(convert(bigint,[min])) as [tot_min],(sum(convert(bigint,[min]))/COUNT([min]))as [avg_min],
	sum(convert(bigint,[hour])) as  [tot_hour ],(sum(convert(bigint,[hour]))/COUNT([hour]))as  [avg_hour]
	from [dbo].[wv_Details]
		WHERE [id]=@id
		AND (convert(varchar(10),[task_created],101) >=RTRIM(LTRIM(@Date1))  
				AND  convert(varchar(10),[task_created],101) <=RTRIM(LTRIM(@Date2)))
	end

	if @opt=4
	begin
	SELECT task_id, task_name, min, hour, day
	from [dbo].[wv_Details]
		WHERE [id]=@id
		AND [min]= (select min([min])from [dbo].[wv_Details])
		AND (convert(varchar(10),[task_created],101) >=RTRIM(LTRIM(@Date1))  
				AND  convert(varchar(10),[task_created],101) <=RTRIM(LTRIM(@Date2)))
	end

END




GO
/****** Object:  StoredProcedure [dbo].[SP_insert_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_insert_task]
				@task_name varchar(50),
				@task_usr varchar(10),
				@task_sst bit
AS

BEGIN
	Insert Into [dbo].[task]
		(task_name, task_created , task_status, usr_id)
	values
		(@task_name,GETDATE(),@task_sst,@task_usr)
END



GO
/****** Object:  StoredProcedure [dbo].[SP_insert_user]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_insert_user]
				@name varchar(50)
AS
Declare @stts bit
Set @stts = 1
BEGIN
	Insert Into [dbo].[usr_task]
		(usr_name,usr_status)
	values
		(@name,@stts)
END



GO
/****** Object:  StoredProcedure [dbo].[SP_select_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_select_task]
						@id bigint

AS

BEGIN
	select task_id, task_name, task_created, task_completed,
	case 
	 WHEN task_completed IS NULL THEN 'IN PROGRESS'
	 ELSE
	 'COMPLETED'
	end as STAT
	from [dbo].[task] a
	inner join [dbo].[usr_task] b 
	on a.usr_id=b.id
	where a.usr_id=@id
END



GO
/****** Object:  StoredProcedure [dbo].[SP_select_user]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_select_user]

AS

BEGIN
	select * from  [dbo].[usr_task]
END



GO
/****** Object:  StoredProcedure [dbo].[SP_update_task]    Script Date: 5/17/2022 8:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_update_task]
					@id_task int,
					@id_usr int
					

AS

BEGIN
	update [dbo].[task]
	set [task_completed]= GETDATE()
	where [task_id]=@id_task
	and [usr_id]=@id_usr
	END




GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 119
               Right = 418
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'wv_Details'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'wv_Details'
GO
