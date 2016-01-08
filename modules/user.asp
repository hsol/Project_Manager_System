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