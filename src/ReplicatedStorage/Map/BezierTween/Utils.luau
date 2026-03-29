local function LerpValue(A, B, T)
	local TypeA = typeof(A)

	if TypeA == 'Vector3' then
		return A * (1 - T) + B * T
	elseif TypeA == 'UDim2' then
		return UDim2.new(
			A.X.Scale * (1 - T) + B.X.Scale * T,
			A.X.Offset * (1 - T) + B.X.Offset * T,
			A.Y.Scale * (1 - T) + B.Y.Scale * T,
			A.Y.Offset * (1 - T) + B.Y.Offset * T
		)
	elseif TypeA == 'Color3' then
		return Color3.new(
			A.R * (1 - T) + B.R * T,
			A.G * (1 - T) + B.G * T, 
			A.B * (1 - T) + B.B * T
		)
	elseif TypeA == 'CFrame' then
		local PosA, PosB = A.Position, B.Position
		local Position = PosA * (1 - T) + PosB * T
		return A:Lerp(B, T)
	elseif TypeA == 'number' then
		return A * (1 - T) + B * T
	else
		return A
	end
end

local Utils = {}

function Utils.GetPointValue(Point, PropertyType)
	if typeof(Point) == 'Instance' and Point:IsA'BasePart' then
		if PropertyType == 'CFrame' then
			return Point.CFrame
		else
			return Point.Position
		end
	else
		return Point
	end
end

function Utils.BezierPoint(Points, T)
	local N = #Points
	if N == 0 then return nil end
	local FirstPoint = Points[1]
	local PointType = typeof(FirstPoint)

	local ProcessedPoints = {}

	if PointType == 'Instance' and FirstPoint:IsA'BasePart' then
		if typeof(Points[2]) == 'CFrame' or (typeof(Points[2]) == 'Instance' and Points[2]:IsA'BasePart') then
			for I, Point in Points do
				ProcessedPoints[I] = Utils.GetPointValue(Point, 'CFrame')
			end

			local TempPoints = table.clone(ProcessedPoints)
			for J = 1, N - 1 do
				for K = 1, N - J do
					TempPoints[K] = LerpValue(TempPoints[K], TempPoints[K + 1], T)
				end
			end

			local ResultCFrame = TempPoints[1]

			local Derivative = Vector3.new()
			if N >= 2 then
				local TempDeriv = {}
				for I = 1, N - 1 do
					TempDeriv[I] = (ProcessedPoints[I + 1].Position - ProcessedPoints[I].Position) * (N - 1)
				end

				for J = 1, N - 2 do
					for K = 1, N - 1 - J do
						TempDeriv[K] = LerpValue(TempDeriv[K], TempDeriv[K + 1], T)
					end
				end

				Derivative = TempDeriv[1]
			end

			if Derivative.Magnitude > 0.001 then
				local LookDir = Derivative.Unit
				ResultCFrame = CFrame.lookAt(ResultCFrame.Position, ResultCFrame.Position + LookDir, Vector3.new(0, 1, 0))
			else
				local ClosestIndex = math.floor(T * (N - 1) + 1.5)
				ClosestIndex = math.clamp(ClosestIndex, 1, N)
				local ClosestOrientation = ProcessedPoints[ClosestIndex] - ProcessedPoints[ClosestIndex].Position
				ResultCFrame = CFrame.new(ResultCFrame.Position) * ClosestOrientation
			end

			return ResultCFrame
		else
			for I, Point in Points do
				ProcessedPoints[I] = Utils.GetPointValue(Point, 'Position')
			end

			for J = 1, N - 1 do
				for K = 1, N - J do
					ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
				end
			end

			return ProcessedPoints[1]
		end
	elseif PointType == 'Vector3' then
		local HasBasePartPoints = false

		for I, Point in Points do
			if typeof(Point) == 'Instance' and Point:IsA'BasePart' then
				HasBasePartPoints = true
				ProcessedPoints[I] = Point.Position
			else
				ProcessedPoints[I] = Point
			end
		end

		for J = 1, N - 1 do
			for K = 1, N - J do
				ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
			end
		end

		return ProcessedPoints[1]
	elseif PointType == 'UDim2' then
		for I, Point in Points do
			ProcessedPoints[I] = Point
		end

		for J = 1, N - 1 do
			for K = 1, N - J do
				ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
			end
		end

		return ProcessedPoints[1]
	elseif PointType == 'Color3' then
		for I, Point in Points do
			ProcessedPoints[I] = Point
		end

		for J = 1, N - 1 do
			for K = 1, N - J do
				ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
			end
		end

		return ProcessedPoints[1]
	elseif PointType == 'CFrame' then
		for I, Point in Points do
			ProcessedPoints[I] = Point
		end

		for J = 1, N - 1 do
			for K = 1, N - J do
				ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
			end
		end

		local ResultCFrame = ProcessedPoints[1]

		local Derivative = Vector3.new()
		if N >= 2 then
			local TempDeriv = {}
			for I = 1, N - 1 do
				TempDeriv[I] = (Points[I + 1].Position - Points[I].Position) * (N - 1)
			end

			for J = 1, N - 2 do
				for K = 1, N - 1 - J do
					TempDeriv[K] = LerpValue(TempDeriv[K], TempDeriv[K + 1], T)
				end
			end

			Derivative = TempDeriv[1]
		end

		if Derivative.Magnitude > 0.001 then
			local LookDir = Derivative.Unit
			ResultCFrame = CFrame.lookAt(ResultCFrame.Position, ResultCFrame.Position + LookDir, Vector3.new(0, 1, 0))
		else
			local ClosestIndex = math.floor(T * (N - 1) + 1.5)
			ClosestIndex = math.clamp(ClosestIndex, 1, N)
			local ClosestOrientation = Points[ClosestIndex] - Points[ClosestIndex].Position
			ResultCFrame = CFrame.new(ResultCFrame.Position) * ClosestOrientation
		end

		return ResultCFrame
	elseif PointType == 'number' then
		for I, Point in Points do
			ProcessedPoints[I] = Point
		end

		for J = 1, N - 1 do
			for K = 1, N - J do
				ProcessedPoints[K] = LerpValue(ProcessedPoints[K], ProcessedPoints[K + 1], T)
			end
		end

		return ProcessedPoints[1]
	else
		return FirstPoint
	end
end

function Utils.CalculateDerivative(Points, T)
	local N = #Points
	if N < 2 then return typeof(Points[1]) == 'Vector3' and Vector3.new() or Points[1] end
	local FirstPoint = Points[1]
	local PointType = typeof(FirstPoint)

	local DiffPoints = {}
	for I = 1, N - 1 do
		if PointType == 'Instance' and FirstPoint:IsA'BasePart' then
			local P0 = Utils.GetPointValue(Points[I], 'Position')
			local P1 = Utils.GetPointValue(Points[I + 1], 'Position')
			DiffPoints[I] = (P1 - P0) * (N - 1)
		elseif PointType == 'Vector3' then
			local P0, P1
			if typeof(Points[I]) == 'Instance' and Points[I]:IsA'BasePart' then
				P0 = Points[I].Position
			else
				P0 = Points[I]
			end

			if typeof(Points[I + 1]) == 'Instance' and Points[I + 1]:IsA'BasePart' then
				P1 = Points[I + 1].Position
			else
				P1 = Points[I + 1]
			end

			DiffPoints[I] = (P1 - P0) * (N - 1)
		elseif PointType == 'UDim2' then
			local P0, P1 = Points[I], Points[I + 1]
			DiffPoints[I] = UDim2.new(
				(P1.X.Scale - P0.X.Scale) * (N - 1),
				(P1.X.Offset - P0.X.Offset) * (N - 1),
				(P1.Y.Scale - P0.Y.Scale) * (N - 1),
				(P1.Y.Offset - P0.Y.Offset) * (N - 1)
			)
		elseif PointType == 'Color3' then
			local P0, P1 = Points[I], Points[I + 1]
			DiffPoints[I] = Color3.new(
				(P1.R - P0.R) * (N - 1),
				(P1.G - P0.G) * (N - 1),
				(P1.B - P0.B) * (N - 1)
			)
		elseif PointType == 'CFrame' then
			local P0, P1 = Points[I].Position, Points[I + 1].Position
			DiffPoints[I] = (P1 - P0) * (N - 1)
		elseif PointType == 'number' then
			local P0, P1 = Points[I], Points[I + 1]
			DiffPoints[I] = (P1 - P0) * (N - 1)
		end
	end

	if #DiffPoints == 1 then
		if PointType == 'CFrame' then
			return CFrame.new(DiffPoints[1])
		else
			return DiffPoints[1]
		end
	end

	for J = 1, #DiffPoints - 1 do
		for K = 1, #DiffPoints - J do
			DiffPoints[K] = LerpValue(DiffPoints[K], DiffPoints[K + 1], T)
		end
	end

	if PointType == 'CFrame' then
		return CFrame.new(DiffPoints[1])
	else
		return DiffPoints[1]
	end
end

return Utils