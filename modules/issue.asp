<!-- #include virtual="/modules/Common.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "getIssues" Then
		project = textFilter(Request("project"))
		PAGE = textFilter(Request("PAGE"))
		RFP = textFilter(Request("RFP"))
		orderBy = textFilter(Request("orderBy"))
		sString = textFilter(Request("sString"))
		sType = textFilter(Request("sType"))

        ReDim param(6)
		param(0) = DBHelper.MakeParam("@project", adInteger, adParamInput, -1, project)
		param(1) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)
		param(2) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(3) = DBHelper.MakeParam("@orderBy", adVarChar, adParamInput, 10, orderBy)
		param(4) = DBHelper.MakeParam("@sString", adVarChar, adParamInput, 100, sString)
		param(5) = DBHelper.MakeParam("@sType", adVarChar, adParamInput, 50, sType)
		param(6) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))

		Set rs = DBHelper.ExecSPReturnRS("getIssues", param, Nothing)
		If Not rs.EOF Or Not rs.BOF Then			
			Set issueList = New aspJSON
			issueList.data.Add "maxCount", ""	
			issueList.data.Add "list", issueList.Collection()
			Do Until rs.EOF Or rs.BOF		
				Set row = issueList.AddToCollection (issueList.data ("list"))
				row.add "page", CStrN(rs("page"))
				row.add "PAGE_IDX", CStrN(rs("PAGE_IDX"))
				row.add "project", CStrN(rs("project"))
				row.add "partName", CStrN(rs("partName"))
				row.add "idx", CStrN(rs("idx"))
				row.add "perfection", CStrN(rs("perfection"))
				row.add "state", CStrN(rs("state"))	
				row.add "title", CStrN(rs("title"))
				row.add "targetDate", CStrN(rs("targetDate"))
				row.add "endDate", CStrN(rs("endDate"))
				row.add "created", CStrN(rs("created"))
				row.add "updated", CStrN(rs("updated"))
				row.add "createId", CStrN(rs("createId"))
				row.add "createName", CStrN(rs("createName"))
				row.add "updateId", CStrN(rs("updateId"))
				row.add "updateName", CStrN(rs("updateName"))				
				
				issueList.data("maxCount") = rs("MAX_COUNT")
				rs.movenext()
			Loop
			Response.Write issueList.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "getIssueTotal" Then
		project = textFilter(Request("project"))
		startDate = textFilter(Request("startDate"))
		endDate = textFilter(Request("endDate"))

        ReDim param(3)
		param(0) = DBHelper.MakeParam("@startDate", adVarChar, adParamInput, 8, startDate)
		param(1) = DBHelper.MakeParam("@endDate", adVarChar, adParamInput, 8, endDate)
		param(2) = DBHelper.MakeParam("@project", adInteger, adParamInput, -1, project)
		param(3) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("getIssueTotal", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then		
			If IsNull(rs("projectName")) Then
				projectIdx = ""
				projectName = ""
			Else
				projectIdx = rs("projectIdx")
				projectName = rs("projectName")
			End If
			Set total = New aspJSON
			total.data.Add "projectIdx", projectIdx
			total.data.Add "projectName", projectName
			total.data.Add "total", rs("total")
			total.data.Add "completed", rs("completed")
			total.data.Add "progress", rs("progress")
			total.data.Add "terminated", rs("terminated")
			Response.Write total.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "insertIssue" Then
		project = textFilter(Request("project"))
		part = textFilter(Request("part"))
		title = textFilter(Request("title"))
		contents = textFilter(Request("contents"))
		state = textFilter(Request("state"))
		targetDate = textFilter(Request("targetDate"))
		isEnabled = textFilter(Request("isEnabled"))
		userList = textFilter(Request("userList"))

		ReDim param(7)
		param(0) = DBHelper.MakeParam("@project", adInteger, adParamInput, -1, project)
		param(1) = DBHelper.MakeParam("@part", adInteger, adParamInput, -1, part)
		param(2) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 200, title)
		param(3) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		param(4) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		param(5) = DBHelper.MakeParam("@state", adInteger, adParamInput, -1, state)
		param(6) = DBHelper.MakeParam("@targetDate", adVarChar, adParamInput, 10, targetDate)
		param(7) = DBHelper.MakeParam("@isEnabled", adInteger, adParamInput, -1, isEnabled)
		Set rs = DBHelper.ExecSPReturnRS("insertIssue", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			If rs("state") = "true" Then
				ReDim param(0)
				param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, rs("idx"))
				DBHelper.ExecSP "removeAllIssueUser", param, Nothing

				Set temp = New aspJSON
				temp.loadJSON(userList)
				For Each i In temp.data("list")
					ReDim param(1)
					param(0) = DBHelper.MakeParam("@issue", adVarChar, adParamInput, 10, rs("idx"))
					param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 10, temp.data("list").item(i))
					DBHelper.ExecSP "setIssueUser", param, Nothing
				Next
			End If
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
			Response.Write res.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "updateIssue" Then
		idx = textFilter(Request("idx"))
		project = textFilter(Request("project"))
		part = textFilter(Request("part"))
		title = textFilter(Request("title"))
		contents = textFilter(Request("contents"))
		userId = User.data("userId")
		state = textFilter(Request("state"))
		targetDate = textFilter(Request("targetDate"))
		isEnded = textFilter(Request("isEnded"))
		isEnabled = textFilter(Request("isEnabled"))
		userList = textFilter(Request("userList"))

		ReDim param(8)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(1) = DBHelper.MakeParam("@part", adVarChar, adParamInput, 10, part)
		param(2) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 200, title)
		param(3) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		param(4) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, userId)
		param(5) = DBHelper.MakeParam("@state", adVarChar, adParamInput, 10, state)
		param(6) = DBHelper.MakeParam("@targetDate", adVarChar, adParamInput, 10, targetDate)
		param(7) = DBHelper.MakeParam("@isEnded", adVarChar, adParamInput, 1, isEnded)
		param(8) = DBHelper.MakeParam("@isEnabled", adVarChar, adParamInput, 1, isEnabled)
		Set rs = DBHelper.ExecSPReturnRS("updateIssue", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			If rs("state") = "true" Then
				ReDim param(0)
				param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
				DBHelper.ExecSP "removeAllIssueUser", param, Nothing

				Set temp = New aspJSON
				temp.loadJSON(userList)
				For Each i In temp.data("list")
					ReDim param(1)
					param(0) = DBHelper.MakeParam("@issue", adVarChar, adParamInput, 10, idx)
					param(1) = DBHelper.MakeParam("@user", adVarChar, adParamInput, 10, temp.data("list").item(i))
					DBHelper.ExecSP "setIssueUser", param, Nothing
				Next
			End If
			res.data("state") = rs("state")
			res.data("code") = rs("code")
			res.data("message") = rs("message")
			Response.Write res.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	ElseIf ROLE = "removeIssue" Then
		idx = textFilter(Request("idx"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("removeIssue", param, Nothing)

		res.data("state") = rs("state")
		res.data("code") = rs("code")
		res.data("message") = rs("message")
		Response.Write res.JSONoutput()

	ElseIf ROLE = "getIssue" Then
		idx = textFilter(Request("idx"))
		project = textFilter(Request("project"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(1) = DBHelper.MakeParam("@project", adInteger, adParamInput, -1, project)
		Set rsDetail = DBHelper.ExecSPReturnRS("getIssue", param, Nothing)

		ReDim param(0)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		Set rsUser = DBHelper.ExecSPReturnRS("getIssueUser", param, Nothing)

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@parentTable", adVarchar, adParamInput, 50, "Issue")
		param(1) = DBHelper.MakeParam("@parent", adVarchar, adParamInput, 10, idx)
		Set rsFile = DBHelper.ExecSPReturnRS("getFiles", param, Nothing)

		If Not rsDetail.EOF And Not rsDetail.BOF Then
			Set view = New aspJSON
			view.data.Add "idx", rsDetail("idx")
			view.data.Add "partId", rsDetail("partId")
			view.data.Add "partName", rsDetail("partName")
			view.data.Add "projectId", rsDetail("projectId")
			view.data.Add "projectName", rsDetail("projectName")
			view.data.Add "title", rsDetail("title")
			view.data.Add "perfection", rsDetail("perfection")
			view.data.Add "stateName", rsDetail("stateName")
			view.data.Add "stateId", rsDetail("stateId")
			view.data.Add "targetDate", rsDetail("targetDate")
			view.data.Add "endDate", rsDetail("endDate")
			view.data.Add "created", rsDetail("created")
			view.data.Add "createId", rsDetail("createId")
			view.data.Add "createName", rsDetail("createName")
			view.data.Add "updated", rsDetail("updated")
			view.data.Add "updateId", rsDetail("updateId")
			view.data.Add "updateName", rsDetail("updateName")
			view.data.Add "contents", rsDetail("contents")
			view.data.Add "isEnabled", rsDetail("isEnabled")
			view.data.Add "users", view.Collection()
			Do Until rsUser.EOF OR rsUser.BOF
				If IsNull(rsUser("part")) Then
					Exit Do
				Else
					Set row = view.AddToCollection (view.data ("users"))
					row.add "part", CStrN(rsUser("part"))
					row.add "id", CStrN(rsUser("id"))
					row.add "name", CStrN(rsUser("name"))
					row.add "class", CStrN(rsUser("class"))
				End If
				rsUser.movenext()
			Loop
			view.data.Add "files", view.Collection()
			Do Until rsFile.EOF OR rsFile.BOF
				If rsFile("idx") = "0" Then
					Exit Do
				Else
					Set row = view.AddToCollection (view.data ("files"))
					row.add "idx", CStrN(rsFile("idx"))
					row.add "parentTable", CStrN(rsFile("parentTable"))
					row.add "parent", CStrN(rsFile("parent"))
					row.add "path", CStrN(rsFile("path"))
					row.add "name", CStrN(rsFile("name"))
				End If				
				rsFile.movenext()
			Loop

			Response.Write view.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	Else
		Response.Write Session("userInfo")
		Response.End()
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
	Set rs = Nothing
	Set rsDetail = Nothing
	Set rsUser = Nothing
	Set temp = Nothing
	Set issueList = Nothing
	Set total = Nothing
%>