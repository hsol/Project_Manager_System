<!-- #include virtual="/modules/Common.asp"  -->
<%
	'on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "getIssueList" Then
		project = textFilter(Request("project"))
		PAGE = textFilter(Request("PAGE"))
		RFP = textFilter(Request("RFP"))
		orderBy = textFilter(Request("orderBy"))
		sString = textFilter(Request("sString"))
		sType = textFilter(Request("sType"))

        ReDim param(5)
		param(0) = DBHelper.MakeParam("@project", adVarChar, adParamInput, 10, project)
		param(1) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)
		param(2) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(3) = DBHelper.MakeParam("@orderBy", adVarChar, adParamInput, 10, orderBy)
		param(4) = DBHelper.MakeParam("@sString", adVarChar, adParamInput, 100, sString)
		param(5) = DBHelper.MakeParam("@sType", adVarChar, adParamInput, 50, sType)

		Set rs = DBHelper.ExecSPReturnRS("getIssueList", param, Nothing)
		If Not rs.EOF Or Not rs.BOF Then			
			Set issueList = New aspJSON
			issueList.data.Add "maxCount", ""	
			issueList.data.Add "list", issueList.Collection()
			Do Until rs.EOF Or rs.BOF		
				Set row = issueList.AddToCollection (issueList.data ("list"))
				row.add "page", CStr(rs("page"))
				row.add "PAGE_IDX", CStr(rs("PAGE_IDX"))
				row.add "project", CStr(rs("project"))
				row.add "idx", CStr(rs("idx"))
				row.add "perfection", CStr(rs("perfection"))
				row.add "state", CStr(rs("state"))	
				row.add "title", CStr(rs("title"))
				row.add "targetDate", CStr(rs("targetDate"))
				row.add "endDate", CStr(rs("endDate"))
				row.add "created", CStr(rs("created"))
				row.add "updated", CStr(rs("updated"))
				row.add "createId", CStr(rs("createId"))
				row.add "createName", CStr(rs("createName"))
				row.add "updateId", CStr(rs("updateId"))
				row.add "updateName", CStr(rs("updateName"))				
				
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

        ReDim param(2)
		param(0) = DBHelper.MakeParam("@startDate", adVarChar, adParamInput, 8, startDate)
		param(1) = DBHelper.MakeParam("@endDate", adVarChar, adParamInput, 8, endDate)
		param(2) = DBHelper.MakeParam("@project", adVarChar, adParamInput, 10, project)
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
		userId = User.data("userId")
		state = textFilter(Request("state"))
		targetDate = textFilter(Request("targetDate"))
		isEnabled = textFilter(Request("isEnabled"))
		userList = textFilter(Request("userList"))

		ReDim param(7)
		param(0) = DBHelper.MakeParam("@project", adVarChar, adParamInput, 10, project)
		param(1) = DBHelper.MakeParam("@part", adVarChar, adParamInput, 10, part)
		param(2) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 50, title)
		param(3) = DBHelper.MakeParam("@contents", adVarChar, adParamInput, -1, contents)
		param(4) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, userId)
		param(5) = DBHelper.MakeParam("@state", adVarChar, adParamInput, 10, state)
		param(6) = DBHelper.MakeParam("@targetDate", adVarChar, adParamInput, 10, targetDate)
		param(7) = DBHelper.MakeParam("@isEnabled", adVarChar, adParamInput, 1, isEnabled)
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
		param(2) = DBHelper.MakeParam("@title", adVarChar, adParamInput, 50, title)
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

		ReDim param(0)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		DBHelper.ExecSP "removeIssue", param, Nothing

		res.data("state") = "true"
		res.data("code") = "00"
		res.data("message") = "삭제되었습니다."
		Response.Write res.JSONoutput()

	ElseIf ROLE = "getIssueDetail" Then
		idx = textFilter(Request("idx"))
		project = textFilter(Request("project"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(1) = DBHelper.MakeParam("@project", adInteger, adParamInput, -1, project)
		Set rsDetail = DBHelper.ExecSPReturnRS("getIssueDetail", param, Nothing)

		ReDim param(0)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		Set rsUser = DBHelper.ExecSPReturnRS("getIssueUser", param, Nothing)

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@parentTable", adVarchar, adParamInput, 50, "Issue")
		param(1) = DBHelper.MakeParam("@parent", adVarchar, adParamInput, 10, idx)
		Set rsFile = DBHelper.ExecSPReturnRS("getFileList", param, Nothing)

		If Not rsDetail.EOF And Not rsDetail.BOF And Not rsUser.EOF And Not rsUser.BOF Then
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
				If rsUser("part") = "0" Then
					Exit Do
				End If
				Set row = view.AddToCollection (view.data ("users"))
				row.add "part", CStr(rsUser("part"))
				row.add "id", CStr(rsUser("id"))
				row.add "name", CStr(rsUser("name"))
				row.add "class", CStr(rsUser("class"))
				rsUser.movenext()
			Loop
			view.data.Add "files", view.Collection()
			Do Until rsFile.EOF OR rsFile.BOF
				If rsFile("idx") = "0" Then
					Exit Do
				End If
				Set row = view.AddToCollection (view.data ("files"))
				row.add "idx", CStr(rsFile("idx"))
				row.add "parentTable", CStr(rsFile("parentTable"))
				row.add "parent", CStr(rsFile("parent"))
				row.add "path", CStr(rsFile("path"))
				row.add "name", CStr(rsFile("name"))
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