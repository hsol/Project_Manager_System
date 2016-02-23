<!-- #include virtual="/modules/Common.asp"  -->
<% ROLE = "user" %>
<!-- #include virtual="/modules/module_permission.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))
	
	Dim param

	If ROLE = "getProjects" Then
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

        ReDim param(5)
		param(0) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)
		param(1) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(2) = DBHelper.MakeParam("@orderBy", adVarChar, adParamInput, 10, orderBy)
		param(3) = DBHelper.MakeParam("@sString", adVarChar, adParamInput, 100, sString)
		param(4) = DBHelper.MakeParam("@sType", adVarChar, adParamInput, 50, sType)
		param(5) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("getProjects", param, Nothing)
		If Not rs.EOF And Not rs.BOF Then			
			Set projectList = New aspJSON
			projectList.data.Add "maxCount", ""	
			projectList.data.Add "list", projectList.Collection()
			Do Until rs.EOF OR rs.BOF
				Set row = projectList.AddToCollection (projectList.data ("list"))
				row.add "page", CStrN(rs("page"))
				row.add "PAGE_IDX", CStrN(rs("PAGE_IDX"))
				row.add "idx", CStrN(rs("idx"))
				row.add "perfection", CStrN(rs("perfection"))
				row.add "state", CStrN(rs("state"))				
				row.add "name", CStrN(rs("name"))
				row.add "created", CStrN(rs("created"))
				row.add "updated", CStrN(rs("updated"))
				row.add "createId", CStrN(rs("createId"))
				row.add "createName", CStrN(rs("createName"))
				row.add "updateId", CStrN(rs("updateId"))
				row.add "updateName", CStrN(rs("updateName"))
				row.add "targetDate", CStrN(rs("targetDate"))
				row.add "endDate", CStrN(rs("endDate"))
				
				projectList.data("maxCount") = rs("MAX_COUNT")
				rs.movenext()
			Loop
			Response.Write projectList.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If

	ElseIf ROLE = "getProjectTotal" Then
		startDate = textFilter(Request("startDate"))
		endDate = textFilter(Request("endDate"))

        ReDim param(2)
		param(0) = DBHelper.MakeParam("@startDate", adVarChar, adParamInput, 8, startDate)
		param(1) = DBHelper.MakeParam("@endDate", adVarChar, adParamInput, 8, endDate)
		param(2) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("getProjectTotal", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then			
			Set total = New aspJSON
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

	ElseIf ROLE = "getProject" Then
		idx = textFilter(Request("idx"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rsDetail = DBHelper.ExecSPReturnRS("getProject", param, Nothing)

		ReDim param(0)
		param(0) = DBHelper.MakeParam("@idx", adInteger, adParamInput, -1, idx)
		Set rsUser = DBHelper.ExecSPReturnRS("getProjectUser", param, Nothing)

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@parentTable", adVarchar, adParamInput, 50, "Project")
		param(1) = DBHelper.MakeParam("@parent", adVarchar, adParamInput, 10, idx)
		Set rsFile = DBHelper.ExecSPReturnRS("getFiles", param, Nothing)

		If Not rsDetail.EOF And Not rsDetail.BOF Then
			Set view = New aspJSON
			view.data.Add "idx", rsDetail("idx")
			view.data.Add "projectName", rsDetail("projectName")
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
			view.data.Add "description", rsDetail("description")
			view.data.Add "isEnabled", rsDetail("isEnabled")
			view.data.Add "issueCount", rsDetail("issueCount")
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
	ElseIf ROLE = "insertProject" Then
		name = textFilter(Request("name"))		
		description = textFilter(Request("description"))
		state = textFilter(Request("state"))
		targetDate = textFilter(Request("targetDate"))
		isEnabled = textFilter(Request("isEnabled"))
		userList = textFilter(Request("userList"))

		ReDim param(5)
		param(0) = DBHelper.MakeParam("@name", adVarChar, adParamInput, 200, name)
		param(1) = DBHelper.MakeParam("@description", adVarChar, adParamInput, -1, description)
		param(2) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		param(3) = DBHelper.MakeParam("@state", adVarChar, adParamInput, 10, state)
		param(4) = DBHelper.MakeParam("@targetDate", adVarChar, adParamInput, 10, targetDate)
		param(5) = DBHelper.MakeParam("@isEnabled", adVarChar, adParamInput, 1, isEnabled)
		Set rs = DBHelper.ExecSPReturnRS("insertProject", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			If rs("state") = "true" Then
				ReDim param(0)
				param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, rs("idx"))
				DBHelper.ExecSP "removeAllProjectUser", param, Nothing

				Set temp = New aspJSON
				temp.loadJSON(userList)
				For Each i In temp.data("list")
					ReDim param(1)
					param(0) = DBHelper.MakeParam("@project", adVarChar, adParamInput, 10, rs("idx"))
					param(1) = DBHelper.MakeParam("@user", adVarChar, adParamInput, 10, temp.data("list").item(i))
					DBHelper.ExecSP "setProjectUser", param, Nothing
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
	ElseIf ROLE = "updateProject" Then
		idx = textFilter(Request("idx"))
		name = textFilter(Request("name"))
		description = textFilter(Request("description"))
		state = textFilter(Request("state"))
		targetDate = textFilter(Request("targetDate"))
		isEnded = textFilter(Request("isEnded"))
		isEnabled = textFilter(Request("isEnabled"))
		userList = textFilter(Request("userList"))

		ReDim param(7)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(1) = DBHelper.MakeParam("@name", adVarChar, adParamInput, 200, name)
		param(2) = DBHelper.MakeParam("@description", adVarChar, adParamInput, -1, description)
		param(3) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		param(4) = DBHelper.MakeParam("@state", adVarChar, adParamInput, 10, state)
		param(5) = DBHelper.MakeParam("@targetDate", adVarChar, adParamInput, 10, targetDate)
		param(6) = DBHelper.MakeParam("@isEnded", adVarChar, adParamInput, 1, isEnded)
		param(7) = DBHelper.MakeParam("@isEnabled", adVarChar, adParamInput, 1, isEnabled)
		Set rs = DBHelper.ExecSPReturnRS("updateProject", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then	
			If rs("state") = "true" Then
				ReDim param(0)
				param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
				DBHelper.ExecSP "removeAllProjectUser", param, Nothing

				Set temp = New aspJSON
				temp.loadJSON(userList)
				For Each i In temp.data("list")
					ReDim param(1)
					param(0) = DBHelper.MakeParam("@project", adVarChar, adParamInput, 10, idx)
					param(1) = DBHelper.MakeParam("@user", adVarChar, adParamInput, 10, temp.data("list").item(i))
					DBHelper.ExecSP "setProjectUser", param, Nothing
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
	ElseIf ROLE = "removeProject" Then
		idx = textFilter(Request("idx"))

		ReDim param(1)
		param(0) = DBHelper.MakeParam("@idx", adVarChar, adParamInput, 10, idx)
		param(1) = DBHelper.MakeParam("@userId", adVarChar, adParamInput, 50, User.data("userId"))
		Set rs = DBHelper.ExecSPReturnRS("removeProject", param, Nothing)

		res.data("state") = rs("state")
		res.data("code") = rs("code")
		res.data("message") = rs("message")
		Response.Write res.JSONoutput()
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
	Set rs = Nothing
	Set rsDetail = Nothing
	Set rsUser = Nothing
	Set rsFile = Nothing
	Set projectList = Nothing
	Set temp = Nothing
	Set total = Nothing
	
%>