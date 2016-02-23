<!-- #include virtual="/modules/Common.asp"  -->
<%
	on error resume Next
	ROLE = textFilter(Request("role"))

	Dim param
	
	If ROLE = "getUserList" Then
		PAGE = textFilter(Request("page"))
		RFP = textFilter(Request("rfp"))
		sString = textFilter(Request("sString"))
		sType = textFilter(Request("sType"))

		ReDim param(3)
		param(0) = DBHelper.MakeParam("@PAGE", adInteger, adParamInput, -1, PAGE)
		param(1) = DBHelper.MakeParam("@RFP", adInteger, adParamInput, -1, RFP)
		param(2) = DBHelper.MakeParam("@sString", adVarChar, adParamInput, 100, sString)
		param(3) = DBHelper.MakeParam("@sType", adVarChar, adParamInput, 50, sType)
		Set rs = DBHelper.ExecSPReturnRS("getUserList", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
			Set userList = New aspJSON
			userList.data.Add "maxCount", ""	
			userList.data.Add "list", userList.Collection()
			Do Until rs.EOF
				Set row = userList.AddToCollection(userList.data("list"))
				row.add "page_idx", CStr(rs("PAGE_IDX"))
				row.add "idx", CStr(rs("idx"))
				row.add "part", CStr(rs("part"))
				row.add "id", CStr(rs("id"))
				row.add "name", CStr(rs("name"))	
				userList.data("maxCount") = rs("MAX_COUNT")
				rs.movenext()
			Loop
			Response.Write userList.JSONoutput()
		Else
			res.data("state") = "false"
			res.data("code") = "10"
			res.data("message") = "서버가 응답하지 않습니다."
			Response.Write res.JSONoutput()
		End If
	ElseIf ROLE = "updateUser" Then	
		userid = textFilter(Request("userid"))
		password = textFilter(Request("password"))
		name = textFilter(Request("name"))
		duty = textFilter(Request("duty"))
		part = textFilter(Request("part"))

		If userid = "" Then
			res.data("state") = "false"
			res.data("code") = "01"
			res.data("message") = "필요한 파라미터가 존재하지 않습니다."
			Response.Write res.JSONoutput()
			Response.End()
		ElseIf userid <> User.data("userId") Then
			res.data("state") = "false"
			res.data("code") = "E4"
			res.data("message") = "권한이 없습니다."
			Response.Write res.JSONoutput()
			Response.End()
		End If

		ReDim param(4)
		param(0) = DBHelper.MakeParam("@userid", adVarChar, adParamInput, 50, userid)		
		param(1) = DBHelper.MakeParam("@password", adVarChar, adParamInput, 100, password)
		param(2) = DBHelper.MakeParam("@name", adVarChar, adParamInput, 100, name)
		param(3) = DBHelper.MakeParam("@duty", adInteger, adParamInput, -1, duty)
		param(4) = DBHelper.MakeParam("@part", adInteger, adParamInput, -1, part)
		Set rs = DBHelper.ExecSPReturnRS("updateUser", param, Nothing)

		If Not rs.EOF And Not rs.BOF Then
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
%>