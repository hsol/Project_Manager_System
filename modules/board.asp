<!-- #include virtual="/modules/Common.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))
	
	Dim param

	If ROLE = "getBoards" Then
		head = textFilter(Request("head"))
		PAGE = textFilter(Request("PAGE"))
		RFP = textFilter(Request("RFP"))
		orderBy = textFilter(Request("orderBy"))
		sString = textFilter(Request("sString"))
		sType = textFilter(Request("sType"))
		If PAGE = "" Or RFP = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

        ReDim param(6)
		param(0) = DBHelper.MakeParam("@head", adVarChar, adParamInput, 50, head)
		param(1) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)
		param(2) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(3) = DBHelper.MakeParam("@orderBy", adVarChar, adParamInput, 10, orderBy)
		param(4) = DBHelper.MakeParam("@sString", adVarChar, adParamInput, 100, sString)
		param(5) = DBHelper.MakeParam("@sType", adVarChar, adParamInput, 50, sType)
		param(6) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("getBoards", param, Nothing)
		If Not rs.EOF And Not rs.BOF Then			
			Set boardList = New aspJSON
			boardList.data.Add "maxCount", ""	
			boardList.data.Add "list", boardList.Collection()
			Do Until rs.EOF OR rs.BOF
				Set row = boardList.AddToCollection (boardList.data ("list"))
				row.add "page", CStrN(rs("page"))
				row.add "PAGE_IDX", CStrN(rs("PAGE_IDX"))
				row.add "idx", CStrN(rs("idx"))
				row.add "head", CStrN(rs("head"))
				row.add "title", CStrN(rs("title"))
				row.add "created", CStrN(rs("created"))
				row.add "updated", CStrN(rs("updated"))
				row.add "createId", CStrN(rs("createId"))
				row.add "createName", CStrN(rs("createName"))
				row.add "updateId", CStrN(rs("updateId"))
				row.add "updateName", CStrN(rs("updateName"))
				
				boardList.data("maxCount") = rs("MAX_COUNT")
				rs.movenext()
			Loop
			Response.Write boardList.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	ElseIf ROLE = "getBoard" Then
		head = textFilter(Request("head"))
		idx = textFilter(Request("idx"))

		If head = "" Or idx = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

        ReDim param(2)
		param(0) = DBHelper.MakeParam("@head", adVarChar, adParamInput, 50, head)
		param(1) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, idx)
		param(2) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("getBoard", param, Nothing)
		If Not rs.EOF And Not rs.BOF Then
			Set board = New aspJSON
			board.data.Add "state", CStrN(rs("true"))
			board.data.Add "parent", CStrN(rs("parent"))
			board.data.Add "title", CStrN(rs("title"))
			board.data.Add "description", CStrN(rs("description"))
			board.data.Add "updated", CStrN(rs("updated"))
			board.data.Add "createId", CStrN(rs("createId"))
			board.data.Add "createName", CStrN(rs("createName"))
			board.data.Add "updateId", CStrN(rs("updateId"))
			board.data.Add "updateName", CStrN(rs("updateName"))
			board.data.Add "isEnabled", CStrN(rs("isEnabled"))
			board.data.Add "hit", CStrN(rs("hit"))
			Response.Write board.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	ElseIf ROLE = "insertBoard" Then
		head = textFilter(Request("head"))
		idx = textFilter(Request("idx"))
		parent = textFilter(Request("parent"))
		title = textFilter(Request("title"))
		description = textFilter(Request("description"))
		isEnabled = textFilter(Request("isEnabled"))

		If title = "" Or description = "" Or head = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

        ReDim param(6)
		param(0) = DBHelper.MakeParam("@head", adVarChar, adParamInput, 50, head)
		param(1) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(2) = DBHelper.MakeParam("@parent", adInteger, adParamInput, -1, parent)
		param(3) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 100, title)
		param(4) = DBHelper.MakeParam("@description", adVarChar, adParamInput, -1, description)
		param(5) = DBHelper.MakeParam("@isEnabled", adInteger, adParamInput, -1, isEnabled)
		param(6) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("setBoard", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "updateBoard" Then
		head = textFilter(Request("head"))
		idx = textFilter(Request("idx"))
		parent = textFilter(Request("parent"))
		title = textFilter(Request("title"))
		description = textFilter(Request("description"))
		isEnabled = textFilter(Request("isEnabled"))

		If title = "" Or description = "" Or idx = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

        ReDim param(6)
		param(0) = DBHelper.MakeParam("@head", adVarChar, adParamInput, 50, head)
		param(1) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(2) = DBHelper.MakeParam("@parent", adInteger, adParamInput, -1, parent)
		param(3) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 100, title)
		param(4) = DBHelper.MakeParam("@description", adVarChar, adParamInput, -1, description)
		param(5) = DBHelper.MakeParam("@isEnabled", adInteger, adParamInput, -1, isEnabled)
		param(6) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("setBoard", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then			
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "removeBoard" Then
		idx = textFilter(Request("idx"))

		If idx = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

        ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("removeBoard", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	Else
		Response.Write Session("userInfo")
	End If

	If Err.Number <> 0 Then
		Response.Clear()
		res.data("state") = "false"
		res.data("code") = Err.Number
		res.data("message") = Err.Description
		Response.Write res.JSONoutput()
	End If

	DBHelper.Dispose
	Set DBHelper = Nothing
%>