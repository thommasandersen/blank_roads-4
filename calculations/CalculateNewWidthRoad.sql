DECLARE--*/--5.75
	@ObjectName varchar(250) = 'br4_elevated_node-2_lod.obj',
	@ObjectNameLoad varchar(250) = '',
	@NewWidth decimal(4,2) = 12.5,
	@OldWidth decimal(4,2) =9.5
--AS
SET @ObjectNameLoad  = @ObjectName
--IF @ObjectName LIKE 'br4_elevated%' AND @ObjectName LIKE '%lod%'
--	SET @OldWidth = 15
--if @ObjectName LIKE 'br4_basic_node-%' SET @ObjectNameLoad = 'br4_basic_node_lod.obj'

DECLARE
	@ObjectGName varchar(50)

SET @ObjectGName = replace(@ObjectName,'.obj','')

DECLARE @Ratio decimal(4,2) = @NewWidth/@OldWidth
DECLARE
	@Add decimal(4,2) = ((@NewWidth/2)-(@OldWidth/2)),
	@Pavement decimal(4,2) = (@NewWidth/2)-2
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	WITH cte_Temp AS (
		SELECT
			ROW_NUMBER() OVER(ORDER BY ObjectName ASC) AS MeshID,
			ObjectName,
			left(MeshValue,CHARINDEX(' ',MeshValue)-1) AS ObjectType,
			right(rtrim(MeshValue),len(MeshValue)-CHARINDEX(' ',MeshValue)) AS MeshValue,
			MeshValue AS OriginalMeshValue
		FROM MeshValues
		WHERE LEFT(MeshValue,1) NOT IN ('#','o')
	),  cte_Check AS (
		SELECT
			ct.MeshID,
			CHARINDEX(' ',ct.MeshValue) AS x,
			CHARINDEX(' ',ct.MeshValue,CHARINDEX(' ',ct.MeshValue)+1) y,
			len(MeshValue) AS z
		FROM cte_Temp ct
		WHERE ObjectType = 'v'
	), cte_Split AS (
		SELECT
			ct.MeshID,
			ct.ObjectName,
			ct.ObjectType,
			cast(left(ct.MeshValue,x) AS decimal(10,8)) AS MeshX,
			cast(right(left(ct.MeshValue,y),y-x) AS decimal(10,8)) AS MeshY,
			cast(right(left(ct.MeshValue,z),z-y) AS decimal(10,8)) AS MeshZ
		FROM cte_Temp ct
		INNER JOIN cte_Check cc
		ON cc.MeshID = ct.MeshID
	)
	SELECT
		--@ratio,
		--OriginalMeshValue,
		case when ct.ObjectType = 'v' then 
			concat(ct.ObjectType,' ',
				cast(
					case
						--when @ObjectName LIKE 'br4_elevated_node%' then MeshX*@ratio
						when MeshX > 1 then @add+MeshX
						when MeshX < -1 then MeshX-@add
					else MeshX end
				AS decimal(10,8)
				),
				' ',
				cast(
					MeshY
					AS decimal(10,8)
				),
				' ',
				MeshZ
			)
		when ct.ObjectType = 's' then concat('g ',@ObjectGName)
		else ct.OriginalMeshValue end AS MeshValue
	FROM cte_Temp ct
	LEFT JOIN cte_Split cs
	ON cs.MeshID = ct.MeshID
	WHERE ct.ObjectName = @ObjectNameLoad
	ORDER BY ct.MeshID
END